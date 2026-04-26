-- ==========================================
-- Hub Universal V4 - ABAS E TEMAS
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Configurações Globais
local minimizado = false
local espAtivado = false
local invisivel = false
local corTema = Color3.fromRGB(0, 170, 255) -- Azul padrão

-- 1. Interface Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubPremiumV4"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = corTema

-- Barra de Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB UNIVERSAL V4"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Botões Fechar e Minimizar
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- SISTEMA DE ABAS (TABS)
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tabBar.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.LayoutOrder = ordem
    return btn
end

local tabScripts = criarAba("Scripts", 1)
local tabConfig = criarAba("Interface", 2)
local tabSec = criarAba("Segurança", 3)

-- Containers das Páginas
local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70)
pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local function criarPagina()
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return page
end

local pageScripts = criarPagina()
local pageConfig = criarPagina()
local pageSec = criarPagina()
pageScripts.Visible = true -- Página inicial

-- Lógica de troca de abas
local function mudarAba(ativa, paginaAtiva)
    tabScripts.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabConfig.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabSec.TextColor3 = Color3.fromRGB(200, 200, 200)
    ativa.TextColor3 = corTema
    
    pageScripts.Visible = false
    pageConfig.Visible = false
    pageSec.Visible = false
    paginaAtiva.Visible = true
end

tabScripts.MouseButton1Click:Connect(function() mudarAba(tabScripts, pageScripts) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)
tabSec.MouseButton1Click:Connect(function() mudarAba(tabSec, pageSec) end)
tabScripts.TextColor3 = corTema -- Cor inicial

-- ==========================================
-- PÁGINA 1: SCRIPTS
-- ==========================================
local function criarLinhaEscala(texto, baseValue, parent, isJump)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.7, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.25, 0, 1, 0)
    input.Position = UDim2.new(0.75, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.Text = "1"
    input.TextColor3 = corTema
    input.Font = Enum.Font.GothamBold
    input.TextSize = 16
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local valor = tonumber(input.Text) or 1
            valor = math.clamp(valor, 1, 10)
            input.Text = tostring(valor)
            if isJump then
                char.Humanoid.UseJumpPower = true
                char.Humanoid.JumpPower = baseValue * valor
            else
                char.Humanoid.WalkSpeed = baseValue * valor
            end
        end
    end)
    return input
end

local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- Espaço no topo
Instance.new("Frame", pageScripts).Size = UDim2.new(1,0,0,1)

local inputVel = criarLinhaEscala("Aplicar Velocidade (1-10)", 16, pageScripts, false)
local inputPulo = criarLinhaEscala("Aplicar Pulo (1-10)", 50, pageScripts, true)
local btnInvis = criarBotaoSimples("Ativar Invisibilidade", pageScripts)
local btnEsp = criarBotaoSimples("Ativar ESP (Nomes)", pageScripts)
local btnSpec = criarBotaoSimples("Espionar Próximo", pageScripts)
local btnUnspec = criarBotaoSimples("Parar Espionagem", pageScripts, Color3.fromRGB(120, 50, 50))

-- Lógica Invisibilidade (Local)
btnInvis.MouseButton1Click:Connect(function()
    invisivel = not invisivel
    btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ativar Invisibilidade"
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = invisivel and 1 or 0
            elseif part:IsA("Decal") then
                part.Transparency = invisivel and 1 or 0
            end
        end
    end
end)

-- Lógica ESP
btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnEsp.Text = espAtivado and "ESP: ATIVADO" or "Ativar ESP (Nomes)"
    if espAtivado then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local bgui = Instance.new("BillboardGui", p.Character.Head)
                bgui.Name = "ESPTag"
                bgui.Size = UDim2.new(0, 200, 0, 50)
                bgui.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", bgui)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = p.Name
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.TextStrokeTransparency = 0
                txt.TextSize = 14
                txt.Font = Enum.Font.GothamBold
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

-- Lógica Espionar
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

-- ==========================================
-- PÁGINA 2: CONFIGURAÇÕES (TEMA)
-- ==========================================
Instance.new("Frame", pageConfig).Size = UDim2.new(1,0,0,1)
local txtConfig = Instance.new("TextLabel", pageConfig)
txtConfig.Size = UDim2.new(0.9, 0, 0, 30)
txtConfig.BackgroundTransparency = 1
txtConfig.Text = "Escolha a cor do Menu:"
txtConfig.TextColor3 = Color3.fromRGB(255, 255, 255)
txtConfig.Font = Enum.Font.GothamBold
txtConfig.TextSize = 14

local cores = {
    {"Azul Neon", Color3.fromRGB(0, 170, 255)},
    {"Vermelho Sangue", Color3.fromRGB(255, 50, 50)},
    {"Verde Hacker", Color3.fromRGB(50, 255, 50)},
    {"Roxo Escuro", Color3.fromRGB(150, 50, 255)}
}

for _, dados in ipairs(cores) do
    local btnCor = criarBotaoSimples(dados[1], pageConfig, dados[2])
    btnCor.TextColor3 = Color3.fromRGB(0,0,0) -- Texto preto para ler melhor nas cores
    btnCor.MouseButton1Click:Connect(function()
        corTema = dados[2]
        mainStroke.Color = corTema
        inputVel.TextColor3 = corTema
        inputPulo.TextColor3 = corTema
        if tabScripts.TextColor3 ~= Color3.fromRGB(200,200,200) then tabScripts.TextColor3 = corTema end
        if tabConfig.TextColor3 ~= Color3.fromRGB(200,200,200) then tabConfig.TextColor3 = corTema end
        if tabSec.TextColor3 ~= Color3.fromRGB(200,200,200) then tabSec.TextColor3 = corTema end
    end)
end

-- ==========================================
-- PÁGINA 3: SEGURANÇA (SCANNER)
-- ==========================================
Instance.new("Frame", pageSec).Size = UDim2.new(1,0,0,1)

local infoSec = Instance.new("TextLabel", pageSec)
infoSec.Size = UDim2.new(0.9, 0, 0, 60)
infoSec.BackgroundTransparency = 1
infoSec.Text = "Este scanner verifica nomes de arquivos locais suspeitos. Ele não detecta anti-cheats de servidor!"
infoSec.TextColor3 = Color3.fromRGB(180, 180, 180)
infoSec.TextWrapped = true
infoSec.Font = Enum.Font.Gotham
infoSec.TextSize = 12

local btnScan = criarBotaoSimples("Iniciar Verificação do Mapa", pageSec, Color3.fromRGB(80, 80, 80))

local resultadoSec = Instance.new("TextLabel", pageSec)
resultadoSec.Size = UDim2.new(0.9, 0, 0, 80)
resultadoSec.BackgroundTransparency = 1
resultadoSec.Text = "Status: Aguardando verificação..."
resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 255)
resultadoSec.TextWrapped = true
resultadoSec.Font = Enum.Font.GothamBold
resultadoSec.TextSize = 14

btnScan.MouseButton1Click:Connect(function()
    btnScan.Text = "Escaneando..."
    resultadoSec.Text = "Procurando scripts suspeitos..."
    resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    task.wait(2) -- Simula o tempo de escaneamento
    
    local suspeito = false
    -- Varredura básica por palavras chave no cliente
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") then
            local nome = string.lower(v.Name)
            if string.find(nome, "anti") or string.find(nome, "cheat") or string.find(nome, "ban") or string.find(nome, "kick") then
                suspeito = true
                break
            end
        end
    end
    
    btnScan.Text = "Refazer Verificação"
    if suspeito then
        resultadoSec.Text = "⚠️ ALERTA: Arquivos de Anti-Cheat detectados no cliente! Risco Alto de usar scripts."
        resultadoSec.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        resultadoSec.Text = "✅ Aparentemente Seguro: Nenhum sistema básico de Anti-Cheat local foi encontrado (Mas cuidado com o Servidor)."
        resultadoSec.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

-- ==========================================
-- SISTEMA DE JANELA
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false
        pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 400), "Out", "Quad", 0.3, true)
        tabBar.Visible = true
        pageContainer.Visible = true
    end
end)
