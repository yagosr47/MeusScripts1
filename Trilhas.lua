-- ==========================================
-- SCRIPT: GHOST TRAIL SYSTEM
-- Rastro de fantasma para visualização de caminho
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local isRecording = false
local ghostFolder = Instance.new("Folder", workspace)
ghostFolder.Name = "GhostPath_Folder"

-- Interface
local screenGui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.8, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.Text = "Iniciar Rastro"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.new(0.9, 0, 0, 40)
clearBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
clearBtn.Text = "Limpar Rastro"
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Lógica do Rastro
local function createGhost(cframe)
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 4, 2) -- Tamanho aproximado de um jogador
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 255, 255) -- Cor ciano brilhante
    part.Transparency = 0.6
    part.Parent = ghostFolder
end

toggleBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    toggleBtn.Text = isRecording and "Gravando..." or "Iniciar Rastro"
    toggleBtn.BackgroundColor3 = isRecording and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(50, 200, 50)
end)

clearBtn.MouseButton1Click:Connect(function()
    ghostFolder:ClearAllChildren()
end)

-- Loop de gravação (a cada 0.3 segundos)
local timer = 0
runService.RenderStepped:Connect(function(dt)
    if isRecording then
        timer = timer + dt
        if timer > 0.3 then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createGhost(player.Character.HumanoidRootPart.CFrame)
            end
            timer = 0
        end
    end
end)
