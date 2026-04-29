-- ==========================================================
-- DEATH NOTE ROBLOX - EXECUTOR HUB
-- Baseado nas mecânicas: ESP de IDs, Death Notes e Players
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- PROTEÇÃO E CRIAÇÃO DA GUI
-- ==========================================
local DeathNoteHub = Instance.new("ScreenGui")
DeathNoteHub.Name = "DeathNoteHub_Exec"
DeathNoteHub.ResetOnSpawn = false

-- Tenta colocar no CoreGui para bypassar anti-cheats básicos, se falhar vai pro PlayerGui
local success = pcall(function()
    DeathNoteHub.Parent = CoreGui
end)
if not success then
    DeathNoteHub.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DeathNoteHub

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "DEATH NOTE HUB"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.Oswald
Title.TextSize = 24
Title.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Espaçamento do título
local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 50)
Padding.Parent = MainFrame

-- Função para criar botões Toggle
local function createToggle(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name .. " [OFF]"
    btn.Parent = MainFrame
    return btn
end

-- ==========================================
-- VARIÁVEIS DE ESTADO (TOGGLES)
-- ==========================================
local states = {
    DeathNoteESP = false,
    IdESP = false,
    PlayerESP = false,
    Fullbright = false
}

-- ==========================================
-- FUNÇÕES DE ESP (EXTRAÇÃO DO WORKSPACE)
-- ==========================================

local function createESP(instance, color, nameText)
    if not instance:FindFirstChild("DN_ESP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DN_ESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = nameText
        text.TextColor3 = color
        text.TextStrokeTransparency = 0
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 14
        text.Parent = billboard
        
        billboard.Parent = instance
    end
end

local function clearESP(espName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == espName then
            v:Destroy()
        end
    end
end

-- ==========================================
-- LÓGICA DOS BOTÕES
-- ==========================================

-- 1. Death Note ESP (Spots Death Notes for free)
local btnDN = createToggle("Death Note ESP")
btnDN.MouseButton1Click:Connect(function()
    states.DeathNoteESP = not states.DeathNoteESP
    btnDN.Text = "Death Note ESP " .. (states.DeathNoteESP and "[ON]" or "[OFF]")
    btnDN.TextColor3 = states.DeathNoteESP and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 255, 255)
    
    if not states.DeathNoteESP then
        clearESP("DN_ESP_NOTE")
    end
end)

-- 2. I.D. ESP (Spots IDs for free)
local btnID = createToggle("I.D. ESP")
btnID.MouseButton1Click:Connect(function()
    states.IdESP = not states.IdESP
    btnID.Text = "I.D. ESP " .. (states.IdESP and "[ON]" or "[OFF]")
    btnID.TextColor3 = states.IdESP and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 255, 255)
    
    if not states.IdESP then
        clearESP("DN_ESP_ID")
    end
end)

-- 3. Player ESP
local btnPlayer = createToggle("Player ESP")
btnPlayer.MouseButton1Click:Connect(function()
    states.PlayerESP = not states.PlayerESP
    btnPlayer.Text = "Player ESP " .. (states.PlayerESP and "[ON]" or "[OFF]")
    btnPlayer.TextColor3 = states.PlayerESP and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 255, 255)
    
    if not states.PlayerESP then
        clearESP("DN_ESP_PLAYER")
    end
end)

-- 4. Fullbright (Shinigami Vision)
local btnBright = createToggle("Shinigami Vision")
btnBright.MouseButton1Click:Connect(function()
    states.Fullbright = not states.Fullbright
    btnBright.Text = "Shinigami Vision " .. (states.Fullbright and "[ON]" or "[OFF]")
    btnBright.TextColor3 = states.Fullbright and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 255, 255)
    
    if states.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128) -- Cores padrão aproximadas
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

-- ==========================================
-- LOOP DE ATUALIZAÇÃO (RENDER STEPPED)
-- ==========================================
RunService.RenderStepped:Connect(function()
    
    -- Atualiza ESP de Itens no Workspace
    if states.DeathNoteESP or states.IdESP then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = string.lower(obj.Name)
                
                -- Checa por Death Notes
                if states.DeathNoteESP and (string.find(name, "deathnote") or string.find(name, "death note")) then
                    if not obj:FindFirstChild("DN_ESP_NOTE") then
                        local esp = createESP(obj, Color3.fromRGB(0, 0, 0), "💀 DEATH NOTE")
                        if obj:FindFirstChild("DN_ESP") then obj.DN_ESP.Name = "DN_ESP_NOTE" end
                    end
                end
                
                -- Checa por IDs
                if states.IdESP and (string.find(name, "id") or string.find(name, "i.d")) and not string.find(name, "video") then
                    if not obj:FindFirstChild("DN_ESP_ID") then
                        local esp = createESP(obj, Color3.fromRGB(0, 255, 255), "🪪 I.D.")
                        if obj:FindFirstChild("DN_ESP") then obj.DN_ESP.Name = "DN_ESP_ID" end
                    end
                end
            end
        end
    end
    
    -- Atualiza ESP de Players
    if states.PlayerESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                if not head:FindFirstChild("DN_ESP_PLAYER") then
                    createESP(head, Color3.fromRGB(255, 0, 0), p.Name)
                    if head:FindFirstChild("DN_ESP") then head.DN_ESP.Name = "DN_ESP_PLAYER" end
                end
            end
        end
    end
end)

-- Tecla de atalho para fechar/abrir o menu (Right Shift)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        DeathNoteHub.Enabled = not DeathNoteHub.Enabled
    end
end)

print("Death Note Executor Hub Carregado! Pressione Right Shift para esconder/mostrar o menu.")
