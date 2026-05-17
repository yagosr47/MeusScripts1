-- ==========================================
-- CONSTRUTOR AVANÇADO V3.1 (EXECUTOR / LOCAL)
-- Criar (Preview), Mover, Esticar por Alças, Duplicar, Cores, Desfazer e Refazer
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")

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
    redoStack = {}
    if #undoStack > 50 then table.remove(undoStack, 1) end
end

-- ==========================================
-- 2. CRIANDO A INTERFACE (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuilderGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGui

-- Container Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 430)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Barra Superior (Top Bar)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🛠️ Construtor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Botão Minimizar
local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -65, 0, 2)
btnMinimize.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
btnMinimize.Text = "-"
btnMinimize.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 18
Instance.new("UICorner", btnMinimize).CornerRadius = UDim.new(0, 4)
btnMinimize.Parent = topBar

-- Botão Fechar
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -32, 0, 2)
btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnClose.Text = "X"
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 14
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 4)
btnClose.Parent = topBar

-- Área de Conteúdo
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = contentFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local espacoTopo = Instance.new("Frame", contentFrame)
espacoTopo.Size = UDim2.new(1, 0, 0, 5)
espacoTopo.BackgroundTransparency = 1

local selectionText = Instance.new("TextLabel")
selectionText.Size = UDim2.new(0.9, 0, 0, 20)
selectionText.BackgroundTransparency = 1
selectionText.Text = "Selecionado: Nenhum"
selectionText.TextColor3 = Color3.fromRGB(150, 255, 150)
selectionText.Font = Enum.Font.Gotham
selectionText.TextSize = 12
selectionText.Parent = contentFrame

-- Função auxiliar de botões
local function criarBotao(nome, cor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = cor
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = contentFrame
    return btn
end

-- Configuração dos Botões
local btnSpawn = criarBotao("➕ Criar Bloco (Fantasma)", Color3.fromRGB(0, 150, 200))

-- Botão OK (Confirmação de Bloco Fantasma) - Fica dentro da lista e invisível por padrão
local btnConfirmOK = criarBotao("✅ Confirmar Posição [OK]", Color3.fromRGB(50, 200, 100))
btnConfirmOK.Visible = false

local btnMove = criarBotao("🖱️ Mover (Clique no Mapa)", Color3.fromRGB(200, 150, 0))
local btnDuplicate = criarBotao("📑 Duplicar", Color3.fromRGB(50, 100, 200))
local btnStretch = criarBotao("↕️ Esticar (+ Global)", Color3.fromRGB(200, 100, 50))
local btnShrink = criarBotao("↔️ Encolher (- Global)", Color3.fromRGB(200, 150, 50))
local btnColor = criarBotao("🎨 Mudar Cor", Color3.fromRGB(150, 50, 200))
local btnDelete = criarBotao("🗑️ Deletar", Color3.fromRGB(200, 50, 50))

local espaco = Instance.new("Frame", contentFrame)
espaco.Size = UDim2.new(1, 0, 0, 10)
espaco.BackgroundTransparency = 1

local btnUndo = criarBotao("↩️ Desfazer", Color3.fromRGB(100, 100, 100))
local btnRedo = criarBotao("↪️ Refazer", Color3.fromRGB(100, 100, 100))

-- ==========================================
-- 3. ALÇAS DE REDIMENSIONAMENTO (HANDLES DIRECONAIS)
-- ==========================================
local selectedPart = nil
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 0)

-- Criação do Objeto de Alças nativo do Roblox
local handles = Instance.new("SelectionHandles")
handles.Color3 = Color3.fromRGB(255, 255, 0)
handles.Style = Enum.SelectionHandlesStyle.Resize
handles.Parent = targetGui

local tamanhoInicial, cframeInicial
handles.MouseButton1Down:Connect(function(normal)
    if not selectedPart then return end
    tamanhoInicial = selectedPart.Size
    cframeInicial = selectedPart.CFrame
end)

handles.MouseDrag:Connect(function(normal, distance)
    if not selectedPart then return end
    local snapDistance = math.round(distance / 2) * 2
    local axis = Vector3.FromNormalId(normal)
    local novoTamanho = tamanhoInicial + (Vector3.new(math.abs(axis.X), math.abs(axis.Y), math.abs(axis.Z)) * snapDistance)
    
    if novoTamanho.X > 0.5 and novoTamanho.Y > 0.5 and novoTamanho.Z > 0.5 then
        selectedPart.Size = novoTamanho
        selectedPart.CFrame = cframeInicial + (selectedPart.CFrame:VectorToWorldSpace(axis) * (snapDistance / 2))
    end
end)

handles.MouseButton1Up:Connect(function(normal)
    if not selectedPart then return end
    registrarAcao("Transform", selectedPart, {Size = tamanhoInicial, CFrame = cframeInicial}, {Size = selectedPart.Size, CFrame = selectedPart.CFrame})
end)

-- ==========================================
-- 4. CONTROLE DE SELEÇÃO E ESTADOS
-- ==========================================
local isMovingMode = false
local ghostPart = nil
local ghostConnection = nil

local function selecionar(part)
    if ghostPart then
        ghostPart:Destroy()
        ghostPart = nil
        if ghostConnection then ghostConnection:Disconnect() end
        btnConfirmOK.Visible = false
    end

    selectedPart = part
    if part then
        selectionText.Text = "Selecionado: Bloco"
        highlight.Parent = part
        handles.Adornee = part
    else
        selectionText.Text = "Selecionado: Nenhum"
        highlight.Parent = nil
        handles.Adornee = nil
        isMovingMode = false
        btnMove.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        btnMove.Text = "🖱️ Mover (Clique no Mapa)"
    end
end

-- ==========================================
-- 5. LÓGICA DE INTERAÇÃO COM O MOUSE
-- ==========================================
mouse.Button1Down:Connect(function()
    -- Se estiver no modo de Preview Criar Fantasma, fixa o local temporariamente esperando o OK
    if ghostPart then
        if ghostConnection then 
            ghostConnection:Disconnect() 
            ghostConnection = nil 
        end
        return
    end

    -- Modo Mover Ativo
    if isMovingMode and selectedPart then
        local posicaoAntiga = selectedPart.Position
        local novaPosicao = mouse.Hit.Position + Vector3.new(0, selectedPart.Size.Y / 2, 0)
        selectedPart.Position = novaPosicao
        registrarAcao("Posicao", selectedPart, posicaoAntiga, novaPosicao)
        
        isMovingMode = false
        btnMove.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        btnMove.Text = "🖱️ Mover (Clique no Mapa)"
        return
    end

    -- Seleção Padrão
    if mouse.Target and mouse.Target:IsDescendantOf(blocksFolder) then
        selecionar(mouse.Target)
    end
end)

-- ==========================================
-- 6. AÇÕES DOS BOTÕES DA INTERFACE
-- ==========================================

btnClose.MouseButton1Click:Connect(function()
    if ghostPart then ghostPart:Destroy() end
    handles:Destroy()
    screenGui:Destroy()
end)

local minimizado = false
btnMinimize.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 220, 0, 35)
        btnMinimize.Text = "+"
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 220, 0, 430)
        btnMinimize.Text = "-"
    end
end)

-- CRIAR BLOCO FANTASMA (PREVIEW)
btnSpawn.MouseButton1Click:Connect(function()
    selecionar(nil)

    ghostPart = Instance.new("Part")
    ghostPart.Size = Vector3.new(4, 4, 4)
    ghostPart.Transparency = 0.4 -- Alterado para 0.4 (Fica um pouco visível, mais nítido)
    ghostPart.Color = Color3.fromRGB(0, 255, 100) -- Cor verde neon marcante
    ghostPart.Anchored = true
    ghostPart.CanCollide = false
    ghostPart.Parent = workspace

    btnConfirmOK.Visible = true -- Mostra o botão OK dentro da interface

    ghostConnection = runService.RenderStepped:Connect(function()
        if ghostPart then
            ghostPart.Position = mouse.Hit.Position + Vector3.new(0, ghostPart.Size.Y / 2, 0)
        end
    end)
end)

-- CONFIRMAR CRIAÇÃO DO BLOCO (BOTÃO OK INTERNO)
btnConfirmOK.MouseButton1Click:Connect(function()
    if ghostPart then
        if ghostConnection then ghostConnection:Disconnect() end
        
        local blocoReal = ghostPart
        ghostPart = nil
        blocoReal.Transparency = 0
        blocoReal.CanCollide = true
        blocoReal.BrickColor = BrickColor.Random()
        blocoReal.Parent = blocksFolder
        
        btnConfirmOK.Visible = false -- Esconde o botão após confirmar
        registrarAcao("Criar", blocoReal, nil, nil)
        selecionar(blocoReal)
    end
end)

-- ATIVAR MODO DE MOVER
btnMove.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    isMovingMode = not isMovingMode
    if isMovingMode then
        btnMove.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        btnMove.Text = "📍 Clique num local!"
    else
        btnMove.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        btnMove.Text = "🖱️ Mover (Clique no Mapa)"
    end
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
    selectedPart.Parent = nil
    registrarAcao("Deletar", selectedPart, nil, nil)
    selecionar(nil)
end)

-- MUDAR COR
btnColor.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local corAntiga = selectedPart.Color
    selectedPart.BrickColor = BrickColor.Random()
    registrarAcao("Cor", selectedPart, corAntiga, selectedPart.Color)
end)

-- ESTICAR E ENCOLHER (GLOBAL CONTÍNUO)
btnStretch.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    selectedPart.Size = selectedPart.Size + Vector3.new(2, 2, 2)
    registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
end)

btnShrink.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    local novoTamanho = selectedPart.Size - Vector3.new(2, 2, 2)
    if novoTamanho.X > 0.5 and novoTamanho.Y > 0.5 and novoTamanho.Z > 0.5 then
        selectedPart.Size = novoTamanho
        registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
    end
end)

-- ==========================================
-- 7. LÓGICA DO DESFAZER E REFAZER
-- ==========================================
btnUndo.MouseButton1Click:Connect(function()
    if #undoStack == 0 then return end
    local acao = table.remove(undoStack, #undoStack)
    table.insert(redoStack, acao)

    if acao.tipo == "Criar" then
        acao.part.Parent = nil
        if selectedPart == acao.part then selecionar(nil) end
    elseif acao.tipo == "Deletar" then
        acao.part.Parent = blocksFolder
    elseif acao.tipo == "Cor" then
        acao.part.Color = acao.oldData
    elseif acao.tipo == "Tamanho" then
        acao.part.Size = acao.oldData
    elseif acao.tipo == "Posicao" then
        acao.part.Position = acao.oldData
    elseif acao.tipo == "Transform" then
        acao.part.Size = acao.oldData.Size
        acao.part.CFrame = acao.oldData.CFrame
    end
end)

btnRedo.MouseButton1Click:Connect(function()
    if #redoStack == 0 then return end
    local acao = table.remove(redoStack, #redoStack)
    table.insert(undoStack, acao)

    if acao.tipo == "Criar" then
        acao.part.Parent = blocksFolder
    elseif acao.tipo == "Deletar" then
        acao.part.Parent = nil
        if selectedPart == acao.part then selecionar(nil) end
    elseif acao.tipo == "Cor" then
        acao.part.Color = acao.newData
    elseif acao.tipo == "Tamanho" then
        acao.part.Size = acao.newData
    elseif acao.tipo == "Posicao" then
        acao.part.Position = acao.newData
    elseif acao.tipo == "Transform" then
        acao.part.Size = acao.newData.Size
        acao.part.CFrame = acao.newData.CFrame
    end
end)
