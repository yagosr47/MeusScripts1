-- =========================================================
-- PAINEL ADM COM INTERFACE GRÁFICA (HUB) E LISTA DE COMANDOS
-- =========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- 1. CRIAÇÃO DA INTERFACE VISUAL (GUI)
-- =========================================================

local AdmGui = Instance.new("ScreenGui")
AdmGui.Name = "YagoAdmHub"
AdmGui.ResetOnSpawn = false
local success = pcall(function()
    AdmGui.Parent = game:GetService("CoreGui")
end)
if not success then
    AdmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 250)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = AdmGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Painel de Comando ADM"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local TabMenu = Instance.new("Frame")
TabMenu.Size = UDim2.new(1, 0, 0, 35)
TabMenu.Position = UDim2.new(0, 0, 0, 30)
TabMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabMenu.BorderSizePixel = 0
TabMenu.Parent = MainFrame

local TabExecutar = Instance.new("TextButton")
TabExecutar.Size = UDim2.new(0.5, 0, 1, 0)
TabExecutar.Position = UDim2.new(0, 0, 0, 0)
TabExecutar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabExecutar.TextColor3 = Color3.fromRGB(255, 255, 255)
TabExecutar.Text = "Executar"
TabExecutar.Font = Enum.Font.GothamSemibold
TabExecutar.TextSize = 13
TabExecutar.BorderSizePixel = 0
TabExecutar.Parent = TabMenu

local TabComandos = Instance.new("TextButton")
TabComandos.Size = UDim2.new(0.5, 0, 1, 0)
TabComandos.Position = UDim2.new(0.5, 0, 0, 0)
TabComandos.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabComandos.TextColor3 = Color3.fromRGB(150, 150, 150)
TabComandos.Text = "Lista de Comandos"
TabComandos.Font = Enum.Font.GothamSemibold
TabComandos.TextSize = 13
TabComandos.BorderSizePixel = 0
TabComandos.Parent = TabMenu

-- =========================================================
-- ABA 1: EXECUTAR
-- =========================================================
local ExecutarFrame = Instance.new("Frame")
ExecutarFrame.Size = UDim2.new(1, 0, 1, -65)
ExecutarFrame.Position = UDim2.new(0, 0, 0, 65)
ExecutarFrame.BackgroundTransparency = 1
ExecutarFrame.Visible = true
ExecutarFrame.Parent = MainFrame

local CommandInput = Instance.new("TextBox")
CommandInput.Size = UDim2.new(1, -60, 0, 45)
CommandInput.Position = UDim2.new(0, 30, 0, 30)
CommandInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandInput.Font = Enum.Font.Gotham
CommandInput.TextSize = 16
CommandInput.PlaceholderText = "Ex: speed me 50"
CommandInput.Text = ""
CommandInput.ClearTextOnFocus = false
CommandInput.Parent = ExecutarFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = CommandInput

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(1, -60, 0, 40)
ExecuteBtn.Position = UDim2.new(0, 30, 0, 95)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
ExecuteBtn.Text = "EXECUTAR COMANDO"
ExecuteBtn.Parent = ExecutarFrame

local ExecCorner = Instance.new("UICorner")
ExecCorner.CornerRadius = UDim.new(0, 6)
ExecCorner.Parent = ExecuteBtn

-- =========================================================
-- ABA 2: LISTA DE COMANDOS
-- =========================================================
local ComandosFrame = Instance.new("Frame")
ComandosFrame.Size = UDim2.new(1, 0, 1, -65)
ComandosFrame.Position = UDim2.new(0, 0, 0, 65)
ComandosFrame.BackgroundTransparency = 1
ComandosFrame.Visible = false
ComandosFrame.Parent = MainFrame

local ScrollComandos = Instance.new("ScrollingFrame")
ScrollComandos.Size = UDim2.new(1, -20, 1, -20)
ScrollComandos.Position = UDim2.new(0, 10, 0, 10)
ScrollComandos.BackgroundTransparency = 1
ScrollComandos.ScrollBarThickness = 5
ScrollComandos.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollComandos.BorderSizePixel = 0
ScrollComandos.Parent = ComandosFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ScrollComandos

local ComandosInfo = {
    {cmd = "kill [alvo]", desc = "Elimina o jogador selecionado."},
    {cmd = "kick [alvo] [motivo]", desc = "Expulsa o jogador do servidor."},
    {cmd = "speed [alvo] [número]", desc = "Altera a velocidade (Padrão: 16)."},
    {cmd = "jump [alvo] [número]", desc = "Altera a força do pulo (Padrão: 50)."},
    {cmd = "god [alvo]", desc = "Torna o jogador invencível (Vida infinita)."},
    {cmd = "ungod [alvo]", desc = "Remove a invencibilidade do jogador."},
    {cmd = "heal [alvo]", desc = "Restaura a vida do jogador ao máximo."},
    {cmd = "tp [alvo1] [alvo2]", desc = "Teleporta o alvo1 até o alvo2."},
    {cmd = "bring [alvo]", desc = "Teleporta o jogador até a sua localização."},
    {cmd = "goto [alvo]", desc = "Teleporta você até a localização do jogador."},
    {cmd = "freeze [alvo]", desc = "Congela o jogador no lugar."},
    {cmd = "unfreeze [alvo]", desc = "Descongela o jogador."},
    {cmd = "ff [alvo]", desc = "Dá um ForceField (Escudo) ao jogador."},
    {cmd = "unff [alvo]", desc = "Remove o ForceField do jogador."},
    {cmd = "sit [alvo]", desc = "Força o jogador a sentar."},
    {cmd = "invis [alvo]", desc = "Deixa o jogador invisível."},
    {cmd = "vis [alvo]", desc = "Deixa o jogador visível novamente."},
    {cmd = "fire [alvo]", desc = "Coloca fogo no personagem do jogador."},
    {cmd = "unfire [alvo]", desc = "Remove o fogo do personagem."}
}

for i, info in ipairs(ComandosInfo) do
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Size = UDim2.new(1, -10, 0, 40)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = ScrollComandos

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 4)
    ItemCorner.Parent = ItemFrame

    local CmdText = Instance.new("TextLabel")
    CmdText.Size = UDim2.new(0.45, 0, 1, 0)
    CmdText.Position = UDim2.new(0, 10, 0, 0)
    CmdText.BackgroundTransparency = 1
    CmdText.Text = info.cmd
    CmdText.TextColor3 = Color3.fromRGB(100, 180, 255)
    CmdText.Font = Enum.Font.GothamBold
    CmdText.TextSize = 12
    CmdText.TextXAlignment = Enum.TextXAlignment.Left
    CmdText.Parent = ItemFrame

    local DescText = Instance.new("TextLabel")
    DescText.Size = UDim2.new(0.55, -20, 1, 0)
    DescText.Position = UDim2.new(0.45, 10, 0, 0)
    DescText.BackgroundTransparency = 1
    DescText.Text = info.desc
    DescText.TextColor3 = Color3.fromRGB(200, 200, 200)
    DescText.Font = Enum.Font.Gotham
    DescText.TextSize = 11
    DescText.TextXAlignment = Enum.TextXAlignment.Left
    DescText.TextWrapped = true
    DescText.Parent = ItemFrame
end

ScrollComandos.CanvasSize = UDim2.new(0, 0, 0, #ComandosInfo * 45)

-- =========================================================
-- LÓGICA DAS ABAS E BOTÕES DA GUI
-- =========================================================

CloseBtn.MouseButton1Click:Connect(function()
    AdmGui:Destroy()
end)

TabExecutar.MouseButton1Click:Connect(function()
    ExecutarFrame.Visible = true
    ComandosFrame.Visible = false
    TabExecutar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabExecutar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabComandos.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabComandos.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

TabComandos.MouseButton1Click:Connect(function()
    ExecutarFrame.Visible = false
    ComandosFrame.Visible = true
    TabComandos.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabComandos.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabExecutar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabExecutar.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- =========================================================
-- 2. LÓGICA DE ALVOS (TARGETS)
-- =========================================================

local function GetTargets(targetString)
    local targets = {}
    if not targetString then return targets end
    
    targetString = string.lower(targetString)
    
    if targetString == "me" then
        table.insert(targets, LocalPlayer)
    elseif targetString == "all" then
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(targets, p)
        end
    elseif targetString == "others" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then 
                table.insert(targets, p) 
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, #targetString) == targetString then
                table.insert(targets, p)
            end
        end
    end
    
    return targets
end

-- =========================================================
-- 3. BANCO DE COMANDOS
-- =========================================================

local Commands = {}

-- Comandos Antigos
Commands["kill"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
end

Commands["kick"] = function(args)
    local targets = GetTargets(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    if reason == "" then reason = "Expulso pelo ADM." end

    for _, target in ipairs(targets) do
        target:Kick(reason)
    end
end

Commands["speed"] = function(args)
    local targets = GetTargets(args[1])
    local speedValue = tonumber(args[2]) or 16
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = speedValue
        end
    end
end

Commands["jump"] = function(args)
    local targets = GetTargets(args[1])
    local jumpValue = tonumber(args[2]) or 50
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.JumpPower = jumpValue
            target.Character.Humanoid.UseJumpPower = true
        end
    end
end

Commands["god"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = math.huge
            target.Character.Humanoid.Health = math.huge
        end
    end
end

Commands["ungod"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = 100
            target.Character.Humanoid.Health = 100
        end
    end
end

Commands["heal"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = target.Character.Humanoid.MaxHealth
        end
    end
end

Commands["tp"] = function(args)
    local targetsA = GetTargets(args[1])
    local targetsB = GetTargets(args[2])
    
    if #targetsA > 0 and #targetsB > 0 then
        local destination = targetsB[1].Character
        if destination and destination:FindFirstChild("HumanoidRootPart") then
            for _, targetA in ipairs(targetsA) do
                if targetA.Character and targetA.Character:FindFirstChild("HumanoidRootPart") then
                    targetA.Character.HumanoidRootPart.CFrame = destination.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

Commands["bring"] = function(args)
    local targets = GetTargets(args[1])
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        for _, target in ipairs(targets) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                target.Character.HumanoidRootPart.CFrame = myCFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

Commands["goto"] = function(args)
    local targets = GetTargets(args[1])
    if #targets > 0 then
        local destination = targets[1].Character
        if destination and destination:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = destination.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

-- Novos Comandos Adicionados
Commands["freeze"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = true
        end
    end
end

Commands["unfreeze"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = false
        end
    end
end

Commands["ff"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and not target.Character:FindFirstChildOfClass("ForceField") then
            Instance.new("ForceField", target.Character)
        end
    end
end

Commands["unff"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character then
            for _, child in ipairs(target.Character:GetChildren()) do
                if child:IsA("ForceField") then
                    child:Destroy()
                end
            end
        end
    end
end

Commands["sit"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Sit = true
        end
    end
end

Commands["invis"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character then
            for _, part in ipairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
end

Commands["vis"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character then
            for _, part in ipairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end
end

Commands["fire"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not target.Character.HumanoidRootPart:FindFirstChild("AdminFire") then
                local fire = Instance.new("Fire")
                fire.Name = "AdminFire"
                fire.Parent = target.Character.HumanoidRootPart
            end
        end
    end
end

Commands["unfire"] = function(args)
    local targets = GetTargets(args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local fire = target.Character.HumanoidRootPart:FindFirstChild("AdminFire")
            if fire then
                fire:Destroy()
            end
        end
    end
end

-- =========================================================
-- 4. PROCESSADOR DE COMANDOS DA INTERFACE
-- =========================================================

local function ExecuteCommand()
    local text = CommandInput.Text
    if text == "" then return end
    
    local args = string.split(text, " ")
    local commandName = string.lower(args[1])
    table.remove(args, 1) 
    
    if Commands[commandName] then
        local success, err = pcall(function()
            Commands[commandName](args)
        end)
        
        if success then
            CommandInput.Text = ""
            CommandInput.PlaceholderText = "Comando '" .. commandName .. "' executado!"
            task.wait(2)
            CommandInput.PlaceholderText = "Ex: speed me 50"
        else
            warn("Erro no comando: " .. tostring(err))
        end
    else
        CommandInput.Text = ""
        CommandInput.PlaceholderText = "Comando não encontrado!"
        task.wait(2)
        CommandInput.PlaceholderText = "Ex: speed me 50"
    end
end

ExecuteBtn.MouseButton1Click:Connect(ExecuteCommand)
CommandInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ExecuteCommand()
    end
end)
