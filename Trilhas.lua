-- ==========================================
-- SCRIPT: GHOST TRAIL PRO (UI APRIMORADA)
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local isRecording = false
local ghostFolder = Instance.new("Folder", workspace)
ghostFolder.Name = "GhostPath_Folder"

-- Limpeza caso já exista
if CoreGui:FindFirstChild("GhostMenu") then CoreGui.GhostMenu:Destroy() end

-- Criando a Interface Moderna
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "GhostMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.8, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Ghost Trail"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

-- Botão de Toggle
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
toggleBtn.Text = "Ativar Trilha"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Botão de Limpar
local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.new(0.8, 0, 0, 40)
clearBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
clearBtn.Text = "Limpar Agora"
clearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
local btnCorner2 = Instance.new("UICorner", clearBtn)
btnCorner2.CornerRadius = UDim.new(0, 8)

-- Lógica da Trilha
local function createGhost(cframe)
    local part = Instance.new("Part")
    part.Size = Vector3.new(3, 5, 3)
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 255, 255)
    part.Transparency = 0.5
    part.Parent = ghostFolder
    
    -- Faz o rastro sumir após 10 segundos
    Debris:AddItem(part, 10)
end

toggleBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    toggleBtn.Text = isRecording and "Gravando..." or "Ativar Trilha"
    toggleBtn.BackgroundColor3 = isRecording and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(40, 40, 40)
end)

clearBtn.MouseButton1Click:Connect(function()
    ghostFolder:ClearAllChildren()
end)

-- Loop
local timer = 0
runService.RenderStepped:Connect(function(dt)
    if isRecording then
        timer = timer + dt
        if timer > 0.25 then -- Frequência da trilha
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createGhost(player.Character.HumanoidRootPart.CFrame)
            end
            timer = 0
        end
    end
end)
