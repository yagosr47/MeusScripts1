-- ==========================================
-- SCRIPT DE CÂMERA DRONE (FREECAM)
-- Navegação suave pelo mapa
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local isFreecam = false
local speed = 50
local sensitivity = 0.2

-- Variáveis de controle
local move = Vector3.new()
local look = Vector2.new()

-- Criar a interface de controle
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.9, -60)
button.Text = "Ativar Drone"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)

local function toggleFreecam()
    isFreecam = not isFreecam
    if isFreecam then
        camera.CameraType = Enum.CameraType.Scriptable
        button.Text = "Drone: ATIVADO"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        button.Text = "Ativar Drone"
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end

button.MouseButton1Click:Connect(toggleFreecam)

-- Entradas de teclado
userInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.W then move = move + Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then move = move + Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then move = move + Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then move = move + Vector3.new(1, 0, 0) end
end)

userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then move = move - Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then move = move - Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then move = move - Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then move = move - Vector3.new(1, 0, 0) end
end)

-- Loop de atualização da câmera
runService.RenderStepped:Connect(function(deltaTime)
    if isFreecam then
        -- Movimento da câmera
        local cf = camera.CFrame
        local newCf = cf * CFrame.new(move * speed * deltaTime)
        
        -- Rotação simples com o mouse (pode ser expandida)
        camera.CFrame = newCf
        
        -- Esconder mouse para rotacionar
        userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)
