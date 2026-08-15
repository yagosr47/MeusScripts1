-- ==========================================
-- Hub Universal V21 - INVENTÁRIO AVANÇADO & BUSCA GLOBAL (UI CORRIGIDA)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local esp1ItemAtivado = false
local espBuscaAtivada = false
local termoGlobalBusca = ""
local loopAtivo = true

local corTema = Color3.fromRGB(255, 50, 50) -- Tema Vermelho

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
-- Limpa versões antigas para evitar sobreposição
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "HubInventoryScanner" then v:Destroy() end
end
if player:FindFirstChild("PlayerGui") then
    for _, v in pairs(player.PlayerGui:GetChildren()) do
        if v.Name == "HubInventoryScanner" then v:Destroy() end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubInventoryScanner"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 460, 0, 420)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB INVENTÁRIOS V21"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- SISTEMA DE ABAS (BOTÕES EVIDENTES)
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 40); tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); tabBar.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal

local abas = {}
local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.3333, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Cor de fundo para parecer botão
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.LayoutOrder = ordem
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    
    table.insert(abas, btn)
    return btn
end

local tabEsp = criarAba("ESP (1 Item)", 1)
local tabScanner = criarAba("Scanner Geral", 2)
local tabBusca = criarAba("Busca Global", 3)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -75); pageContainer.Position = UDim2.new(0, 0, 0, 75)
pageContainer.BackgroundTransparency = 1

local pageEsp = Instance.new("Frame", pageContainer); pageEsp.Size = UDim2.new(1, 0, 1, 0); pageEsp.BackgroundTransparency = 1; pageEsp.Visible = true
local pageScanner = Instance.new("Frame", pageContainer); pageScanner.Size = UDim2.new(1, 0, 1, 0); pageScanner.BackgroundTransparency = 1; pageScanner.Visible = false
local pageBusca = Instance.new("Frame", pageContainer); pageBusca.Size = UDim2.new(1, 0, 1, 0); pageBusca.BackgroundTransparency = 1; pageBusca.Visible = false

local function resetTabs()
    for _, aba in pairs(abas) do
        aba.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        aba.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    pageEsp.Visible = false; pageScanner.Visible = false; pageBusca.Visible = false
end

local function ativarAba(btn, pagina)
    resetTabs()
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = corTema
    pagina.Visible = true
end

tabEsp.MouseButton1Click:Connect(function() ativarAba(tabEsp, pageEsp) end)
tabScanner.MouseButton1Click:Connect(function() ativarAba(tabScanner, pageScanner) end)
tabBusca.MouseButton1Click:Connect(function() ativarAba(tabBusca, pageBusca) end)

-- Ativa a primeira aba por padrão
ativarAba(tabEsp, pageEsp)

-- ==========================================
-- FUNÇÕES AUXILIARES E ESP
-- ==========================================
local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    btn.Position = UDim2.new(0.05, 0, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function obterInventarioAvançado(alvo)
    local itensData = {}
    local nomesRegistrados = {}

    local function adicionarItem(nome, tipoInv)
        if not nomesRegistrados[nome] then
            table.insert(itensData, {Nome = nome, Tipo = tipoInv})
            nomesRegistrados[nome] = true
        end
    end

    if alvo:FindFirstChild("Backpack") then
        for _, item in pairs(alvo.Backpack:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name, "Mochila") end
        end
    end
    if alvo.Character then
        for _, item in pairs(alvo.Character:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name, "Equipado") end
        end
    end

    local possiveisPastas = {"Inventory", "Inventario", "Items", "Bag", "Mochila", "Pets"}
    for _, nomePasta in ipairs(possiveisPastas) do
        local pasta = alvo:FindFirstChild(nomePasta)
        if pasta then
            for _, item in pairs(pasta:GetChildren()) do
                adicionarItem(item.Name, "Pasta: " .. nomePasta)
            end
        end
    end

    return itensData
end

local function gerenciarESP(alvo, ligar, textoCima, cor)
    if not alvo.Character or not alvo.Character:FindFirstChild("Head") then return end
    local char = alvo.Character
    local head = char.Head

    if char:FindFirstChild("ESP_Highlight_Hub") then char.ESP_Highlight_Hub:Destroy() end
    if head:FindFirstChild("ESP_Texto_Hub") then head.ESP_Texto_Hub:Destroy() end

    if ligar then
        local hl = Instance.new("Highlight", char)
        hl.Name = "ESP_Highlight_Hub"
        hl.FillColor = cor; hl.OutlineColor = cor
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0

        local espGui = Instance.new("BillboardGui", head)
        espGui.Name = "ESP_Texto_Hub"; espGui.Size = UDim2.new(0, 200, 0, 50)
        espGui.AlwaysOnTop = true; espGui.StudsOffset = Vector3.new(0, 2.5, 0)
        
        local txt = Instance.new("TextLabel", espGui)
        txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
        txt.TextColor3 = cor; txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold; txt.TextSize = 13
        txt.Text = textoCima
    end
end

local function limparTodosESPs()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then gerenciarESP(p, false) end
    end
end

-- Loop de Verificação Central
task.spawn(function()
    while task.wait(0.5) do
        if not loopAtivo then break end

        if esp1ItemAtivado or espBuscaAtivada then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local itens = obterInventarioAvançado(p)
                    local encontrouAlvo = false
                    
                    -- Prioridade 1: Busca Global
                    if espBuscaAtivada and termoGlobalBusca ~= "" then
                        local itemEncontradoBusca = nil
                        for _, itemData in ipairs(itens) do
                            if string.find(string.lower(itemData.Nome), termoGlobalBusca) then
                                itemEncontradoBusca = itemData.Nome
                                break
                            end
                        end
                        if itemEncontradoBusca then
                            encontrouAlvo = true
                            gerenciarESP(p, true, "["..p.Name.."]\nAchou: "..itemEncontradoBusca, Color3.fromRGB(255, 0, 0))
                        end
                    end

                    -- Prioridade 2: ESP 1 Item
                    if not encontrouAlvo and esp1ItemAtivado then
                        if #itens == 1 then
                            encontrouAlvo = true
                            gerenciarESP(p, true, "["..p.Name.."]\n1 Item: "..itens[1].Nome, Color3.fromRGB(255, 150, 0))
                        end
                    end

                    if not encontrouAlvo then gerenciarESP(p, false) end
                end
            end
        end
    end
end)

-- ==========================================
-- PÁGINA 1: ESP (APENAS 1 ITEM)
-- ==========================================
local espInfo = Instance.new("TextLabel", pageEsp)
espInfo.Size = UDim2.new(0.9, 0, 0, 60); espInfo.Position = UDim2.new(0.05, 0, 0.05, 0)
espInfo.BackgroundTransparency = 1; espInfo.TextWrapped = true
espInfo.Text = "Revela jogadores com EXATAMENTE 1 item (qualquer tipo de inventário). O jogador ficará Laranja."
espInfo.TextColor3 = Color3.fromRGB(200, 200, 200); espInfo.Font = Enum.Font.Gotham; espInfo.TextSize = 13

local btnAtivarEsp = criarBotaoSimples("Ligar ESP (1 Item)", pageEsp, Color3.fromRGB(150, 100, 50))
btnAtivarEsp.Position = UDim2.new(0.05, 0, 0.35, 0)

btnAtivarEsp.MouseButton1Click:Connect(function()
    esp1ItemAtivado = not esp1ItemAtivado
    btnAtivarEsp.Text = esp1ItemAtivado and "Desligar ESP (1 Item)" or "Ligar ESP (1 Item)"
    btnAtivarEsp.BackgroundColor3 = esp1ItemAtivado and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(150, 100, 50)
    if not esp1ItemAtivado and not espBuscaAtivada then limparTodosESPs() end
end)

-- ==========================================
-- PÁGINA 2: SCANNER DE INVENTÁRIOS
-- ==========================================
local btnAtualizarPlayers = criarBotaoSimples("Atualizar Jogadores", pageScanner, Color3.fromRGB(0, 150, 100))
btnAtualizarPlayers.Position = UDim2.new(0.05, 0, 0.05, 0)

local listaJogadoresFrame = Instance.new("ScrollingFrame", pageScanner)
listaJogadoresFrame.Size = UDim2.new(0.9, 0, 0.7, 0); listaJogadoresFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
listaJogadoresFrame.BackgroundTransparency = 1; listaJogadoresFrame.ScrollBarThickness = 4
local listaLayout = Instance.new("UIListLayout", listaJogadoresFrame); listaLayout.Padding = UDim.new(0, 5)

local itensContainer = Instance.new("Frame", pageScanner)
itensContainer.Size = UDim2.new(1, 0, 1, 0); itensContainer.BackgroundTransparency = 1; itensContainer.Visible = false

local btnVoltar = criarBotaoSimples("← Voltar", itensContainer, Color3.fromRGB(80, 80, 80))
btnVoltar.Position = UDim2.new(0.05, 0, 0.05, 0)

local listaItensScroll = Instance.new("ScrollingFrame", itensContainer)
listaItensScroll.Size = UDim2.new(0.9, 0, 0.7, 0); listaItensScroll.Position = UDim2.new(0.05, 0, 0.22, 0)
listaItensScroll.BackgroundTransparency = 1; listaItensScroll.ScrollBarThickness = 4
local itensLayout = Instance.new("UIListLayout", listaItensScroll); itensLayout.Padding = UDim.new(0, 5)

btnAtualizarPlayers.MouseButton1Click:Connect(function()
    for _, child in pairs(listaJogadoresFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btnPlayer = Instance.new("TextButton", listaJogadoresFrame)
            btnPlayer.Size = UDim2.new(1, 0, 0, 35); btnPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btnPlayer.Text = p.Name .. " (" .. #obterInventarioAvançado(p) .. " Itens)"
            btnPlayer.TextColor3 = Color3.fromRGB(255, 255, 255); btnPlayer.Font = Enum.Font.GothamBold
            Instance.new("UICorner", btnPlayer).CornerRadius = UDim.new(0, 6)
            
            btnPlayer.MouseButton1Click:Connect(function()
                btnAtualizarPlayers.Visible = false; listaJogadoresFrame.Visible = false; itensContainer.Visible = true
                for _, child in pairs(listaItensScroll:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
                
                local itens = obterInventarioAvançado(p)
                for _, itemData in ipairs(itens) do
                    local lblItem = Instance.new("TextLabel", listaItensScroll)
                    lblItem.Size = UDim2.new(1, 0, 0, 30); lblItem.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    lblItem.Text = " [" .. itemData.Tipo .. "] " .. itemData.Nome
                    lblItem.TextColor3 = Color3.fromRGB(200, 200, 255); lblItem.TextXAlignment = Enum.TextXAlignment.Left
                    lblItem.Font = Enum.Font.Gotham; lblItem.TextSize = 13
                    Instance.new("UICorner", lblItem).CornerRadius = UDim.new(0, 6)
                end
            end)
        end
    end
end)

btnVoltar.MouseButton1Click:Connect(function()
    itensContainer.Visible = false; btnAtualizarPlayers.Visible = true; listaJogadoresFrame.Visible = true
end)

-- ==========================================
-- PÁGINA 3: BUSCA GLOBAL (ESP DE ITEM ESPECÍFICO)
-- ==========================================
local buscaInfo = Instance.new("TextLabel", pageBusca)
buscaInfo.Size = UDim2.new(0.9, 0, 0, 60); buscaInfo.Position = UDim2.new(0.05, 0, 0.05, 0)
buscaInfo.BackgroundTransparency = 1; buscaInfo.TextWrapped = true
buscaInfo.Text = "Digite o nome de um item. Qualquer jogador no mapa que possuir este item ficará VERMELHO."
buscaInfo.TextColor3 = Color3.fromRGB(200, 200, 200); buscaInfo.Font = Enum.Font.Gotham; buscaInfo.TextSize = 13

local inputGlobalBusca = Instance.new("TextBox", pageBusca)
inputGlobalBusca.Size = UDim2.new(0.9, 0, 0, 40); inputGlobalBusca.Position = UDim2.new(0.05, 0, 0.28, 0)
inputGlobalBusca.BackgroundColor3 = Color3.fromRGB(40, 40, 40); inputGlobalBusca.PlaceholderText = "Digite o item aqui (Ex: Gun, Key...)"
inputGlobalBusca.Text = ""; inputGlobalBusca.TextColor3 = Color3.fromRGB(255, 255, 255)
inputGlobalBusca.Font = Enum.Font.GothamBold; inputGlobalBusca.TextSize = 14
Instance.new("UICorner", inputGlobalBusca).CornerRadius = UDim.new(0, 6)

local btnAtivarBusca = criarBotaoSimples("Ligar ESP de Busca", pageBusca, Color3.fromRGB(150, 50, 50))
btnAtivarBusca.Position = UDim2.new(0.05, 0, 0.45, 0)

-- Atualiza em tempo real enquanto digita
inputGlobalBusca:GetPropertyChangedSignal("Text"):Connect(function()
    termoGlobalBusca = string.lower(inputGlobalBusca.Text)
    if inputGlobalBusca.Text == "" and espBuscaAtivada then
        limparTodosESPs() -- Limpa a tela se apagar tudo
    end
end)

btnAtivarBusca.MouseButton1Click:Connect(function()
    espBuscaAtivada = not espBuscaAtivada
    if espBuscaAtivada then
        termoGlobalBusca = string.lower(inputGlobalBusca.Text)
        btnAtivarBusca.Text = "Desligar ESP de Busca"
        btnAtivarBusca.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        btnAtivarBusca.Text = "Ligar ESP de Busca"
        btnAtivarBusca.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if not esp1ItemAtivado then limparTodosESPs() end
    end
end)

-- ==========================================
-- LÓGICA GERAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() 
    loopAtivo = false
    limparTodosESPs()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 460, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false; pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 460, 0, 420), "Out", "Quad", 0.3, true)
        tabBar.Visible = true; pageContainer.Visible = true
    end
end)
