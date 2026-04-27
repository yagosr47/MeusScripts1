-- =========================================================
-- HUB DEATH NOTE (NOTA DE MORTE) - CLIENT-SIDE EXPLOIT
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
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
TitleBar.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Vermelho escuro temático
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
TitleText.Text = "DEATH NOTE SCRIPT"
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
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonsFrame

-- Função para criar botões padronizados
local function CreateButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.Parent = parent
    return btn
end

local BtnESPPlayers = CreateButton("Ativar ESP (Funções/Nomes)", ButtonsFrame)
local BtnESPItems = CreateButton("Ativar ESP (Cartões de ID)", ButtonsFrame)
local BtnProbKira = CreateButton("Forçar Chance: KIRA (Bypass)", ButtonsFrame)
local BtnProbL = CreateButton("Forçar Chance: L (Bypass)", ButtonsFrame)

-- =========================================================
-- 2. LÓGICA DE ESP DE JOGADORES (FUNÇÕES)
-- =========================================================
local ESPPlayersAtivo = false

-- Função inteligente para descobrir a classe (role) do jogador
local function GetPlayerRole(player)
    -- 1. Verifica se o jogo salva no próprio objeto do jogador (StringValue/Objeto)
    if player:FindFirstChild("Role") then return player.Role.Value end
    if player:FindFirstChild("Equipe") then return player.Equipe.Value end
    
    -- 2. Verifica se o jogador tem ferramentas (ferramentas como o caderno indicam Kira)
    if player:FindFirstChild("Backpack") then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            local name = string.lower(item.Name)
            if string.find(name, "death") or string.find(name, "caderno") or string.find(name, "note") then
                return "Kira (Com Caderno)"
            end
        end
    end
    
    -- 3. Verifica no Character
    if player.Character then
        if player.Character:FindFirstChild("Role") then return player.Character.Role.Value end
        -- Se estiver segurando o item na mão
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            local name = string.lower(tool.Name)
            if string.find(name, "death") or string.find(name, "note") then return "Kira" end
            if string.find(name, "id") or string.find(name, "cartão") then return "Investigador / L" end
        end
    end
    
    return "Inocente / Desconhecido"
end

local function UpdatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            
            -- Remove o ESP antigo se existir
            if head:FindFirstChild("RoleESP") then
                head.RoleESP:Destroy()
            end
            
            if ESPPlayersAtivo then
                local role = GetPlayerRole(player)
                
                -- Cor baseada na função
                local roleColor = Color3.fromRGB(200, 200, 200) -- Inocente (Cinza)
                if string.find(string.lower(role), "kira") then
                    roleColor = Color3.fromRGB(255, 50, 50) -- Kira (Vermelho)
                elseif string.find(string.lower(role), "l") or string.find(string.lower(role), "near") then
                    roleColor = Color3.fromRGB(50, 100, 255) -- L/Near (Azul)
                end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "RoleESP"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true -- Mostra através das paredes
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = player.Name .. "\n[" .. role .. "]"
                textLabel.TextColor3 = roleColor
                textLabel.TextStrokeTransparency = 0 -- Borda preta para ler de longe
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
        UpdatePlayerESP() -- Limpa o ESP ao desligar
    end
end)

-- Atualiza o ESP dos jogadores a cada segundo
task.spawn(function()
    while task.wait(1) do
        if ESPPlayersAtivo then
            UpdatePlayerESP()
        end
    end
end)

-- =========================================================
-- 3. LÓGICA DE ESP DE ITENS (CARTÕES ID)
-- =========================================================
local ESPItemsAtivo = false

local function UpdateItemESP()
    -- Limpa todos os ESPs de itens anteriores
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == "ItemESP" then
            v:Destroy()
        end
    end

    if ESPItemsAtivo then
        for _, item in ipairs(Workspace:GetDescendants()) do
            -- Procura por itens que possam ser cartões de ID ou cadernos
            if item:IsA("BasePart") or item:IsA("Tool") or item:IsA("Model") then
                local name = string.lower(item.Name)
                if string.find(name, "id") or string.find(name, "card") or string.find(name, "cartão") or string.find(name, "note") then
                    
                    -- Acha a parte principal do item para colocar a UI
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
                        textLabel.TextColor3 = Color3.fromRGB(255, 200, 50) -- Amarelo para destacar
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

-- Atualiza itens a cada 3 segundos (menos frequente para evitar lag)
task.spawn(function()
    while task.wait(3) do
        if ESPItemsAtivo then
            UpdateItemESP()
        end
    end
end)

-- =========================================================
-- 4. MANIPULAÇÃO DE PROBABILIDADE (BYPASS ATTEMPT)
-- =========================================================
-- Como a probabilidade costuma ser Server-Side, este script
-- tenta achar Eventos Remotos mal protegidos que os desenvolvedores
-- deixam no ReplicatedStorage para testar o jogo.

local function AttemptToSetRole(roleName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Tenta encontrar e disparar eventos remotos comuns em jogos de Murder/DeathNote
    local remoteNames = {"SetRole", "ChangeRole", "SelectRole", "RoleEvent", "UpdateProbability", "SetKira", "SetL"}
    
    local successFire = false
    
    for _, rName in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(rName, true)
        if remote and remote:IsA("RemoteEvent") then
            -- Tenta enviar o cargo desejado ou probabilidade 100%
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
    
    -- Tenta alterar valores locais (pode não replicar, mas vale a pena forçar localmente)
    if LocalPlayer:FindFirstChild("KiraChance") then
        LocalPlayer.KiraChance.Value = 100
    end
    
    if successFire then
        print("Exploit de Probabilidade enviado ao servidor para: " .. roleName)
    else
        warn("Nenhum RemoteEvent desprotegido encontrado para " .. roleName .. ". O jogo pode ter um anti-cheat seguro.")
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

