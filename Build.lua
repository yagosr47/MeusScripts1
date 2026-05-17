-- ==========================================
-- CONSTRUTOR AVANÇADO (EXECUTOR / LOCAL)
-- Criação, Edição, Desfazer e Refazer Ações
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- Garantir compatibilidade com executores de celular
local targetGui
if type(gethui) == "function" then
    targetGui = gethui()
else
    local success = pcall(function() return CoreGui.Name end)
    targetGui = success and CoreGui or player:WaitForChild("PlayerGui")
end

if targetGui:FindFirstChild("BuilderGUI") then
    targetGui.BuilderGUI:Destroy()
end

-- Pasta para guardar os blocos criados
local blocksFolder = workspace:FindFirstChild("LocalBuildingBlocks")
if not blocksFolder then
    blocksFolder = Instance.new("Folder")
    blocksFolder.Name = "LocalBuildingBlocks"
    blocksFolder.Parent = workspace
end

-- ==========================================
-- 1. SISTEMA DE DESFAZER / REFAZER (HISTORY)
-- ==========================================
local undoStack = {}
local redoStack = {}

local function registrarAcao(tipo, part, oldData, newData)
    table.insert(undoStack, {
        tipo = tipo,
        part = part,
        oldData = oldData,
        newData = newData
    })
    redoStack = {} -- Limpa o refazer se uma nova ação for feita
    if #undoStack > 50 then table.remove(undoStack, 1) end -- Limite de 50 ações
end

-- ==========================================
-- 2. CRIANDO A INTERFACE (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuilderGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGui

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 220, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ScrollBarThickness = 4
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🛠️ Construtor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local selectionText = Instance.new("TextLabel")
selectionText.Size = UDim2.new(0.9, 0, 0, 20)
selectionText.BackgroundTransparency = 1
selectionText.Text = "Selecionado: Nenhum"
selectionText.TextColor3 = Color3.fromRGB(150, 255, 150)
selectionText.Font = Enum.Font.Gotham
selectionText.TextSize = 12
selectionText.Parent = frame

-- Função para criar botões padronizados
local function criarBotao(nome, cor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = cor
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = frame
    return btn
end

local btnSpawn = criarBotao("➕ Criar Bloco", Color3.fromRGB(0, 150, 200))
local btnDuplicate = criarBotao("📑 Duplicar", Color3.fromRGB(50, 100, 200))
local btnStretch = criarBotao("↕️ Esticar (Aumentar)", Color3.fromRGB(200, 100, 50))
local btnShrink = criarBotao("↔️ Encolher (Diminuir)", Color3.fromRGB(200, 150, 50))
local btnColor = criarBotao("🎨 Mudar Cor", Color3.fromRGB(150, 50, 200))
local btnDelete = criarBotao("🗑️ Deletar", Color3.fromRGB(200, 50, 50))

local espaco = Instance.new("Frame", frame)
espaco.Size = UDim2.new(1, 0, 0, 10)
espaco.BackgroundTransparency = 1

local btnUndo = criarBotao("↩️ Desfazer", Color3.fromRGB(100, 100, 100))
local btnRedo = criarBotao("↪️ Refazer", Color3.fromRGB(100, 100, 100))

-- ==========================================
-- 3. LÓGICA DE SELEÇÃO E DESTAQUE
-- ==========================================
local selectedPart = nil
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 0)

local function selecionar(part)
    selectedPart = part
    if part then
        selectionText.Text = "Selecionado: Bloco"
        highlight.Parent = part
    else
        selectionText.Text = "Selecionado: Nenhum"
        highlight.Parent = nil
    end
end

-- Selecionar blocos ao clicar neles
mouse.Button1Down:Connect(function()
    if mouse.Target and mouse.Target:IsDescendantOf(blocksFolder) then
        selecionar(mouse.Target)
    end
end)

-- ==========================================
-- 4. AÇÕES DAS FERRAMENTAS
-- ==========================================

-- CRIAR BLOCO
btnSpawn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local novoBloco = Instance.new("Part")
    novoBloco.Size = Vector3.new(4, 4, 4)
    novoBloco.Position = char.HumanoidRootPart.Position + (char.HumanoidRootPart.CFrame.LookVector * 10)
    novoBloco.Anchored = true -- Fixado no ar para poder construir
    novoBloco.CanCollide = true -- Com física para o jogador pisar
    novoBloco.BrickColor = BrickColor.Random()
    novoBloco.Parent = blocksFolder

    registrarAcao("Criar", novoBloco, nil, nil)
    selecionar(novoBloco)
end)

-- DUPLICAR
btnDuplicate.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local clone = selectedPart:Clone()
    clone.Position = selectedPart.Position + Vector3.new(0, selectedPart.Size.Y, 0)
    clone.Parent = blocksFolder
    registrarAcao("Criar", clone, nil, nil)
    selecionar(clone)
end)

-- DELETAR
btnDelete.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    selectedPart.Parent = nil -- Esconde em vez de Destroy para poder desfazer
    registrarAcao("Deletar", selectedPart, nil, nil)
    selecionar(nil)
end)

-- MUDAR COR
btnColor.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local corAntiga = selectedPart.Color
    selectedPart.BrickColor = BrickColor.Random()
    local corNova = selectedPart.Color
    registrarAcao("Cor", selectedPart, corAntiga, corNova)
end)

-- ESTICAR / AUMENTAR TAMANHO
btnStretch.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    selectedPart.Size = selectedPart.Size + Vector3.new(2, 2, 2)
    registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
end)

-- ENCOLHER / DIMINUIR TAMANHO
btnShrink.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    local novoTamanho = selectedPart.Size - Vector3.new(2, 2, 2)
    -- Impede o bloco de ficar com tamanho zero ou negativo
    if novoTamanho.X > 0.5 and novoTamanho.Y > 0.5 and novoTamanho.Z > 0.5 then
        selectedPart.Size = novoTamanho
        registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
    end
end)

-- ==========================================
-- 5. LÓGICA DO DESFAZER E REFAZER
-- ==========================================

btnUndo.MouseButton1Click:Connect(function()
    if #undoStack == 0 then return end
    
    local acao = table.remove(undoStack, #undoStack) -- Pega a última ação
    table.insert(redoStack, acao) -- Move para o refazer

    if acao.tipo == "Criar" then
        acao.part.Parent = nil
        if selectedPart == acao.part then selecionar(nil) end
    elseif acao.tipo == "Deletar" then
        acao.part.Parent = blocksFolder
    elseif acao.tipo == "Cor" then
        acao.part.Color = acao.oldData
    elseif acao.tipo == "Tamanho" then
        acao.part.Size = acao.oldData
    end
end)

btnRedo.MouseButton1Click:Connect(function()
    if #redoStack == 0 then return end
    
    local acao = table.remove(redoStack, #redoStack) -- Pega a última ação desfeita
    table.insert(undoStack, acao) -- Devolve para o desfazer

    if acao.tipo == "Criar" then
        acao.part.Parent = blocksFolder
    elseif acao.tipo == "Deletar" then
        acao.part.Parent = nil
        if selectedPart == acao.part then selecionar(nil) end
    elseif acao.tipo == "Cor" then
        acao.part.Color = acao.newData
    elseif acao.tipo == "Tamanho" then
        acao.part.Size = acao.newData
    end
end)
