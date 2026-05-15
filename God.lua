-- ==========================================
-- SCRIPT DE GOD MODE / ASTRAL PROJECTION
-- Para uso em Executores (Client-Side)
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") -- Usa o CoreGui para o anti-cheat do jogo não deletar a interface

-- Evita duplicar a interface se executar duas vezes
if CoreGui:FindFirstChild("GodModeMenu") then
    CoreGui.GodModeMenu:Destroy()
end

-- ==========================================
-- 1. CRIANDO A INTERFACE (MOD MENU)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodModeMenu"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.5, -100, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true -- Permite arrastar a interface pela tela
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Menu Mod"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
toggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleButton.Text = "God Mode: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = frame

-- ==========================================
-- 2. LÓGICA DO GOD MODE (FANTASMA + TELEPORTE)
-- ==========================================
local isGodMode = false
local realChar = nil
local ghostChar = nil
local noclipConnection = nil

local function toggleGodMode(state)
    local workspace = game:GetService("Workspace")
    local camera = workspace.CurrentCamera

    if state then
        -- ATIVAR
        realChar = player.Character
        if not realChar then return end
        
        realChar.Archivable = true
        ghostChar = realChar:Clone()
        ghostChar.Name = "Ghost_Clone"
        ghostChar.Parent = workspace
        
        -- Deixa o clone com visual de fantasma (Somentente você vê)
        for _, part in ipairs(ghostChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.Material = Enum.Material.ForceField
            end
        end
        
        -- Congela o corpo real (Para os outros, você parou aqui)
        local realRoot = realChar:FindFirstChild("HumanoidRootPart")
        if realRoot then 
            realRoot.Anchored = true 
        end
        
        -- Esconde o corpo real da sua tela
        for _, part in ipairs(realChar:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end

        -- Passa o controle do seu teclado/câmera para o fantasma
        player.Character = ghostChar
        camera.CameraSubject = ghostChar:FindFirstChild("Humanoid")
        
        -- Ativa o Noclip (Atravessar paredes) apenas para o fantasma
        noclipConnection = RunService.Stepped:Connect(function()
            if ghostChar then
                for _, part in ipairs(ghostChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

    else
        -- DESATIVAR
        if noclipConnection then 
            noclipConnection:Disconnect() 
            noclipConnection = nil
        end
        
        if realChar and ghostChar then
            local ghostRoot = ghostChar:FindFirstChild("HumanoidRootPart")
            local realRoot = realChar:FindFirstChild("HumanoidRootPart")
            
            if ghostRoot and realRoot then
                -- O grande truque: Teleporta o corpo real (invisível/parado) 
                -- para onde o fantasma foi parar.
                realRoot.CFrame = ghostRoot.CFrame
            end
            
            -- Descongela e revela o corpo real
            if realRoot then 
                realRoot.Anchored = false 
            end
            
            for _, part in ipairs(realChar:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0 
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
            
            -- Devolve o controle para o corpo real
            player.Character = realChar
            camera.CameraSubject = realChar:FindFirstChild("Humanoid")
            
            -- Destrói o fantasma
            ghostChar:Destroy()
        end
        ghostChar = nil
    end
end

-- ==========================================
-- 3. EVENTO DO BOTÃO
-- ==========================================
toggleButton.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    
    if isGodMode then
        toggleButton.Text = "God Mode: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        toggleGodMode(true)
    else
        toggleButton.Text = "God Mode: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        toggleGodMode(false)
    end
end)
