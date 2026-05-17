-- ==========================================
-- CONSTRUTOR AVANÇADO + BARRA SUPERIOR + MOVER + ESTICAR + BLOCO FANTASMA
-- Criação, Edição, Mover, Esticar, Desfazer, Refazer, Minimizar e Fechar
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Garantir compatibilidade com executores de celular
local targetGui
if type(gethui) == "function" then
    targetGui = gethui()
else
    local success, _ = pcall(function() return CoreGui.Name end)
    targetGui = success and CoreGui or player:WaitForChild("PlayerGui")
end

if targetGui:FindFirstChild("BuilderGUI") then
    targetGui.BuilderGUI:Destroy()
end

-- Pasta para guardar os blocos criados e as alavancas (handles)
local blocksFolder = workspace:FindFirstChild("LocalBuildingBlocks")
if not blocksFolder then
    blocksFolder = Instance.new("Folder")
    blocksFolder.Name = "LocalBuildingBlocks"
    blocksFolder.Parent = workspace
end

local handlesFolder = blocksFolder:FindFirstChild("Handles")
if not handlesFolder then
    handlesFolder = Instance.new("Folder")
    handlesFolder.Name = "Handles"
    handlesFolder.Parent = blocksFolder
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

-- Container Principal (Alargado para 260 para caber os botões OK e Cancelar)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 430)
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
title.Size = UDim2.new(0, 70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🛠️ Build"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- BOTÃO CONFIRMAR CRIAÇÃO (OK)
local btnConfirmSpawn = Instance.new("TextButton")
btnConfirmSpawn.Size = UDim2.new(0, 45, 0, 25)
btnConfirmSpawn.Position = UDim2.new(0, 80, 0, 5)
btnConfirmSpawn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
btnConfirmSpawn.Text = "✔️"
btnConfirmSpawn.TextColor3 = Color3.fromRGB(255, 255, 255)
btnConfirmSpawn.Font = Enum.Font.GothamBold
btnConfirmSpawn.TextSize = 14
btnConfirmSpawn.Visible = false
Instance.new("UICorner", btnConfirmSpawn).CornerRadius = UDim.new(0, 4)
btnConfirmSpawn.Parent = topBar

-- BOTÃO CANCELAR CRIAÇÃO
local btnCancelSpawn = Instance.new("TextButton")
btnCancelSpawn.Size = UDim2.new(0, 45, 0, 25)
btnCancelSpawn.Position = UDim2.new(0, 130, 0, 5)
btnCancelSpawn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnCancelSpawn.Text = "❌"
btnCancelSpawn.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCancelSpawn.Font = Enum.Font.GothamBold
btnCancelSpawn.TextSize = 14
btnCancelSpawn.Visible = false
Instance.new("UICorner", btnCancelSpawn).CornerRadius = UDim.new(0, 4)
btnCancelSpawn.Parent = topBar

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

-- BOTÕES
local btnSpawn = criarBotao("➕ Criar Bloco", Color3.fromRGB(0, 150, 200))
local btnMove = criarBotao("🖱️ Mover (Clique no Mapa)", Color3.fromRGB(200, 150, 0))
local btnDuplicate = criarBotao("📑 Duplicar", Color3.fromRGB(50, 100, 200))
local btnStretch = criarBotao("↕️ Esticar Tudo (Aumentar)", Color3.fromRGB(200, 100, 50))
local btnShrink = criarBotao("↔️ Encolher Tudo (Diminuir)", Color3.fromRGB(200, 150, 50))
local btnColor = criarBotao("🎨 Mudar Cor", Color3.fromRGB(150, 50, 200))
local btnDelete = criarBotao("🗑️ Deletar", Color3.fromRGB(200, 50, 50))

local espaco = Instance.new("Frame", contentFrame)
espaco.Size = UDim2.new(1, 0, 0, 10)
espaco.BackgroundTransparency = 1

local btnUndo = criarBotao("↩️ Desfazer", Color3.fromRGB(100, 100, 100))
local btnRedo = criarBotao("↪️ Refazer", Color3.fromRGB(100, 100, 100))

-- ==========================================
-- VARIÁVEIS DO BLOCO FANTASMA
-- ==========================================
local ghostBlock = nil
local draggingGhost = false

-- ==========================================
-- 3. AÇÕES DA BARRA SUPERIOR
-- ==========================================
btnClose.MouseButton1Click:Connect(function()
    -- Ao fechar, se houver um bloco fantasma solto, ele é deletado
    if ghostBlock then
        ghostBlock:Destroy()
        ghostBlock = nil
    end
    
    handlesFolder:ClearAllChildren()
    screenGui:Destroy()
end)

local minimizado = false
btnMinimize.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 260, 0, 35)
        btnMinimize.Text = "+"
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 260, 0, 430)
        btnMinimize.Text = "-"
    end
end)

-- ==========================================
-- 4. LÓGICA DAS BOLAS DE ESTICAR (HANDLES)
-- ==========================================
local function updateHandlesPositions(part)
    if not part then return end
    for _, handle in ipairs(handlesFolder:GetChildren()) do
        local axis = Vector3.new(handle:GetAttribute("AxisX"), handle:GetAttribute("AxisY"), handle:GetAttribute("AxisZ"))
        local absAxis = Vector3.new(math.abs(axis.X), math.abs(axis.Y), math.abs(axis.Z))
        handle.Position = part.Position + (axis * ((part.Size * absAxis) / 2 + Vector3.new(0.5, 0.5, 0.5)))
    end
end

local function createHandles(part)
    handlesFolder:ClearAllChildren()
    if not part then return end

    local directions = {
        {name = "Top", axis = Vector3.new(0,1,0), color = Color3.fromRGB(0, 255, 0)},
        {name = "Bottom", axis = Vector3.new(0,-1,0), color = Color3.fromRGB(0, 150, 0)},
        {name = "Right", axis = Vector3.new(1,0,0), color = Color3.fromRGB(255, 0, 0)},
        {name = "Left", axis = Vector3.new(-1,0,0), color = Color3.fromRGB(150, 0, 0)},
        {name = "Front", axis = Vector3.new(0,0,1), color = Color3.fromRGB(0, 0, 255)},
        {name = "Back", axis = Vector3.new(0,0,-1), color = Color3.fromRGB(0, 0, 150)}
    }

    for _, d in ipairs(directions) do
        local handle = Instance.new("Part")
        handle.Shape = Enum.PartType.Ball
        handle.Size = Vector3.new(1.2, 1.2, 1.2)
        handle.Color = d.color
        handle.Material = Enum.Material.Neon
        handle.Anchored = true
        handle.CanCollide = false
        handle.CastShadow = false
        handle.Name = d.name
        
        handle:SetAttribute("AxisX", d.axis.X)
        handle:SetAttribute("AxisY", d.axis.Y)
        handle:SetAttribute("AxisZ", d.axis.Z)
        handle.Parent = handlesFolder
    end
    updateHandlesPositions(part)
end

-- ==========================================
-- 5. LÓGICA DE SELEÇÃO E DESTAQUE
-- ==========================================
local selectedPart = nil
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
local isMovingMode = false

local function selecionar(part)
    selectedPart = part
    if part then
        selectionText.Text = "Selecionado: Bloco"
        highlight.Parent = part
        createHandles(part)
    else
        selectionText.Text = "Selecionado: Nenhum"
        highlight.Parent = nil
        handlesFolder:ClearAllChildren()
        
        isMovingMode = false
        btnMove.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        btnMove.Text = "🖱️ Mover (Clique no Mapa)"
    end
end

-- ==========================================
-- 6. LÓGICA DO MOUSE (CLICAR, MOVER E ARRASTAR BOLAS)
-- ==========================================
local draggingHandleMode = false
local dragHandle = nil
local dragStartSize = nil
local dragStartCFrame = nil
local dragStartMousePos = nil

mouse.Button1Down:Connect(function()
    -- Se clicou numa bola de esticar
    if mouse.Target and mouse.Target.Parent == handlesFolder then
        draggingHandleMode = true
        dragHandle = mouse.Target
        dragStartSize = selectedPart.Size
        dragStartCFrame = selectedPart.CFrame
        dragStartMousePos = mouse.Hit.Position
        return
    end

    -- Se o bloco fantasma estiver ativo, permite arrastá-lo
    if ghostBlock then
        draggingGhost = true
        ghostBlock.Position = mouse.Hit.Position + Vector3.new(0, ghostBlock.Size.Y / 2, 0)
        return
    end

    -- Modo Mover normal
    if isMovingMode and selectedPart then
        local posicaoAntiga = selectedPart.Position
        local novaPosicao = mouse.Hit.Position + Vector3.new(0, selectedPart.Size.Y / 2, 0)
        selectedPart.Position = novaPosicao
        updateHandlesPositions(selectedPart)
        
        registrarAcao("Posicao", selectedPart, posicaoAntiga, novaPosicao)
        
        isMovingMode = false
        btnMove.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        btnMove.Text = "🖱️ Mover (Clique no Mapa)"
        return
    end

    -- Sistema de Seleção Normal
    if mouse.Target and mouse.Target:IsDescendantOf(blocksFolder) and mouse.Target.Parent ~= handlesFolder then
        selecionar(mouse.Target)
    end
end)

mouse.Move:Connect(function()
    -- Arrastar o bloco fantasma pela tela
    if draggingGhost and ghostBlock then
        ghostBlock.Position = mouse.Hit.Position + Vector3.new(0, ghostBlock.Size.Y / 2, 0)
    end

    -- Lógica de puxar as bolas para redimensionar em uma direção
    if draggingHandleMode and dragHandle and selectedPart then
        local axis = Vector3.new(dragHandle:GetAttribute("AxisX"), dragHandle:GetAttribute("AxisY"), dragHandle:GetAttribute("AxisZ"))
        local absAxis = Vector3.new(math.abs(axis.X), math.abs(axis.Y), math.abs(axis.Z))
        
        local currentMousePos = mouse.Hit.Position
        local deltaPos = currentMousePos - dragStartMousePos
        local deltaMove = deltaPos:Dot(axis) * 2
        
        local newSize = dragStartSize + (absAxis * deltaMove)
        
        if newSize.X < 0.5 then newSize = Vector3.new(0.5, newSize.Y, newSize.Z) deltaMove = (0.5 - dragStartSize.X) end
        if newSize.Y < 0.5 then newSize = Vector3.new(newSize.X, 0.5, newSize.Z) deltaMove = (0.5 - dragStartSize.Y) end
        if newSize.Z < 0.5 then newSize = Vector3.new(newSize.X, newSize.Y, 0.5) deltaMove = (0.5 - dragStartSize.Z) end

        selectedPart.Size = newSize
        selectedPart.CFrame = dragStartCFrame * CFrame.new(axis * (deltaMove / 4))
        updateHandlesPositions(selectedPart)
    end
end)

mouse.Button1Up:Connect(function()
    draggingGhost = false

    if draggingHandleMode then
        if selectedPart and dragStartSize and selectedPart.Size ~= dragStartSize then
            registrarAcao("TamanhoPosicao", selectedPart, {Size = dragStartSize, CFrame = dragStartCFrame}, {Size = selectedPart.Size, CFrame = selectedPart.CFrame})
        end
        draggingHandleMode = false
        dragHandle = nil
    end
end)

-- ==========================================
-- 7. AÇÕES DAS FERRAMENTAS
-- ==========================================

-- CRIAR BLOCO (FANTASMA E CONFIRMAÇÃO)
btnSpawn.MouseButton1Click:Connect(function()
    if ghostBlock then return end -- Impede criar vários fantasmas
    
    ghostBlock = Instance.new("Part")
    ghostBlock.Size = Vector3.new(4, 4, 4)
    ghostBlock.Transparency = 0.5
    ghostBlock.CanCollide = false
    ghostBlock.Anchored = true
    ghostBlock.Color = Color3.fromRGB(0, 255, 0)
    ghostBlock.Material = Enum.Material.ForceField
    ghostBlock.Parent = blocksFolder

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        ghostBlock.Position = char.HumanoidRootPart.Position + (char.HumanoidRootPart.CFrame.LookVector * 10)
    end

    btnConfirmSpawn.Visible = true
    btnCancelSpawn.Visible = true
    selecionar(nil) -- Tira a seleção de outros blocos enquanto cria
end)

-- CANCELAR BLOCO FANTASMA
btnCancelSpawn.MouseButton1Click:Connect(function()
    if ghostBlock then
        ghostBlock:Destroy()
        ghostBlock = nil
    end
    btnConfirmSpawn.Visible = false
    btnCancelSpawn.Visible = false
end)

-- CONFIRMAR BLOCO FANTASMA
btnConfirmSpawn.MouseButton1Click:Connect(function()
    if not ghostBlock then return end

    -- Torna físico
    ghostBlock.Transparency = 0
    ghostBlock.CanCollide = true
    ghostBlock.Material = Enum.Material.Plastic
    ghostBlock.BrickColor = BrickColor.Random()
    
    local novoBloco = ghostBlock
    ghostBlock = nil
    
    btnConfirmSpawn.Visible = false
    btnCancelSpawn.Visible = false

    registrarAcao("Criar", novoBloco, nil, nil)
    selecionar(novoBloco)
end)

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

btnDuplicate.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local clone = selectedPart:Clone()
    clone.Position = selectedPart.Position + Vector3.new(0, selectedPart.Size.Y, 0)
    clone.Parent = blocksFolder
    registrarAcao("Criar", clone, nil, nil)
    selecionar(clone)
end)

btnDelete.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    selectedPart.Parent = nil
    registrarAcao("Deletar", selectedPart, nil, nil)
    selecionar(nil)
end)

btnColor.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local corAntiga = selectedPart.Color
    selectedPart.BrickColor = BrickColor.Random()
    local corNova = selectedPart.Color
    registrarAcao("Cor", selectedPart, corAntiga, corNova)
end)

btnStretch.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    selectedPart.Size = selectedPart.Size + Vector3.new(2, 2, 2)
    updateHandlesPositions(selectedPart)
    registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
end)

btnShrink.MouseButton1Click:Connect(function()
    if not selectedPart then return end
    local tamanhoAntigo = selectedPart.Size
    local novoTamanho = selectedPart.Size - Vector3.new(2, 2, 2)
    if novoTamanho.X > 0.5 and novoTamanho.Y > 0.5 and novoTamanho.Z > 0.5 then
        selectedPart.Size = novoTamanho
        updateHandlesPositions(selectedPart)
        registrarAcao("Tamanho", selectedPart, tamanhoAntigo, selectedPart.Size)
    end
end)

-- ==========================================
-- 8. LÓGICA DO DESFAZER E REFAZER
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
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
    elseif acao.tipo == "Posicao" then
        acao.part.Position = acao.oldData
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
    elseif acao.tipo == "TamanhoPosicao" then
        acao.part.Size = acao.oldData.Size
        acao.part.CFrame = acao.oldData.CFrame
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
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
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
    elseif acao.tipo == "Posicao" then
        acao.part.Position = acao.newData
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
    elseif acao.tipo == "TamanhoPosicao" then
        acao.part.Size = acao.newData.Size
        acao.part.CFrame = acao.newData.CFrame
        if selectedPart == acao.part then updateHandlesPositions(selectedPart) end
    end
end)
