-- ==========================================
-- Hub Universal V2 - Interface Moderna
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 1. Criação da Interface Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubV2"
screenGui.ResetOnSpawn = false

local success, err = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- 2. Painel Principal com Bordas Arredondadas
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 280)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- 3. Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Text = "Hub Universal V2"
title.Parent = mainFrame

-- 4. Função Auxiliar para Criar Botões
local function criarBotao(texto, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Text = texto
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

-- 5. Função Auxiliar para Criar Caixas de Texto (Inputs de 1 a 10)
local function criarInput(texto, posY)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.25, 0, 0, 35)
    box.Position = UDim2.new(0.7, 0, posY, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(0, 255, 100)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.Text = texto
    box.Parent = mainFrame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    return box
end

-- Elementos da UI
local btnSpeed = criarBotao("Aplicar Velocidade", 0.2)
local inputSpeed = criarInput("1", 0.2)

local btnJump = criarBotao("Aplicar Pulo", 0.35)
local inputJump = criarInput("1", 0.35)

local btnSpectate = criarBotao("Espionar Próximo", 0.5)
local btnUnspectate = criarBotao("Parar Espionagem", 0.65)
btnUnspectate.Size = UDim2.new(0.9, 0, 0, 35)
btnUnspectate.Position = UDim2.new(0.05, 0, 0.65, 0)
btnUnspectate.BackgroundColor3 = Color3.fromRGB(150, 40, 40)

-- ==========================================
-- Lógica dos Sistemas
-- ==========================================

-- Lógica de Velocidade (Multiplicador de 1 a 10)
btnSpeed.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local valor = tonumber(inputSpeed.Text) or 1
        valor = math.clamp(valor, 1, 10) -- Garante que fique entre 1 e 10
        inputSpeed.Text = tostring(valor)
        char.Humanoid.WalkSpeed = 16 * valor -- 16 é o padrão, vezes o multiplicador
    end
end)

-- Lógica de Pulo (Multiplicador de 1 a 10)
btnJump.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local valor = tonumber(inputJump.Text) or 1
        valor = math.clamp(valor, 1, 10)
        inputJump.Text = tostring(valor)
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = 50 * valor -- 50 é o padrão, vezes o multiplicador
    end
end)

-- Lógica de Espionar (Spectate)
local spectateIndex = 1
btnSpectate.MouseButton1Click:Connect(function()
    local listaJogadores = Players:GetPlayers()
    spectateIndex = spectateIndex + 1
    if spectateIndex > #listaJogadores then spectateIndex = 1 end
    
    local alvo = listaJogadores[spectateIndex]
    if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid
        btnSpectate.Text = "Espiando: " .. alvo.Name
    end
end)

btnUnspectate.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        btnSpectate.Text = "Espionar Próximo"
    end
end)
