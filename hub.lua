-- ==========================================
-- Hub Universal V3 - PREMIUM
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações de Estado
local voando = false
local espAtivado = false
local velocidadeVoo = 50
local minimizado = false

-- 1. Interface Base (Design Moderno)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubPremiumV3"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Parent = mainFrame

-- Barra de Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB PREMIUM V3"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Botão Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Botão Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Container dos Botões
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

-- Função para criar botões estilizados
local function criarBotaoMenu(texto, cor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- Botões de Funcionalidade
local btnFly = criarBotaoMenu("Ativar Voo (Fly)", Color3.fromRGB(0, 100, 200))
local btnEsp = criarBotaoMenu("Ativar ESP (Nomes)", Color3.fromRGB(0, 150, 100))
local btnSpec = criarBotaoMenu("Espionar Próximo")
local btnUnspec = criarBotaoMenu("Parar Espionagem", Color3.fromRGB(100, 50, 50))
local btnSpeed = criarBotaoMenu("Super Velocidade (x5)")

-- ==========================================
-- LÓGICA DO HUB
-- ==========================================

-- Fechar e Minimizar
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 35), "Out", "Quad", 0.3, true)
        content.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 380), "Out", "Quad", 0.3, true)
        content.Visible = true
    end
end)

-- Sistema de Voo (Fly)
btnFly.MouseButton1Click:Connect(function()
    voando = not voando
    btnFly.Text = voando and "Voo: ATIVADO" or "Ativar Voo (Fly)"
    
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if voando then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "VooVel"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "VooGiro"
        bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9000
        bg.CFrame = hrp.CFrame
        
        task.spawn(function()
            while voando do
                RunService.RenderStepped:Wait()
                local cam = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0,0,0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                
                bv.Velocity = moveDir * velocidadeVoo
                bg.CFrame = cam
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end)

-- Sistema de ESP (Ver Nomes através das paredes)
local function criarESP(p)
    if p == player then return end
    p.CharacterAdded:Connect(function(char)
        local head = char:WaitForChild("Head")
        local bgui = Instance.new("BillboardGui", head)
        bgui.Name = "ESPTag"
        bgui.Size = UDim2.new(0, 200, 0, 50)
        bgui.AlwaysOnTop = true
        bgui.Adornee = head
        bgui.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local txt = Instance.new("TextLabel", bgui)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = p.Name
        txt.TextColor3 = Color3.fromRGB(0, 255, 255)
        txt.TextStrokeTransparency = 0
        txt.TextSize = 14
        txt.Font = Enum.Font.GothamBold
    end)
end

btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnEsp.Text = espAtivado and "ESP: ATIVADO" or "Ativar ESP (Nomes)"
    
    if espAtivado then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("ESPTag") then
                    local bgui = Instance.new("BillboardGui", head)
                    bgui.Name = "ESPTag"
                    bgui.Size = UDim2.new(0, 200, 0, 50)
                    bgui.AlwaysOnTop = true
                    bgui.ExtentsOffset = Vector3.new(0, 3, 0)
                    local txt = Instance.new("TextLabel", bgui)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = p.Name
                    txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                    txt.TextStrokeTransparency = 0
                    txt.TextSize = 14
                    txt.Font = Enum.Font.GothamBold
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local tag = p.Character.Head:FindFirstChild("ESPTag")
                if tag then tag:Destroy() end
            end
        end
    end
end)

-- Sistema de Espionagem (Câmera)
local indexSpec = 1
btnSpec.MouseButton1Click:Connect(function()
    local todos = Players:GetPlayers()
    indexSpec = indexSpec + 1
    if indexSpec > #todos then indexSpec = 1 end
    local alvo = todos[indexSpec]
    if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid
        btnSpec.Text = "Espiando: " .. alvo.Name
    end
end)

btnUnspec.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        btnSpec.Text = "Espionar Próximo"
    end
end)

-- (Super Velocidade)
btnSpeed.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 80
    end
end)
