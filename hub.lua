-- ==========================================
-- Hub Universal V7 - INVENTÁRIO ADICIONADO
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Configurações Globais
local minimizado = false
local espAtivado = false
local invisivel = false
local modoDeus = false
local noclipAtivado = false
local godModeConnection = nil
local noclipConnection = nil
local corTema = Color3.fromRGB(0, 170, 255) 

-- 1. Interface Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubPremiumV7"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 480) -- Painel um pouco maior
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = corTema

-- Barra de Título
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB UNIVERSAL V7"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left

-- Botoes Janela
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

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.25, 0, 1, 0) -- 4 Abas agora, então dividimos 100% por 4
    btn.BackgroundTransparency = 1
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.LayoutOrder = ordem
    return btn
end

local tabScripts = criarAba("Scripts", 1)
local tabInv = criarAba("Inventário", 2)
local tabConfig = criarAba("Interface", 3)
local tabSec = criarAba("Segurança", 4)

-- Containers
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
local pageInv = criarPagina()
local pageConfig = criarPagina()
local pageSec = criarPagina()
pageScripts.Visible = true

local function mudarAba(ativa, paginaAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do
        if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
    end
    ativa.TextColor3 = corTema
    pageScripts.Visible = false; pageInv.Visible = false; pageConfig.Visible = false; pageSec.Visible = false
    paginaAtiva.Visible = true
end

tabScripts.MouseButton1Click:Connect(function() mudarAba(tabScripts, pageScripts) end)
tabInv.MouseButton1Click:Connect(function() mudarAba(tabInv, pageInv) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)
tabSec.MouseButton1Click:Connect(function() mudarAba(tabSec, pageSec) end)
tabScripts.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES DE CRIAÇÃO DE UI
-- ==========================================
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

-- ==========================================
-- PÁGINA 1: SCRIPTS GERAIS
-- ==========================================
Instance.new("Frame", pageScripts).Size = UDim2.new(1,0,0,1)

local btnNoclip = criarBotaoSimples("Atravessar Parede (Noclip)", pageScripts, Color3.fromRGB(120, 60, 180))
local btnGodMode = criarBotaoSimples("Ativar Modo Deus (HP Infinito)", pageScripts, Color3.fromRGB(150, 100, 0))
local inputVel = criarLinhaEscala("Aplicar Velocidade (1-10)", 16, pageScripts, false)
local inputPulo = criarLinhaEscala("Aplicar Pulo (1-10)", 50, pageScripts, true)
local btnInvis = criarBotaoSimples("Ativar Invisibilidade (Local)", pageScripts)
local btnEsp = criarBotaoSimples("Ativar ESP (Nomes)", pageScripts)
local btnSpec = criarBotaoSimples("Espionar Próximo", pageScripts)
local btnUnspec = criarBotaoSimples("Parar Espionagem", pageScripts, Color3.fromRGB(120, 50, 50))

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivado = not noclipAtivado
    btnNoclip.Text = noclipAtivado and "Atravessar Parede: ATIVADO" or "Atravessar Parede (Noclip)"
    if noclipAtivado then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end)

btnGodMode.MouseButton1Click:Connect(function()
    modoDeus = not modoDeus
    btnGodMode.Text = modoDeus and "Modo Deus: ATIVADO" or "Ativar Modo Deus (HP Infinito)"
    if modoDeus then
        godModeConnection = RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.MaxHealth = math.huge
                player.Character.Humanoid.Health = math.huge
            end
        end)
    else
        if godModeConnection then godModeConnection:Disconnect() end
    end
end)

btnInvis.MouseButton1Click:Connect(function()
    invisivel = not invisivel
    btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ativar Invisibilidade (Local)"
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = invisivel and 1 or 0
            elseif part:IsA("Decal") then part.Transparency = invisivel and 1 or 0 end
        end
    end
end)

btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnEsp.Text = espAtivado and "ESP: ATIVADO" or "Ativar ESP (Nomes)"
    if espAtivado then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local bgui = Instance.new("BillboardGui", p.Character.Head)
                bgui.Name = "ESPTag"; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", bgui)
                txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = p.Name
                txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.TextStrokeTransparency = 0; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold
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

local indexSpec = 1
btnSpec.MouseButton1Click:Connect(function()
    local todos = Players:GetPlayers()
    indexSpec = indexSpec + 1; if indexSpec > #todos then indexSpec = 1 end
    local alvo = todos[indexSpec]
    if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid; btnSpec.Text = "Espiando: " .. alvo.Name
    end
end)

btnUnspec.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid; btnSpec.Text = "Espionar Próximo"
    end
end)

-- ==========================================
-- PÁGINA 2: INVENTÁRIO (ITENS)
-- ==========================================
Instance.new("Frame", pageInv).Size = UDim2.new(1,0,0,1)

local infoInv = Instance.new("TextLabel", pageInv)
infoInv.Size = UDim2.new(0.9, 0, 0, 45)
infoInv.BackgroundTransparency = 1
infoInv.Text = "Atenção: A maioria das edições de Itens aqui afetarão apenas a sua tela (Client-Side)."
infoInv.TextColor3 = Color3.fromRGB(255, 100, 100)
infoInv.TextWrapped = true
infoInv.Font = Enum.Font.GothamBold
infoInv.TextSize = 12

local btnAtualizarInv = criarBotaoSimples("Atualizar Lista de Itens", pageInv, Color3.fromRGB(50, 100, 50))
local listaItensFrame = Instance.new("Frame", pageInv)
listaItensFrame.Size = UDim2.new(0.9, 0, 0, 300)
listaItensFrame.BackgroundTransparency = 1
local listaItensLayout = Instance.new("UIListLayout", listaItensFrame)
listaItensLayout.Padding = UDim.new(0, 5)

btnAtualizarInv.MouseButton1Click:Connect(function()
    -- Limpa lista anterior
    for _, child in pairs(listaItensFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local itensEncontrados = {}
    if player:FindFirstChild("Backpack") then
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(itensEncontrados, item) end
        end
    end
    if player.Character then
        for _, item in pairs(player.Character:GetChildren()) do
            if item:IsA("Tool") then table.insert(itensEncontrados, item) end
        end
    end
    
    if #itensEncontrados == 0 then
        local txt = Instance.new("TextLabel", listaItensFrame)
        txt.Size = UDim2.new(1, 0, 0, 30)
        txt.BackgroundTransparency = 1
        txt.Text = "Nenhum item encontrado no momento."
        txt.TextColor3 = Color3.fromRGB(150, 150, 150)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 13
        return
    end
    
    for _, item in ipairs(itensEncontrados) do
        local frameItem = Instance.new("Frame", listaItensFrame)
        frameItem.Size = UDim2.new(1, 0, 0, 40)
        frameItem.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", frameItem).CornerRadius = UDim.new(0, 8)
        
        local nomeItem = Instance.new("TextLabel", frameItem)
        nomeItem.Size = UDim2.new(0.6, 0, 1, 0)
        nomeItem.Position = UDim2.new(0.05, 0, 0, 0)
        nomeItem.BackgroundTransparency = 1
        nomeItem.Text = item.Name
        nomeItem.TextColor3 = Color3.fromRGB(255, 255, 255)
        nomeItem.TextXAlignment = Enum.TextXAlignment.Left
        nomeItem.Font = Enum.Font.GothamSemibold
        nomeItem.TextSize = 13
        
        local btnHackItem = Instance.new("TextButton", frameItem)
        btnHackItem.Size = UDim2.new(0.3, 0, 0.8, 0)
        btnHackItem.Position = UDim2.new(0.65, 0, 0.1, 0)
        btnHackItem.BackgroundColor3 = corTema
        btnHackItem.Text = "Editar Local"
        btnHackItem.TextColor3 = Color3.fromRGB(0, 0, 0)
        btnHackItem.Font = Enum.Font.GothamBold
        btnHackItem.TextSize = 12
        Instance.new("UICorner", btnHackItem).CornerRadius = UDim.new(0, 6)
        
        btnHackItem.MouseButton1Click:Connect(function()
            -- Lógica de Hack do Item (Procura valores dentro dele e edita)
            local editouAlgo = false
            for _, prop in pairs(item:GetDescendants()) do
                if prop:IsA("NumberValue") or prop:IsA("IntValue") then
                    prop.Value = 99999
                    editouAlgo = true
                end
            end
            if editouAlgo then
                btnHackItem.Text = "Modificado!"
                btnHackItem.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            else
                btnHackItem.Text = "Sem Valores"
                btnHackItem.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            end
        end)
    end
end)

-- ==========================================
-- PÁGINA 3: CONFIGURAÇÕES DA INTERFACE
-- ==========================================
Instance.new("Frame", pageConfig).Size = UDim2.new(1,0,0,1)

local function criarTituloSecao(texto, parent)
    local txt = Instance.new("TextLabel", parent)
    txt.Size = UDim2.new(0.9, 0, 0, 25)
    txt.BackgroundTransparency = 1
    txt.Text = texto; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left
end

criarTituloSecao("Cor Principal do Hub:", pageConfig)
local cores = {
    {"Azul Neon", Color3.fromRGB(0, 170, 255)},
    {"Vermelho Sangue", Color3.fromRGB(255, 50, 50)},
    {"Verde Hacker", Color3.fromRGB(50, 255, 50)},
    {"Rosa Choque", Color3.fromRGB(255, 0, 255)}
}
for _, dados in ipairs(cores) do
    local btnCor = criarBotaoSimples(dados[1], pageConfig, dados[2])
    btnCor.Size = UDim2.new(0.9, 0, 0, 30); btnCor.TextColor3 = Color3.fromRGB(0,0,0)
    btnCor.MouseButton1Click:Connect(function()
        corTema = dados[2]; mainStroke.Color = corTema; inputVel.TextColor3 = corTema; inputPulo.TextColor3 = corTema
        for _, btn in pairs(tabBar:GetChildren()) do
            if btn:IsA("TextButton") and btn.Visible then
                if btn.TextColor3 ~= Color3.fromRGB(200,200,200) then btn.TextColor3 = corTema end
            end
        end
    end)
end

criarTituloSecao("Transparência do Fundo:", pageConfig)
local btnSido = criarBotaoSimples("Fundo Sólido (Normal)", pageConfig)
local btnTransp = criarBotaoSimples("Fundo Transparente (Vidro)", pageConfig)
btnSido.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0 end)
btnTransp.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.4 end)

criarTituloSecao("Estilo das Bordas:", pageConfig)
local btnOcultarBorda = criarBotaoSimples("Ligar/Desligar Linha Neon", pageConfig)
btnOcultarBorda.MouseButton1Click:Connect(function() mainStroke.Enabled = not mainStroke.Enabled end)

-- ==========================================
-- PÁGINA 4: SEGURANÇA (SCANNER)
-- ==========================================
Instance.new("Frame", pageSec).Size = UDim2.new(1,0,0,1)

local infoSec = Instance.new("TextLabel", pageSec)
infoSec.Size = UDim2.new(0.9, 0, 0, 60); infoSec.BackgroundTransparency = 1
infoSec.Text = "Este scanner verifica nomes de arquivos locais suspeitos. Ele não detecta anti-cheats de servidor!"
infoSec.TextColor3 = Color3.fromRGB(180, 180, 180); infoSec.TextWrapped = true
infoSec.Font = Enum.Font.Gotham; infoSec.TextSize = 12

local btnScan = criarBotaoSimples("Iniciar Verificação do Mapa", pageSec, Color3.fromRGB(80, 80, 80))
local resultadoSec = Instance.new("TextLabel", pageSec)
resultadoSec.Size = UDim2.new(0.9, 0, 0, 80); resultadoSec.BackgroundTransparency = 1
resultadoSec.Text = "Status: Aguardando verificação..."
resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 255); resultadoSec.TextWrapped = true
resultadoSec.Font = Enum.Font.GothamBold; resultadoSec.TextSize = 14

btnScan.MouseButton1Click:Connect(function()
    btnScan.Text = "Escaneando..."; resultadoSec.Text = "Procurando scripts suspeitos..."; resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 0)
    task.wait(1.5)
    local suspeito = false
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") then
            local nome = string.lower(v.Name)
            if string.find(nome, "anti") or string.find(nome, "cheat") or string.find(nome, "ban") or string.find(nome, "kick") then suspeito = true; break end
        end
    end
    btnScan.Text = "Refazer Verificação"
    if suspeito then
        resultadoSec.Text = "⚠️ ALERTA: Arquivos de Anti-Cheat detectados no cliente! Risco Alto."
        resultadoSec.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        resultadoSec.Text = "✅ Aparentemente Seguro: Nenhum sistema básico de Anti-Cheat local foi encontrado."
        resultadoSec.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

-- ==========================================
-- LÓGICA DA JANELA
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false; pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 480), "Out", "Quad", 0.3, true)
        tabBar.Visible = true; pageContainer.Visible = true
    end
end)
