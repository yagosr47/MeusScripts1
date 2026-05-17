-- ==========================================
-- GHOST REPLAY (OTIMIZADO PARA EXECUTORES)
-- Rode este script no seu Executor (Delta, Fluxus, etc)
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Sistema inteligente para não dar erro em executores de celular
local targetGui
if type(gethui) == "function" then
    targetGui = gethui() -- Melhor método para executores
else
    local success = pcall(function() return CoreGui.Name end)
    if success then
        targetGui = CoreGui
    else
        targetGui = player:WaitForChild("PlayerGui")
    end
end

-- Evita duplicar a interface se você apertar Execute duas vezes
if targetGui:FindFirstChild("ReplayGUI_Executor") then
    targetGui.ReplayGUI_Executor:Destroy()
end

-- ==========================================
-- 1. CRIANDO A INTERFACE (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReplayGUI_Executor"
screenGui.ResetOnSpawn = false -- Não some quando você morre
screenGui.Parent = targetGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 170)
frame.Position = UDim2.new(0.5, -100, 0.2, 0) -- Centralizado no topo
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🎥 Ghost Replay"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 30)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Parado"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.Parent = frame

-- Botões
local btnRecord = Instance.new("TextButton")
btnRecord.Size = UDim2.new(0.9, 0, 0, 30)
btnRecord.Position = UDim2.new(0.05, 0, 0, 55)
btnRecord.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnRecord.Text = "🔴 Gravar"
btnRecord.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRecord.Font = Enum.Font.GothamBold
btnRecord.TextSize = 12
btnRecord.Parent = frame

local btnStop = Instance.new("TextButton")
btnStop.Size = UDim2.new(0.9, 0, 0, 30)
btnStop.Position = UDim2.new(0.05, 0, 0, 95)
btnStop.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnStop.Text = "⏹️ Parar"
btnStop.TextColor3 = Color3.fromRGB(255, 255, 255)
btnStop.Font = Enum.Font.GothamBold
btnStop.TextSize = 12
btnStop.Parent = frame

local btnPlay = Instance.new("TextButton")
btnPlay.Size = UDim2.new(0.9, 0, 0, 30)
btnPlay.Position = UDim2.new(0.05, 0, 0, 135)
btnPlay.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
btnPlay.Text = "▶️ Tocar Clone"
btnPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPlay.Font = Enum.Font.GothamBold
btnPlay.TextSize = 12
btnPlay.Parent = frame

-- Arredondar botões
for _, obj in ipairs(frame:GetChildren()) do
    if obj:IsA("TextButton") then
        Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 4)
    end
end

-- ==========================================
-- 2. LÓGICA DE GRAVAÇÃO E REPLAY
-- ==========================================
local isRecording = false
local framesGravados = {} 
local conexaoGravacao = nil

btnRecord.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    isRecording = true
    framesGravados = {} 
    statusText.Text = "Status: 🔴 GRAVANDO..."
    statusText.TextColor3 = Color3.fromRGB(255, 50, 50)

    if conexaoGravacao then conexaoGravacao:Disconnect() end
    conexaoGravacao = runService.Heartbeat:Connect(function()
        if isRecording and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(framesGravados, player.Character.HumanoidRootPart.CFrame)
        end
    end)
end)

btnStop.MouseButton1Click:Connect(function()
    isRecording = false
    if conexaoGravacao then 
        conexaoGravacao:Disconnect() 
        conexaoGravacao = nil
    end
    statusText.Text = "Status: Parado (" .. #framesGravados .. " frames)"
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

btnPlay.MouseButton1Click:Connect(function()
    if #framesGravados == 0 then
        statusText.Text = "Erro: Nada gravado!"
        return
    end

    local char = player.Character
    if not char then return end

    statusText.Text = "Status: ▶️ REPRODUZINDO"
    statusText.TextColor3 = Color3.fromRGB(50, 255, 100)

    char.Archivable = true
    local clone = char:Clone()
    char.Archivable = false
    clone.Name = "GhostReplay"
    
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5 -- Deixa o clone meio transparente
            part.CanCollide = false
            part.Anchored = true
        end
    end
    
    clone.Parent = workspace

    task.spawn(function()
        clone:PivotTo(framesGravados[1])
        task.wait(0.5)

        for _, cframeSalvo in ipairs(framesGravados) do
            if not clone or not clone.Parent then break end
            clone:PivotTo(cframeSalvo)
            runService.Heartbeat:Wait()
        end

        task.wait(1)
        if clone then clone:Destroy() end
        statusText.Text = "Status: Parado"
        statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end)
