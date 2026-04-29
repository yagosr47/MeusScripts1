-- Serviços necessários
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Criação da GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModHubInterface"
ScreenGui.ResetOnSpawn = false

-- Se estiver usando em um jogo comum, vai para o PlayerGui.
-- Se for um script de executor, mude para CoreGui.
if game:GetService("RunService"):IsStudio() then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
else
    -- Tentativa de proteção básica caso seja rodado via exploit
    local success, err = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
    end
end

-- Frame Principal (Janela Escura)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Borda arredondada
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título do Hub
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleLabel.Text = "  Mod Menu Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Esconde as pontas inferiores do arredondamento do título para conectar com o corpo
local TitleBlocker = Instance.new("Frame")
TitleBlocker.Size = UDim2.new(1, 0, 0, 10)
TitleBlocker.Position = UDim2.new(0, 0, 1, -10)
TitleBlocker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBlocker.BorderSizePixel = 0
TitleBlocker.Parent = TitleLabel

-- Container da Lista de Mods
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

-- Organizador automático em lista
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

-- ==========================================
-- FUNÇÃO CONSTRUTORA DE TOGGLES (MODS)
-- ==========================================
local function CreateModToggle(name, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 24)
    ToggleButton.Position = UDim2.new(1, -75, 0.5, -12)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    ToggleButton.Text = defaultState and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = ToggleButton

    local isOn = defaultState

    -- Evento de Clique
    ToggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        
        -- Animação simples de cor
        ToggleButton.Text = isOn and "ON" or "OFF"
        ToggleButton.BackgroundColor3 = isOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        
        -- Executa a função associada ao Mod
        callback(isOn)
    end)
    
    -- Ajusta o tamanho do scroll de acordo com a quantidade de itens
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- ==========================================
-- ADICIONANDO OS MODS AO HUB
-- ==========================================

CreateModToggle("Auto Farm", false, function(state)
    if state then
        print("Iniciando rotina de Auto Farm...")
        -- Coloque seu código de loop/farm aqui
    else
        print("Auto Farm interrompido.")
        -- Coloque o código para parar o loop aqui
    end
end)

CreateModToggle("Kill Aura", false, function(state)
    if state then
        print("Kill Aura ativada!")
        -- Coloque seu código de dano em área aqui
    else
        print("Kill Aura desativada.")
    end
end)

CreateModToggle("ESP de Minérios", false, function(state)
    if state then
        print("ESP de Minérios ligado. Criando Highlights...")
        -- Exemplo: Procure por objetos na Workspace e adicione um 'Highlight'
    else
        print("ESP de Minérios desligado. Limpando...")
        -- Remova os Highlights criados
    end
end)

-- ==========================================
-- SISTEMA DE ARRASTAR (DRAG) CUSTOMIZADO
-- ==========================================
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    -- Movimenta o frame principal de forma suave
    game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.05), {
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    }):Play()
end

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ==========================================
-- TECLA PARA ESCONDER/MOSTRAR MENU (INSERT)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Hub carregado com sucesso. Pressione 'Insert' para abrir/fechar.")
