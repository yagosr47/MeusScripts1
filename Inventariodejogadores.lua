-- ==========================================
-- Hub Universal V22 - SCANNER MULTI-INVENTÁRIO E BUSCA
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
local espBuscaAtivado = false
local espConnection = nil
local espBuscaConnection = nil

local corTema = Color3.fromRGB(255, 50, 50)

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubInventoryScannerV22"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 400)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
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

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB INVENTÁRIOS V22"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- SISTEMA DE ABAS E PÁGINAS
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35); tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); tabBar.BorderSizePixel = 0
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    return btn
end

local tabEsp1 = criarAba("ESP (1 Item)", 1)
local tabEspBusca = criarAba("Buscar Item", 2)
local tabScanner = criarAba("Scanner Completo", 3)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local pageEsp1 = Instance.new("Frame", pageContainer); pageEsp1.Size = UDim2.new(1, 0, 1, 0); pageEsp1.BackgroundTransparency = 1; pageEsp1.Visible = true
local pageEspBusca = Instance.new("Frame", pageContainer); pageEspBusca.Size = UDim2.new(1, 0, 1, 0); pageEspBusca.BackgroundTransparency = 1; pageEspBusca.Visible = false
local pageScanner = Instance.new("Frame", pageContainer); pageScanner.Size = UDim2.new(1, 0, 1, 0); pageScanner.BackgroundTransparency = 1; pageScanner.Visible = false

local function mudarAba(abaAtiva, paginaAtiva)
    tabEsp1.TextColor3 = Color3.fromRGB(200, 200, 200); tabEspBusca.TextColor3 = Color3.fromRGB(200, 200, 200); tabScanner.TextColor3 = Color3.fromRGB(200, 200, 200)
    pageEsp1.Visible = false; pageEspBusca.Visible = false; pageScanner.Visible = false
    abaAtiva.TextColor3 = corTema; paginaAtiva.Visible = true
end

tabEsp1.MouseButton1Click:Connect(function() mudarAba(tabEsp1, pageEsp1) end)
tabEspBusca.MouseButton1Click:Connect(function() mudarAba(tabEspBusca, pageEspBusca) end)
tabScanner.MouseButton1Click:Connect(function() mudarAba(tabScanner, pageScanner) end)
tabEsp1.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES AUXILIARES E LÓGICA DE INVENTÁRIO
-- ==========================================
local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    btn.Position = UDim2.new(0.05, 0, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- NOVO: Sistema de busca profunda de itens (Clássico + Pastas Customizadas)
local function obterItensJogador(alvo)
    local itensDetectados = {}
    local nomesAdicionados = {}
    local tipoInventario = "Nenhum detectado"

    local function adicionarItem(nome)
        if not nomesAdicionados[nome] then
            table.insert(itensDetectados, {Name = nome})
            nomesAdicionados[nome] = true
        end
    end

    -- 1. Verificação de Inventário Clássico
    local achouClassico = false
    if alvo:FindFirstChild("Backpack") then
        for _, item in pairs(alvo.Backpack:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name); achouClassico = true end
        end
    end
    if alvo.Character then
        for _, item in pairs(alvo.Character:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name); achouClassico = true end
        end
    end
    if achouClassico then tipoInventario = "Inventário Clássico (Ferramentas)" end

    -- 2. Verificação de Inventário Customizado (Pastas de Dados)
    local pastasComuns = {"Inventory", "Itens", "Items", "Data", "leaderstats", "BackpackData", "PlayerData"}
    local achouCustom = false
    for _, nomePasta in ipairs(pastasComuns) do
        local pasta = alvo:FindFirstChild(nomePasta)
        if pasta then
            for _, obj in pairs(pasta:GetChildren()) do
                if obj:IsA("ValueBase") or obj:IsA("Model") or obj:IsA("Folder") then
                    adicionarItem(obj.Name)
                    achouCustom = true
                end
            end
        end
    end
    
    if achouCustom and not achouClassico then tipoInventario = "Customizado (Dados/Valores)"
    elseif achouCustom and achouClassico then tipoInventario = "Misto (Clássico + Dados)" end

    return itensDetectados, tipoInventario
end

local function limparTodosESPs()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight:Destroy() end
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESP_Tag") then p.Character.Head.ESP_Tag:Destroy() end
        end
    end
end

local function aplicarESPVermelho(char, nomeJogador, nomeItem)
    if not char then return end
    local head = char:FindFirstChild("Head")
    
    if not char:FindFirstChild("ESP_Highlight") then
        local hl = Instance.new("Highlight", char)
        hl.Name = "ESP_Highlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    if head then
        local espGui = head:FindFirstChild("ESP_Tag")
        if not espGui then
            espGui = Instance.new("BillboardGui", head)
            espGui.Name = "ESP_Tag"
            espGui.Size = UDim2.new(0, 200, 0, 50)
            espGui.AlwaysOnTop = true
            espGui.StudsOffset = Vector3.new(0, 2, 0)
            
            local txt = Instance.new("TextLabel", espGui)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 50, 50)
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 13
        end
        espGui.TextLabel.Text = "[ " .. nomeJogador .. " ]\nItem: " .. nomeItem
    end
end

local function removerESP(char)
    if char then
        if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
        if char:FindFirstChild("Head") and char.Head:FindFirstChild("ESP_Tag") then char.Head.ESP_Tag:Destroy() end
    end
end

-- ==========================================
-- PÁGINA 1: ESP (APENAS 1 ITEM)
-- ==========================================
local espInfo1 = Instance.new("TextLabel", pageEsp1)
espInfo1.Size = UDim2.new(0.9, 0, 0, 60); espInfo1.Position = UDim2.new(0.05, 0, 0.1, 0)
espInfo1.BackgroundTransparency = 1; espInfo1.TextWrapped = true
espInfo1.Text = "Revela jogadores que possuem EXATAMENTE 1 item no inventário."
espInfo1.TextColor3 = Color3.fromRGB(200, 200, 200); espInfo1.Font = Enum.Font.Gotham; espInfo1.TextSize = 12

local btnAtivarEsp1 = criarBotaoSimples("Ligar ESP (1 Item)", pageEsp1, Color3.fromRGB(150, 50, 50))
btnAtivarEsp1.Position = UDim2.new(0.05, 0, 0.4, 0)

btnAtivarEsp1.MouseButton1Click:Connect(function()
    esp1ItemAtivado = not esp1ItemAtivado
    if esp1ItemAtivado and espBuscaAtivado then
        espBuscaAtivado = false -- Desativa o outro pra não dar conflito
        if espBuscaConnection then espBuscaConnection:Disconnect(); espBuscaConnection = nil end
    end
    
    btnAtivarEsp1.Text = esp1ItemAtivado and "Desligar ESP (1 Item)" or "Ligar ESP (1 Item)"
    btnAtivarEsp1.BackgroundColor3 = esp1ItemAtivado and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(150, 50, 50)
    
    if esp1ItemAtivado then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local itens = obterItensJogador(p)
                    if #itens == 1 then
                        aplicarESPVermelho(p.Character, p.Name, itens[1].Name)
                    else
                        removerESP(p.Character)
                    end
                end
            end
        end)
    else
        if espConnection then espConnection:Disconnect(); espConnection = nil end
        limparTodosESPs()
    end
end)

-- ==========================================
-- PÁGINA 2: ESP POR BUSCA DE ITEM
-- ==========================================
local espBuscaInfo = Instance.new("TextLabel", pageEspBusca)
espBuscaInfo.Size = UDim2.new(0.9, 0, 0, 60); espBuscaInfo.Position = UDim2.new(0.05, 0, 0.05, 0)
espBuscaInfo.BackgroundTransparency = 1; espBuscaInfo.TextWrapped = true
espBuscaInfo.Text = "Digite o nome de um item. Qualquer jogador no servidor que tiver esse item no inventário ficará destacado em vermelho."
espBuscaInfo.TextColor3 = Color3.fromRGB(200, 200, 200); espBuscaInfo.Font = Enum.Font.Gotham; espBuscaInfo.TextSize = 12

local inputBuscaGlobal = Instance.new("TextBox", pageEspBusca)
inputBuscaGlobal.Size = UDim2.new(0.9, 0, 0, 35); inputBuscaGlobal.Position = UDim2.new(0.05, 0, 0.3, 0)
inputBuscaGlobal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputBuscaGlobal.PlaceholderText = "Ex: Espada Mágica..."
inputBuscaGlobal.Text = ""; inputBuscaGlobal.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBuscaGlobal.Font = Enum.Font.Gotham; inputBuscaGlobal.TextSize = 14
Instance.new("UICorner", inputBuscaGlobal).CornerRadius = UDim.new(0, 6)

local btnAtivarEspBusca = criarBotaoSimples("Ligar ESP por Item", pageEspBusca, Color3.fromRGB(150, 100, 50))
btnAtivarEspBusca.Position = UDim2.new(0.05, 0, 0.5, 0)

btnAtivarEspBusca.MouseButton1Click:Connect(function()
    espBuscaAtivado = not espBuscaAtivado
    if espBuscaAtivado and esp1ItemAtivado then
        esp1ItemAtivado = false -- Desliga o ESP de 1 item
        btnAtivarEsp1.Text = "Ligar ESP (1 Item)"
        btnAtivarEsp1.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if espConnection then espConnection:Disconnect(); espConnection = nil end
    end

    btnAtivarEspBusca.Text = espBuscaAtivado and "Desligar ESP por Item" or "Ligar ESP por Item"
    btnAtivarEspBusca.BackgroundColor3 = espBuscaAtivado and Color3.fromRGB(255, 150, 50) or Color3.fromRGB(150, 100, 50)
    
    if espBuscaAtivado then
        espBuscaConnection = RunService.RenderStepped:Connect(function()
            local termoBusca = string.lower(inputBuscaGlobal.Text)
            if termoBusca == "" then limparTodosESPs(); return end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local itens = obterItensJogador(p)
                    local itemEncontrado = nil
                    
                    for _, it in ipairs(itens) do
                        if string.find(string.lower(it.Name), termoBusca) then
                            itemEncontrado = it.Name
                            break
                        end
                    end
                    
                    if itemEncontrado then
                        aplicarESPVermelho(p.Character, p.Name, itemEncontrado)
                    else
                        removerESP(p.Character)
                    end
                end
            end
        end)
    else
        if espBuscaConnection then espBuscaConnection:Disconnect(); espBuscaConnection = nil end
        limparTodosESPs()
    end
end)

-- ==========================================
-- PÁGINA 3: SCANNER DE INVENTÁRIOS (GERAL)
-- ==========================================
local btnAtualizarPlayers = criarBotaoSimples("Atualizar Lista de Jogadores", pageScanner, Color3.fromRGB(0, 150, 100))
btnAtualizarPlayers.Position = UDim2.new(0.05, 0, 0.05, 0)

local listaJogadoresFrame = Instance.new("ScrollingFrame", pageScanner)
listaJogadoresFrame.Size = UDim2.new(0.9, 0, 0.7, 0); listaJogadoresFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
listaJogadoresFrame.BackgroundTransparency = 1; listaJogadoresFrame.ScrollBarThickness = 4
local listaLayout = Instance.new("UIListLayout", listaJogadoresFrame); listaLayout.Padding = UDim.new(0, 5)

local itensContainer = Instance.new("Frame", pageScanner)
itensContainer.Size = UDim2.new(1, 0, 1, 0); itensContainer.BackgroundTransparency = 1; itensContainer.Visible = false

local btnVoltar = criarBotaoSimples("← Voltar para Lista", itensContainer, Color3.fromRGB(80, 80, 80))
btnVoltar.Position = UDim2.new(0.05, 0, 0.05, 0)

local tipoInvLabel = Instance.new("TextLabel", itensContainer)
tipoInvLabel.Size = UDim2.new(0.9, 0, 0, 20); tipoInvLabel.Position = UDim2.new(0.05, 0, 0.17, 0)
tipoInvLabel.BackgroundTransparency = 1; tipoInvLabel.TextXAlignment = Enum.TextXAlignment.Left
tipoInvLabel.TextColor3 = Color3.fromRGB(150, 255, 150); tipoInvLabel.Font = Enum.Font.Gotham; tipoInvLabel.TextSize = 12

local inputPesquisa = Instance.new("TextBox", itensContainer)
inputPesquisa.Size = UDim2.new(0.9, 0, 0, 30); inputPesquisa.Position = UDim2.new(0.05, 0, 0.25, 0)
inputPesquisa.BackgroundColor3 = Color3.fromRGB(30, 30, 30); inputPesquisa.PlaceholderText = "Filtrar item na lista..."
inputPesquisa.Text = ""; inputPesquisa.TextColor3 = Color3.fromRGB(255, 255, 255)
inputPesquisa.Font = Enum.Font.Gotham; inputPesquisa.TextSize = 13
Instance.new("UICorner", inputPesquisa).CornerRadius = UDim.new(0, 6)

local listaItensScroll = Instance.new("ScrollingFrame", itensContainer)
listaItensScroll.Size = UDim2.new(0.9, 0, 0.55, 0); listaItensScroll.Position = UDim2.new(0.05, 0, 0.38, 0)
listaItensScroll.BackgroundTransparency = 1; listaItensScroll.ScrollBarThickness = 4
local itensLayout = Instance.new("UIListLayout", listaItensScroll); itensLayout.Padding = UDim.new(0, 5)

local jogadorAtualSelecionado = nil

btnAtualizarPlayers.MouseButton1Click:Connect(function()
    for _, child in pairs(listaJogadoresFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btnPlayer = Instance.new("TextButton", listaJogadoresFrame)
            btnPlayer.Size = UDim2.new(1, 0, 0, 35); btnPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            
            local itens, _ = obterItensJogador(p)
            btnPlayer.Text = p.Name .. " (" .. #itens .. " Itens)"
            btnPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnPlayer.Font = Enum.Font.GothamSemibold
            Instance.new("UICorner", btnPlayer).CornerRadius = UDim.new(0, 6)
            
            btnPlayer.MouseButton1Click:Connect(function()
                jogadorAtualSelecionado = p
                btnAtualizarPlayers.Visible = false
                listaJogadoresFrame.Visible = false
                itensContainer.Visible = true
                inputPesquisa.Text = ""
                carregarItensNaLista()
            end)
        end
    end
end)

function carregarItensNaLista()
    for _, child in pairs(listaItensScroll:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
    
    if not jogadorAtualSelecionado or not jogadorAtualSelecionado.Parent then
        local aviso = Instance.new("TextLabel", listaItensScroll)
        aviso.Size = UDim2.new(1, 0, 0, 30); aviso.BackgroundTransparency = 1
        aviso.Text = "Jogador saiu do jogo."; aviso.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    local itens, tipoInv = obterItensJogador(jogadorAtualSelecionado)
    tipoInvLabel.Text = "Sistema Detectado: " .. tipoInv
    local termoPesquisa = string.lower(inputPesquisa.Text)
    local encontrouAlgum = false

    for _, item in ipairs(itens) do
        if termoPesquisa == "" or string.find(string.lower(item.Name), termoPesquisa) then
            encontrouAlgum = true
            local lblItem = Instance.new("TextLabel", listaItensScroll)
            lblItem.Size = UDim2.new(1, 0, 0, 30); lblItem.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            lblItem.Text = " 📦 " .. item.Name; lblItem.TextColor3 = Color3.fromRGB(200, 200, 255)
            lblItem.TextXAlignment = Enum.TextXAlignment.Left; lblItem.Font = Enum.Font.Gotham; lblItem.TextSize = 13
            Instance.new("UICorner", lblItem).CornerRadius = UDim.new(0, 6)
        end
    end
    
    if not encontrouAlgum then
        local aviso = Instance.new("TextLabel", listaItensScroll)
        aviso.Size = UDim2.new(1, 0, 0, 30); aviso.BackgroundTransparency = 1
        aviso.Text = "Nenhum item encontrado."; aviso.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

inputPesquisa:GetPropertyChangedSignal("Text"):Connect(carregarItensNaLista)

btnVoltar.MouseButton1Click:Connect(function()
    itensContainer.Visible = false
    btnAtualizarPlayers.Visible = true
    listaJogadoresFrame.Visible = true
    jogadorAtualSelecionado = nil
end)

-- ==========================================
-- LÓGICA GERAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() 
    if espConnection then espConnection:Disconnect() end
    if espBuscaConnection then espBuscaConnection:Disconnect() end
    limparTodosESPs()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 450, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false; pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 450, 0, 400), "Out", "Quad", 0.3, true)
        tabBar.Visible = true; pageContainer.Visible = true
    end
end)
