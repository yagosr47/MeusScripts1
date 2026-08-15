-- ==========================================
-- Hub Universal V23 - ESP DE CARGOS E MULTI-INVENTÁRIO
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
local espTitulosAtivado = false

local espConnection1Item = nil
local espConnectionBusca = nil
local espConnectionTitulos = nil

local corTema = Color3.fromRGB(255, 50, 50)

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubInventoryScannerV23"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 400)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -200)
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
titleText.Text = "HUB V23 - CARGOS E INVENTÁRIOS"
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
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.82, 0, 0.1, 0)
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
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    return btn
end

local tabEsp1 = criarAba("ESP 1 Item", 1)
local tabEspBusca = criarAba("Busca Item", 2)
local tabEspTitulos = criarAba("Cargos", 3)
local tabScanner = criarAba("Scanner", 4)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local pageEsp1 = Instance.new("Frame", pageContainer); pageEsp1.Size = UDim2.new(1, 0, 1, 0); pageEsp1.BackgroundTransparency = 1; pageEsp1.Visible = true
local pageEspBusca = Instance.new("Frame", pageContainer); pageEspBusca.Size = UDim2.new(1, 0, 1, 0); pageEspBusca.BackgroundTransparency = 1; pageEspBusca.Visible = false
local pageEspTitulos = Instance.new("Frame", pageContainer); pageEspTitulos.Size = UDim2.new(1, 0, 1, 0); pageEspTitulos.BackgroundTransparency = 1; pageEspTitulos.Visible = false
local pageScanner = Instance.new("Frame", pageContainer); pageScanner.Size = UDim2.new(1, 0, 1, 0); pageScanner.BackgroundTransparency = 1; pageScanner.Visible = false

local function mudarAba(abaAtiva, paginaAtiva)
    tabEsp1.TextColor3 = Color3.fromRGB(200, 200, 200); tabEspBusca.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabEspTitulos.TextColor3 = Color3.fromRGB(200, 200, 200); tabScanner.TextColor3 = Color3.fromRGB(200, 200, 200)
    pageEsp1.Visible = false; pageEspBusca.Visible = false; pageEspTitulos.Visible = false; pageScanner.Visible = false
    abaAtiva.TextColor3 = corTema; paginaAtiva.Visible = true
end

tabEsp1.MouseButton1Click:Connect(function() mudarAba(tabEsp1, pageEsp1) end)
tabEspBusca.MouseButton1Click:Connect(function() mudarAba(tabEspBusca, pageEspBusca) end)
tabEspTitulos.MouseButton1Click:Connect(function() mudarAba(tabEspTitulos, pageEspTitulos) end)
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

local function obterItensJogador(alvo)
    local itensDetectados = {}
    local nomesAdicionados = {}
    local function adicionarItem(nome)
        if not nomesAdicionados[nome] then table.insert(itensDetectados, {Name = nome}); nomesAdicionados[nome] = true end
    end

    if alvo:FindFirstChild("Backpack") then
        for _, item in pairs(alvo.Backpack:GetChildren()) do if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name) end end
    end
    if alvo.Character then
        for _, item in pairs(alvo.Character:GetChildren()) do if item:IsA("Tool") or item:IsA("HopperBin") then adicionarItem(item.Name) end end
    end

    local pastasComuns = {"Inventory", "Itens", "Items", "Data", "leaderstats"}
    for _, nomePasta in ipairs(pastasComuns) do
        local pasta = alvo:FindFirstChild(nomePasta)
        if pasta then
            for _, obj in pairs(pasta:GetChildren()) do if obj:IsA("ValueBase") or obj:IsA("Model") or obj:IsA("Folder") then adicionarItem(obj.Name) end end
        end
    end
    return itensDetectados
end

-- ==========================================
-- NOVA LÓGICA: IDENTIFICAR CARGOS/TÍTULOS
-- ==========================================
local function tentarDescobrirCargo(alvo)
    local cargoDetectado = "Inocente / Sem Título"
    
    -- 1. Tentar pegar por "Team" (Jogos clássicos)
    if alvo.Team then cargoDetectado = alvo.Team.Name end
    
    -- 2. Procurar em Strings ocultas
    local nomesDesejados = {"role", "title", "cargo", "classe", "job"}
    local locaisBusca = {alvo, alvo:FindFirstChild("leaderstats")}
    
    for _, localBusca in pairs(locaisBusca) do
        if localBusca then
            for _, obj in pairs(localBusca:GetChildren()) do
                if obj:IsA("StringValue") then
                    for _, nomeP em ipairs(nomesDesejados) do
                        if string.lower(obj.Name) == nomeP then return obj.Value end
                    end
                end
            end
        end
    end
    
    -- 3. Heurística secreta via itens (Dedução)
    local itens = obterItensJogador(alvo)
    for _, item in ipairs(itens) do
        local n = string.lower(item.Name)
        if string.find(n, "knife") or string.find(n, "faca") or string.find(n, "espada") then return "Assassino/Murderer" end
        if string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "arma") then return "Xerife/Sheriff" end
        if string.find(n, "deathnote") or string.find(n, "kira") then return "Kira" end
    end
    
    return cargoDetectado
end

-- ==========================================
-- FUNÇÕES DE ESP E EXCLUSIVIDADE
-- ==========================================
local function limparTodosESPs()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight:Destroy() end
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESP_Tag") then p.Character.Head.ESP_Tag:Destroy() end
        end
    end
end

local function aplicarESPVermelho(char, nomeJogador, textoAdicional)
    if not char then return end
    local head = char:FindFirstChild("Head")
    
    if not char:FindFirstChild("ESP_Highlight") then
        local hl = Instance.new("Highlight", char); hl.Name = "ESP_Highlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    if head then
        local espGui = head:FindFirstChild("ESP_Tag")
        if not espGui then
            espGui = Instance.new("BillboardGui", head); espGui.Name = "ESP_Tag"
            espGui.Size = UDim2.new(0, 200, 0, 50); espGui.AlwaysOnTop = true; espGui.StudsOffset = Vector3.new(0, 2, 0)
            
            local txt = Instance.new("TextLabel", espGui); txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.fromRGB(255, 50, 50)
            txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.GothamBold; txt.TextSize = 13
        end
        espGui.TextLabel.Text = "[ " .. nomeJogador .. " ]\n" .. textoAdicional
    end
end

local function desativarOutrosESPs()
    esp1ItemAtivado = false; espBuscaAtivado = false; espTitulosAtivado = false
    if espConnection1Item then espConnection1Item:Disconnect(); espConnection1Item = nil end
    if espConnectionBusca then espConnectionBusca:Disconnect(); espConnectionBusca = nil end
    if espConnectionTitulos then espConnectionTitulos:Disconnect(); espConnectionTitulos = nil end
    limparTodosESPs()
end

-- ==========================================
-- LÓGICA DAS ABAS DE ESP
-- ==========================================
-- BOTÃO ESP 1 ITEM
local btnAtivarEsp1 = criarBotaoSimples("Ligar ESP (1 Item)", pageEsp1, Color3.fromRGB(150, 50, 50))
btnAtivarEsp1.Position = UDim2.new(0.05, 0, 0.2, 0)
local lblEsp1 = Instance.new("TextLabel", pageEsp1); lblEsp1.Size = UDim2.new(0.9, 0, 0, 40); lblEsp1.Position = UDim2.new(0.05, 0, 0.05, 0); lblEsp1.BackgroundTransparency = 1; lblEsp1.TextColor3 = Color3.fromRGB(200,200,200); lblEsp1.TextWrapped = true; lblEsp1.Text = "Revela quem possui EXATAMENTE 1 item."

btnAtivarEsp1.MouseButton1Click:Connect(function()
    local estavaAtivado = esp1ItemAtivado
    desativarOutrosESPs()
    
    if not estavaAtivado then
        esp1ItemAtivado = true; btnAtivarEsp1.Text = "LIGADO (ESP 1 Item)"; btnAtivarEsp1.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        espConnection1Item = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local itens = obterItensJogador(p)
                    if #itens == 1 then aplicarESPVermelho(p.Character, p.Name, "Item: " .. itens[1].Name) else p.Character:FindFirstChild("ESP_Highlight") end
                end
            end
        end)
    else btnAtivarEsp1.Text = "Ligar ESP (1 Item)"; btnAtivarEsp1.BackgroundColor3 = Color3.fromRGB(150, 50, 50) end
end)

-- BOTÃO ESP BUSCA
local inputBuscaGlobal = Instance.new("TextBox", pageEspBusca)
inputBuscaGlobal.Size = UDim2.new(0.9, 0, 0, 35); inputBuscaGlobal.Position = UDim2.new(0.05, 0, 0.05, 0)
inputBuscaGlobal.BackgroundColor3 = Color3.fromRGB(30, 30, 30); inputBuscaGlobal.PlaceholderText = "Ex: Espada Mágica..."; inputBuscaGlobal.Text = ""; inputBuscaGlobal.TextColor3 = Color3.fromRGB(255, 255, 255)
local btnAtivarEspBusca = criarBotaoSimples("Ligar ESP por Item", pageEspBusca, Color3.fromRGB(150, 100, 50))
btnAtivarEspBusca.Position = UDim2.new(0.05, 0, 0.25, 0)

btnAtivarEspBusca.MouseButton1Click:Connect(function()
    local estavaAtivado = espBuscaAtivado
    desativarOutrosESPs(); btnAtivarEsp1.Text = "Ligar ESP (1 Item)"; btnAtivarEsp1.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    
    if not estavaAtivado then
        espBuscaAtivado = true; btnAtivarEspBusca.Text = "LIGADO (Busca)"; btnAtivarEspBusca.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        espConnectionBusca = RunService.RenderStepped:Connect(function()
            local termo = string.lower(inputBuscaGlobal.Text)
            if termo == "" then limparTodosESPs(); return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local itens = obterItensJogador(p); local achou = nil
                    for _, it in ipairs(itens) do if string.find(string.lower(it.Name), termo) then achou = it.Name; break end end
                    if achou then aplicarESPVermelho(p.Character, p.Name, achou) end
                end
            end
        end)
    else btnAtivarEspBusca.Text = "Ligar ESP por Item"; btnAtivarEspBusca.BackgroundColor3 = Color3.fromRGB(150, 100, 50) end
end)

-- BOTÃO ESP TÍTULOS / CARGOS
local lblEspTitulos = Instance.new("TextLabel", pageEspTitulos); lblEspTitulos.Size = UDim2.new(0.9, 0, 0, 60); lblEspTitulos.Position = UDim2.new(0.05, 0, 0.05, 0); lblEspTitulos.BackgroundTransparency = 1; lblEspTitulos.TextColor3 = Color3.fromRGB(200,200,200); lblEspTitulos.TextWrapped = true; lblEspTitulos.Text = "Escaneia times, dados ocultos e itens para descobrir se o jogador é Inocente, Impostor, Murderer, Xerife, Kira, L, etc."
local btnAtivarEspTitulos = criarBotaoSimples("Ligar ESP de Cargos", pageEspTitulos, Color3.fromRGB(100, 50, 150))
btnAtivarEspTitulos.Position = UDim2.new(0.05, 0, 0.3, 0)

btnAtivarEspTitulos.MouseButton1Click:Connect(function()
    local estavaAtivado = espTitulosAtivado
    desativarOutrosESPs(); btnAtivarEsp1.Text = "Ligar ESP (1 Item)"; btnAtivarEsp1.BackgroundColor3 = Color3.fromRGB(150, 50, 50); btnAtivarEspBusca.Text = "Ligar ESP por Item"; btnAtivarEspBusca.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    
    if not estavaAtivado then
        espTitulosAtivado = true; btnAtivarEspTitulos.Text = "LIGADO (ESP Cargos)"; btnAtivarEspTitulos.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
        espConnectionTitulos = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local cargoStr = tentarDescobrirCargo(p)
                    aplicarESPVermelho(p.Character, p.Name, cargoStr)
                end
            end
        end)
    else btnAtivarEspTitulos.Text = "Ligar ESP de Cargos"; btnAtivarEspTitulos.BackgroundColor3 = Color3.fromRGB(100, 50, 150) end
end)

-- ==========================================
-- PÁGINA 4: SCANNER GERAL
-- ==========================================
local btnAtualizarPlayers = criarBotaoSimples("Atualizar Lista de Jogadores", pageScanner, Color3.fromRGB(0, 150, 100))
local listaJogadoresFrame = Instance.new("ScrollingFrame", pageScanner); listaJogadoresFrame.Size = UDim2.new(0.9, 0, 0.7, 0); listaJogadoresFrame.Position = UDim2.new(0.05, 0, 0.2, 0); listaJogadoresFrame.BackgroundTransparency = 1; listaJogadoresFrame.ScrollBarThickness = 4; local listaLayout = Instance.new("UIListLayout", listaJogadoresFrame); listaLayout.Padding = UDim.new(0, 5)

btnAtualizarPlayers.MouseButton1Click:Connect(function()
    for _, c in pairs(listaJogadoresFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btnPlayer = Instance.new("TextButton", listaJogadoresFrame); btnPlayer.Size = UDim2.new(1, 0, 0, 35); btnPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btnPlayer.Text = p.Name .. " (" .. #obterItensJogador(p) .. " Itens)"; btnPlayer.TextColor3 = Color3.fromRGB(255, 255, 255); btnPlayer.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", btnPlayer).CornerRadius = UDim.new(0, 6)
        end
    end
end)

-- ==========================================
-- LÓGICA GERAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() desativarOutrosESPs(); screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 480, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 480, 0, 400), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
