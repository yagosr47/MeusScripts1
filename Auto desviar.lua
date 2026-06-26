local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local DISTANCIA_SEGURA = 15

-- Variáveis de Controle
local autoDodgeEnabled = false
local isMinimized = false
local dodgeConnection = nil

---------------------------------------------------------
-- 1. CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoDodgeGUI"
screenGui.ResetOnSpawn = false
-- Se estiver testando no Studio, coloca no PlayerGui. 
screenGui.Parent = localPlayer:WaitForChild("PlayerGui") 

-- Janela Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Barra Superior (Title Bar)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = topBar

-- Ajuste para a barra superior ficar reta embaixo
local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Sistema Evasão"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Botão Minimizar
local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 30, 0, 30)
minButton.Position = UDim2.new(1, -60, 0, 0)
minButton.BackgroundTransparency = 1
minButton.Text = "-"
minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minButton.Font = Enum.Font.GothamBold
minButton.TextSize = 18
minButton.Parent = topBar

-- Botão Fechar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = topBar

-- Botão de Ativar/Desativar (Toggle)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 40)
toggleButton.Position = UDim2.new(0.5, -75, 0.5, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho inicial
toggleButton.Text = "DESATIVADO"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

---------------------------------------------------------
-- 2. LÓGICA DE MOVIMENTAÇÃO DA JANELA (DRAG)
---------------------------------------------------------
local dragging, dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

---------------------------------------------------------
-- 3. LÓGICA DA INTERFACE (BOTÕES)
---------------------------------------------------------

-- Função do Botão Minimizar
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 30), "Out", "Quad", 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 150), "Out", "Quad", 0.2, true)
    end
end)

-- Função do Botão Fechar
closeButton.MouseButton1Click:Connect(function()
    autoDodgeEnabled = false
    if dodgeConnection then
        dodgeConnection:Disconnect()
    end
    screenGui:Destroy()
end)

-- Função do Botão Toggle
toggleButton.MouseButton1Click:Connect(function()
    autoDodgeEnabled = not autoDodgeEnabled
    
    if autoDodgeEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde
        toggleButton.Text = "ATIVADO"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho
        toggleButton.Text = "DESATIVADO"
    end
end)

---------------------------------------------------------
-- 4. LÓGICA DO AUTO-DODGE
---------------------------------------------------------
dodgeConnection = RunService.Heartbeat:Connect(function()
    if not autoDodgeEnabled then return end
    
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then 
        return 
    end
    
    local myRoot = character.HumanoidRootPart
    local humanoid = character.Humanoid
    
    local nearestPlayer = nil
    local shortestDistance = DISTANCIA_SEGURA
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    if nearestPlayer then
        local targetRoot = nearestPlayer.Character.HumanoidRootPart
        local directionAway = (myRoot.Position - targetRoot.Position).Unit
        
        -- Garante que o personagem não tente subir ou descer no eixo Y
        local fleeVector = Vector3.new(directionAway.X, 0, directionAway.Z)
        
        -- Evita falhas matemáticas caso os dois jogadores estejam na exata mesma coordenada
        if fleeVector.Magnitude > 0 then
            local safePosition = myRoot.Position + (fleeVector.Unit * DISTANCIA_SEGURA)
            humanoid:MoveTo(safePosition)
        end
    end
end)
