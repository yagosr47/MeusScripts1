-- ==========================================
-- Hub Universal Básico para Roblox
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 1. Criação da Interface (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubUniversal"
screenGui.ResetOnSpawn = false -- Impede que o menu feche quando você morre

-- Tenta colocar no CoreGui (oculta a UI de sistemas anti-cheat comuns do jogo)
-- Se falhar (ex: rodando no Studio sem permissão), vai para o PlayerGui
local success, err = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 2. Criação do Painel Principal (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Painel"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Permite arrastar o painel pela tela
mainFrame.Parent = screenGui

-- 3. Título do Hub
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.Code
title.Text = "Hub Universal"
title.Parent = mainFrame

-- 4. Botão 1: Aumentar Velocidade (WalkSpeed)
local btnSpeed = Instance.new("TextButton")
btnSpeed.Size = UDim2.new(0.8, 0, 0, 35)
btnSpeed.Position = UDim2.new(0.1, 0, 0.35, 0)
btnSpeed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeed.Font = Enum.Font.Code
btnSpeed.TextSize = 14
btnSpeed.Text = "Velocidade Rápida"
btnSpeed.Parent = mainFrame

-- 5. Botão 2: Super Pulo (JumpPower)
local btnJump = Instance.new("TextButton")
btnJump.Size = UDim2.new(0.8, 0, 0, 35)
btnJump.Position = UDim2.new(0.1, 0, 0.65, 0)
btnJump.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnJump.TextColor3 = Color3.fromRGB(255, 255, 255)
btnJump.Font = Enum.Font.Code
btnJump.TextSize = 14
btnJump.Text = "Super Pulo"
btnJump.Parent = mainFrame

-- ==========================================
-- Lógica dos Botões
-- ==========================================

-- Função para alterar a velocidade
btnSpeed.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 50 -- Velocidade normal do Roblox é 16
    end
end)

-- Função para alterar o pulo
btnJump.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 100 -- Pulo normal do Roblox é 50
    end
end)
