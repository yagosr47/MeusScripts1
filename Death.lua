-- =========================================================
-- HUB DEATH NOTE (NOTA DE MORTE) - V2 (ADVANCED ESP & TRACKING)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variável Global para rastrear quem pegou o Death Note cedo
local EarlyDeathNoteFinder = nil

-- =========================================================
-- 1. CRIAÇÃO DA INTERFACE (GUI)
-- =========================================================

local DeathNoteGui = Instance.new("ScreenGui")
DeathNoteGui.Name = "DeathNoteHub"
DeathNoteGui.ResetOnSpawn = false

local success = pcall(function()
    DeathNoteGui.Parent = CoreGui
end)
if not success then
    DeathNoteGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 360) -- Aumentado para caber novos botões
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DeathNoteGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra de Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DEATH NOTE SCRIPT V2"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    DeathNoteGui:Destroy()
end)

-- Layout para os Botões
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -20, 1, -55)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 45)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonsFrame

local function CreateButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = text
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Parent = parent
    return btn
end

local BtnESPPlayers = CreateButton("Ativar ESP (Funções/Nomes)", ButtonsFrame)
local BtnESPItems = CreateButton("Ativar ESP (Cartões de ID)", ButtonsFrame)
local BtnCheckProbs = CreateButton("🔍 Buscar Probabilidades no Servidor", ButtonsFrame)
local BtnProbKira = CreateButton("Forçar Chance: KIRA (Bypass)", ButtonsFrame)
local BtnProbL = CreateButton("Forçar Chance: L (Bypass)", ButtonsFrame)

-- =========================================================
-- 2. DETECÇÃO ANTECIPADA (EARLY FINDER) & LEITURA DE INTERFACE
-- =========================================================

-- Monitora o Backpack de todos os jogadores constantemente para achar quem pegou antes do jogo iniciar
task.spawn(function()
    while task.wait(0.5) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player:FindFirstChild("Backpack") then
                for _, item in ipairs(player.Backpack:GetChildren()) do
                    local name = string.lower(item.Name)
                    if string.find(name, "death") or string.find(name, "caderno") or string.find(name, "note") then
                        EarlyDeathNoteFinder = player.Name
                    end
                end
            end
            -- Verifica se está segurando na mão
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local name = string.lower(tool.Name)
                    if string.find(name, "death") or string.find(name, "note") then
                        EarlyDeathNoteFinder = player.Name
                    end
                end
            end
        end
    end
end)

-- Tenta ler a interface (PlayerGui) distribuída no início da rodada
-- Nota: Em jogos seguros (FilteringEnabled), só podemos ler a nossa própria GUI com certeza.
-- Porém, lemos a dos outros caso o jogo replique a UI mal configurada.
local function ScanGUIForRole(player)
    local roleFound = nil
    pcall(function()
        if player:FindFirstChild("PlayerGui") then
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                    local text = string.lower(gui.Text)
                    if string.find(text, "você é o kira") or string.find(text, "role: kira") then
                        roleFound = "Kira"
                    elseif string.find(text, "você é o l") or string.find(text, "role: l") or string.find(text, "investigador") then
                        roleFound = "Investigador / L"
                    elseif string.find(text, "inocente") then
                        roleFound = "Inocente"
                    end
                end
            end
        end
    end)
    return roleFound
end

local function GetPlayerRole(player)
    -- 0. Verifica se ele pegou o Death Note antes da partida iniciar
    if EarlyDeathNoteFinder == player.Name then
        return "Kira (Pegou o Caderno Cedo)"
    end

    -- 1. Varredura de Interface (GUI) de início de rodada
    local guiRole = ScanGUIForRole(player)
    if guiRole then return guiRole end

    -- 2. Varredura de valores no Servidor/ReplicatedStorage para esse jogador
    if ReplicatedStorage:FindFirstChild(player.Name) then
        local pFolder = ReplicatedStorage[player.Name]
        if pFolder:FindFirstChild("Role") then return pFolder.Role.Value end
    end

    -- 3. Verifica propriedades diretas no objeto Player
    if player:FindFirstChild("Role") then return player.Role.Value end
    if player:FindFirstChild("Equipe") then return player.Equipe.Value end
    
    -- 4. Verifica Backpack (Ferramentas)
    if player:FindFirstChild("Backpack") then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            local name = string.lower(item.Name)
            if string.find(name, "death") or string.find(name, "note") then
                return "Kira (Caderno na Mochila)"
            end
        end
    end
    
    -- 5. Verifica no Character (Ferramenta na mão ou Valores no Modelo)
    if player.Character then
        if player.Character:FindFirstChild("Role") then return player.Character.Role.Value end
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            local name = string.lower(tool.Name)
            if string.find(name, "death") or string.find(name, "note") then return "Kira (Caderno na Mão)" end
            if string.find(name, "id") or string.find(name, "cartão") then return "Investigador / L" end
        end
    end
    
    return "Inocente / Desconhecido"
end

-- =========================================================
-- 3. LÓGICA DE ESP DE JOGADORES
-- =========================================================
local ESPPlayersAtivo = false

local function UpdatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            
            if head:FindFirstChild("RoleESP") then
                head.RoleESP:Destroy()
            end
            
            if ESPPlayersAtivo then
                local role = GetPlayerRole(player)
                
                local roleColor = Color3.fromRGB(200, 200, 200) -- Inocente (Cinza)
                if string.find(string.lower(role), "kira") then
                    roleColor = Color3.fromRGB(255, 50, 50) -- Kira (Vermelho)
                elseif string.find(string.lower(role), "l") or string.find(string.lower(role), "near") or string.find(string.lower(role), "investigador") then
                    roleColor = Color3.fromRGB(50, 100, 255) -- L/Near (Azul)
                end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "RoleESP"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = player.Name .. "\n[" .. role .. "]"
                textLabel.TextColor3 = roleColor
                textLabel.TextStrokeTransparency = 0
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 12
                textLabel.Parent = billboard
                
                billboard.Parent = head
            end
        end
    end
end

BtnESPPlayers.MouseButton1Click:Connect(function()
    ESPPlayersAtivo = not ESPPlayersAtivo
    if ESPPlayersAtivo then
        BtnESPPlayers.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        BtnESPPlayers.Text = "ESP Jogadores: LIGADO"
    else
        BtnESPPlayers.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        BtnESPPlayers.Text = "Ativar ESP (Funções/Nomes)"
        UpdatePlayerESP()
    end
end)

task.spawn(function()
    while task.wait(1) do
        if ESPPlayersAtivo then
            UpdatePlayerESP()
        end
    end
end)

-- =========================================================
-- 4. ESP DE CARTÕES (ID)
-- =========================================================
local ESPItemsAtivo = false

local function UpdateItemESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == "ItemESP" then
            v:Destroy()
        end
    end

    if ESPItemsAtivo then
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("Tool") or item:IsA("Model") then
                local name = string.lower(item.Name)
                if string.find(name, "id") or string.find(name, "card") or string.find(name, "cartão") or string.find(name, "note") then
                    
                    local targetPart = item
                    if item:IsA("Model") or item:IsA("Tool") then
                        targetPart = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
                    end
                    
                    if targetPart and not targetPart:FindFirstChild("ItemESP") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ItemESP"
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.AlwaysOnTop = true
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = "★ " .. item.Name
                        textLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.Font = Enum.Font.GothamSemibold
                        textLabel.TextSize = 10
                        textLabel.Parent = billboard
                        
                        billboard.Parent = targetPart
                    end
                end
            end
        end
    end
end

BtnESPItems.MouseButton1Click:Connect(function()
    ESPItemsAtivo = not ESPItemsAtivo
    if ESPItemsAtivo then
        BtnESPItems.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        BtnESPItems.Text = "ESP Cartões/ID: LIGADO"
    else
        BtnESPItems.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        BtnESPItems.Text = "Ativar ESP (Cartões de ID)"
    end
    UpdateItemESP()
end)

task.spawn(function()
    while task.wait(3) do
        if ESPItemsAtivo then UpdateItemESP() end
    end
end)

-- =========================================================
-- 5. BUSCA DE PROBABILIDADES NO SERVIDOR E BYPASS
-- =========================================================

BtnCheckProbs.MouseButton1Click:Connect(function()
    BtnCheckProbs.Text = "Buscando..."
    local foundProbs = {}
    
    -- Varre ReplicatedStorage buscando valores numéricos de probabilidade
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local name = string.lower(v.Name)
            if string.find(name, "chance") or string.find(name, "prob") or string.find(name, "rate") then
                table.insert(foundProbs, v.Name .. ": " .. tostring(v.Value) .. "%")
            end
        end
    end
    
    if #foundProbs > 0 then
        print("--- PROBABILIDADES DO SERVIDOR ---")
        for _, prob in ipairs(foundProbs) do
            print(prob)
        end
        BtnCheckProbs.Text = "Ver Console (F9) para Resultados"
    else
        BtnCheckProbs.Text = "Nenhuma Prob. Pública Achada"
    end
    
    task.wait(3)
    BtnCheckProbs.Text = "🔍 Buscar Probabilidades no Servidor"
end)

local function AttemptToSetRole(roleName)
    local remoteNames = {"SetRole", "ChangeRole", "SelectRole", "RoleEvent", "UpdateProbability", "SetKira", "SetL"}
    local successFire = false
    
    for _, rName in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(rName, true)
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(roleName)
                remote:FireServer(roleName, 100) 
            end)
            successFire = true
        elseif remote and remote:IsA("RemoteFunction") then
            pcall(function()
                remote:InvokeServer(roleName)
            end)
            successFire = true
        end
    end
    
    if LocalPlayer:FindFirstChild("KiraChance") then LocalPlayer.KiraChance.Value = 100 end
    if LocalPlayer:FindFirstChild("Chance") then LocalPlayer.Chance.Value = 100 end
    
    if successFire then
        print("Exploit de Probabilidade enviado ao servidor para: " .. roleName)
    else
        warn("Nenhum RemoteEvent desprotegido encontrado.")
    end
end

BtnProbKira.MouseButton1Click:Connect(function()
    AttemptToSetRole("Kira")
    BtnProbKira.Text = "Injetado: KIRA (Pendente)"
    BtnProbKira.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    task.wait(2)
    BtnProbKira.Text = "Forçar Chance: KIRA (Bypass)"
    BtnProbKira.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

BtnProbL.MouseButton1Click:Connect(function()
    AttemptToSetRole("L")
    AttemptToSetRole("Investigator")
    BtnProbL.Text = "Injetado: L (Pendente)"
    BtnProbL.BackgroundColor3 = Color3.fromRGB(0, 50, 150)
    task.wait(2)
    BtnProbL.Text = "Forçar Chance: L (Bypass)"
    BtnProbL.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)
