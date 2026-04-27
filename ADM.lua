-- =========================================================
-- PAINEL ADM COM INTERFACE GRÁFICA (HUB)
-- =========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- 1. CRIAÇÃO DA INTERFACE VISUAL (GUI)
-- =========================================================

local AdmGui = Instance.new("ScreenGui")
AdmGui.Name = "YagoAdmHub"
AdmGui.ResetOnSpawn = false
-- Tenta colocar no CoreGui (melhor para executores), se falhar, vai pro PlayerGui
local success = pcall(function()
    AdmGui.Parent = game:GetService("CoreGui")
end)
if not success then
    AdmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 150)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar o painel pela tela
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

-- Remove o arredondamento inferior da barra de título
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

local CommandInput = Instance.new("TextBox")
CommandInput.Size = UDim2.new(1, -40, 0, 40)
CommandInput.Position = UDim2.new(0, 20, 0, 50)
CommandInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandInput.Font = Enum.Font.Gotham
CommandInput.TextSize = 14
CommandInput.PlaceholderText = "Ex: speed me 50"
CommandInput.Text = ""
CommandInput.ClearTextOnFocus = false
CommandInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = CommandInput

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(1, -40, 0, 35)
ExecuteBtn.Position = UDim2.new(0, 20, 0, 100)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
ExecuteBtn.Text = "EXECUTAR COMANDO"
ExecuteBtn.Parent = MainFrame

local ExecCorner = Instance.new("UICorner")
ExecCorner.CornerRadius = UDim.new(0, 6)
ExecCorner.Parent = ExecuteBtn

-- Fecha a interface
CloseBtn.MouseButton1Click:Connect(function()
    AdmGui:Destroy()
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

-- =========================================================
-- 4. PROCESSADOR DE COMANDOS DA INTERFACE
-- =========================================================

local function ExecuteCommand()
    local text = CommandInput.Text
    if text == "" then return end
    
    -- Divide a string do input em argumentos
    local args = string.split(text, " ")
    local commandName = string.lower(args[1])
    table.remove(args, 1) -- Remove o comando, deixando só os alvos/valores
    
    if Commands[commandName] then
        local success, err = pcall(function()
            Commands[commandName](args)
        end)
        
        if success then
            -- Feedback visual de sucesso
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

-- Conecta a execução ao clicar no botão ou ao apertar Enter no teclado
ExecuteBtn.MouseButton1Click:Connect(ExecuteCommand)
CommandInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ExecuteCommand()
    end
end)
