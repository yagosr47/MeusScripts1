-- ==========================================
-- SCRIPT DE CÂMERA DRONE PRO (FREECAM V2)
-- UI Avançada, ESP, Suporte a Analógico e Mobile
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Limpa a interface anterior se existir
if CoreGui:FindFirstChild("DroneUI") then
    CoreGui.DroneUI:Destroy()
end

-- ==========================================
-- VARIÁVEIS DE CONTROLE
-- ==========================================
local isFreecam = false
local speed = 50
local verticalMove = 0
local isZoomed = false
local espObjects = {}

-- Pega o módulo de controle nativo do Roblox (Lê Analógico Mobile e WASD PC)
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

-- ==========================================
-- INTERFACE (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DroneUI"
screenGui.Parent = CoreGui

-- Botão Principal de Ativação
local btnAtivar = Instance.new("TextButton")
btnAtivar.Size = UDim2.new(0, 160, 0, 45)
btnAtivar.Position = UDim2.new(0.5, -80, 0.9, -50)
btnAtivar.Text = "Ativar Drone"
btnAtivar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btnAtivar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAtivar.Font = Enum.Font.GothamBold
btnAtivar.TextSize = 14
local cornerMain = Instance.new("UICorner", btnAtivar)
cornerMain.CornerRadius = UDim.new(0, 8)
btnAtivar.Parent = screenGui

-- Painel de Controles (Aparece apenas quando ativado)
local controlPanel = Instance.new("Frame")
controlPanel.Size = UDim2.new(1, 0, 1, 0)
controlPanel.BackgroundTransparency = 1
controlPanel.Visible = false
controlPanel.Parent = screenGui

-- Controle de Velocidade (Topo)
local speedFrame = Instance.new("Frame", controlPanel)
speedFrame.Size = UDim2.new(0, 200, 0, 40)
speedFrame.Position = UDim2.new(0.5, -100, 0.05, 0)
speedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)

local btnMinus = Instance.new("TextButton", speedFrame)
btnMinus.Size = UDim2.new(0.25, 0, 1, 0)
btnMinus.Text = "-"
btnMinus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnMinus.TextColor3 = Color3.fromRGB(255,255,255)
btnMinus.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 8)

local speedText = Instance.new("TextLabel", speedFrame)
speedText.Size = UDim2.new(0.5, 0, 1, 0)
speedText.Position = UDim2.new(0.25, 0, 0, 0)
speedText.Text = "Vel: " .. speed
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.BackgroundTransparency = 1
speedText.Font = Enum.Font.GothamBold

local btnPlus = Instance.new("TextButton", speedFrame)
btnPlus.Size = UDim2.new(0.25, 0, 1, 0)
btnPlus.Position = UDim2.new(0.75, 0, 0, 0)
btnPlus.Text = "+"
btnPlus.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
btnPlus.TextColor3 = Color3.fromRGB(255,255,255)
btnPlus.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 8)

-- Botões de Subir e Descer (Direita)
local btnUp = Instance.new("TextButton", controlPanel)
btnUp.Size = UDim2.new(0, 60, 0, 60)
btnUp.Position = UDim2.new(0.9, -70, 0.5, -70)
btnUp.Text = "Subir\n(▲)"
btnUp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnUp.TextColor3 = Color3.fromRGB(255,255,255)
btnUp.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 30)

local btnDown = Instance.new("TextButton", controlPanel)
btnDown.Size = UDim2.new(0, 60, 0, 60)
btnDown.Position = UDim2.new(0.9, -70, 0.5, 10)
btnDown.Text = "Descer\n(▼)"
btnDown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnDown.TextColor3 = Color3.fromRGB(255,255,255)
btnDown.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 30)

-- Botão de Zoom (Esquerda)
local btnZoom = Instance.new("TextButton", controlPanel)
btnZoom.Size = UDim2.new(0, 60, 0, 60)
btnZoom.Position = UDim2.new(0.1, 10, 0.5, -30)
btnZoom.Text = "🔍 Zoom"
btnZoom.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnZoom.TextColor3 = Color3.fromRGB(255,255,255)
btnZoom.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnZoom).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- LÓGICA DE ESP (Distância)
-- ==========================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "DroneESP"

local function clearESP()
    espFolder:ClearAllChildren()
    espObjects = {}
end

local function updateESP()
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[target] then
                -- Cria o texto de ESP
                local billboard = Instance.new("BillboardGui", espFolder)
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                textLabel.TextStrokeTransparency = 0
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 14
                
                espObjects[target] = {billboard = billboard, label = textLabel}
            end
            
            local rootPart = target.Character.HumanoidRootPart
            local distance = math.floor((camera.CFrame.Position - rootPart.Position).Magnitude / 3) -- 3 Studs = aprox 1 metro
            
            espObjects[target].billboard.Adornee = rootPart
            espObjects[target].label.Text = target.Name .. "\n[" .. distance .. "m]"
        elseif espObjects[target] then
            espObjects[target].billboard:Destroy()
            espObjects[target] = nil
        end
    end
end

-- ==========================================
-- LÓGICA DE CONTROLES
-- ==========================================
btnMinus.MouseButton1Click:Connect(function()
    speed = math.max(10, speed - 10)
    speedText.Text = "Vel: " .. speed
end)

btnPlus.MouseButton1Click:Connect(function()
    speed = math.min(300, speed + 10)
    speedText.Text = "Vel: " .. speed
end)

btnZoom.MouseButton1Click:Connect(function()
    isZoomed = not isZoomed
    camera.FieldOfView = isZoomed and 30 or 70
    btnZoom.BackgroundColor3 = isZoomed and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 40)
end)

-- Usamos InputBegan/Ended para permitir segurar o botão enquanto arrasta o analógico
btnUp.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalMove = 1
        btnUp.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
btnUp.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalMove = 0
        btnUp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

btnDown.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalMove = -1
        btnDown.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
btnDown.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        verticalMove = 0
        btnDown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

-- Rotação da câmera arrastando a tela (Mouse Direito ou Touch)
local cameraAngleX = 0
local cameraAngleY = 0

UserInputService.InputChanged:Connect(function(input, processed)
    if isFreecam and not processed then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or input.UserInputType == Enum.UserInputType.Touch then
                cameraAngleX = cameraAngleX - input.Delta.X * 0.4
                cameraAngleY = math.clamp(cameraAngleY - input.Delta.Y * 0.4, -85, 85)
            end
        end
    end
end)

-- ==========================================
-- LOOP PRINCIPAL (MOVIMENTO E ATUALIZAÇÃO)
-- ==========================================
local function toggleFreecam()
    isFreecam = not isFreecam
    
    if isFreecam then
        btnAtivar.Text = "Desativar Drone"
        btnAtivar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        controlPanel.Visible = true
        camera.CameraType = Enum.CameraType.Scriptable
        
        -- Inicia a câmera na posição atual da cabeça
        local startCFrame = camera.CFrame
        local x, y, z = startCFrame:ToOrientation()
        cameraAngleX = math.deg(y)
        cameraAngleY = math.deg(x)
    else
        btnAtivar.Text = "Ativar Drone"
        btnAtivar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        controlPanel.Visible = false
        camera.CameraType = Enum.CameraType.Custom
        camera.FieldOfView = 70
        isZoomed = false
        btnZoom.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        if player.Character then
            camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        end
        clearESP()
    end
end

btnAtivar.MouseButton1Click:Connect(toggleFreecam)

RunService.RenderStepped:Connect(function(deltaTime)
    if isFreecam then
        -- Pega a direção do analógico do Roblox ou teclas WASD
        local moveVector = controls:GetMoveVector()
        
        -- Calcula a nova rotação da câmera (Arraste da tela)
        local camRotation = CFrame.Angles(0, math.rad(cameraAngleX), 0) * CFrame.Angles(math.rad(cameraAngleY), 0, 0)
        
        -- Combina Frente/Trás/Lados do analógico com Subir/Descer dos botões da UI
        local movement = Vector3.new(moveVector.X, verticalMove, -moveVector.Z)
        
        if movement.Magnitude > 0 then
            movement = movement.Unit
        end
        
        -- Aplica a velocidade e a rotação
        local newCFrame = camera.CFrame * CFrame.new(movement * speed * deltaTime)
        camera.CFrame = CFrame.new(newCFrame.Position) * camRotation
        
        -- Atualiza o ESP de jogadores
        updateESP()
    end
end)
