-- ==========================================
-- Hub Universal V19 - ESPIONAGEM DE INVENTÁRIO
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local espAtivado = false
local espConnection = nil

local corTema = Color3.fromRGB(255, 50, 50) -- Tema Vermelho para combinar com o ESP

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubInventoryScanner"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 380)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
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
titleText.Text = "HUB INVENTÁRIOS V19"
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
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    return btn
end

local tabEsp = criarAba("ESP (1 Item)", 1)
local tabScanner = criarAba("Scanner (2+ Itens)", 2)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local pageEsp = Instance.new("Frame", pageContainer)
pageEsp.Size = UDim2.new(1, 0, 1, 0); pageEsp.BackgroundTransparency = 1; pageEsp.Visible = true

local pageScanner = Instance.new("Frame", pageContainer)
pageScanner.Size = UDim2.new(1, 0, 1, 0); pageScanner.BackgroundTransparency = 1; pageScanner.Visible = false

tabEsp.MouseButton1Click:Connect(function() pageEsp.Visible = true; pageScanner.Visible = false; tabEsp.TextColor3 = corTema; tabScanner.TextColor3 = Color3.fromRGB(200, 200, 200) end)
tabScanner.MouseButton1Click:Connect(function() pageEsp.Visible = false; pageScanner.Visible = true; tabEsp.TextColor3 = Color3.fromRGB(200, 200, 200); tabScanner.TextColor3 = corTema end)
tabEsp.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES AUXILIARES
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
    local ferramentas = {}
    if alvo:FindFirstChild("Backpack") then
        for _, item in pairs(alvo.Backpack:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then table.insert(ferramentas, item) end
        end
    end
    if alvo.Character then
        for _, item in pairs(alvo.Character:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then table.insert(ferramentas, item) end
        end
    end
    return ferramentas
end

-- ==========================================
-- PÁGINA 1: ESP (APENAS 1 ITEM)
-- ==========================================
local espInfo = Instance.new("TextLabel", pageEsp)
espInfo.Size = UDim2.new(0.9, 0, 0, 60); espInfo.Position = UDim2.new(0.05, 0, 0.1, 0)
espInfo.BackgroundTransparency = 1; espInfo.TextWrapped = true
espInfo.Text = "Esta função revela automaticamente jogadores que possuem EXATAMENTE 1 item no inventário. O jogador ficará vermelho e o nome do item aparecerá em sua cabeça."
espInfo.TextColor3 = Color3.fromRGB(200, 200, 200); espInfo.Font = Enum.Font.Gotham; espInfo.TextSize = 12

local btnAtivarEsp = criarBotaoSimples("Ligar ESP (1 Item)", pageEsp, Color3.fromRGB(150, 50, 50))
btnAtivarEsp.Position = UDim2.new(0.05, 0, 0.4, 0)

local function limparTodosESPs()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESP_1Item") then
                p.Character.Head.ESP_1Item:Destroy()
            end
            if p.Character:FindFirstChild("ESP_Highlight") then
                p.Character.ESP_Highlight:Destroy()
            end
        end
    end
end

btnAtivarEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnAtivarEsp.Text = espAtivado and "Desligar ESP" or "Ligar ESP (1 Item)"
    btnAtivarEsp.BackgroundColor3 = espAtivado and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(150, 50, 50)
    
    if espAtivado then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local itens = obterItensJogador(p)
                    local char = p.Character
                    local head = char.Head
                    
                    if #itens == 1 then
                        -- Criar Highlight Vermelho
                        if not char:FindFirstChild("ESP_Highlight") then
                            local hl = Instance.new("Highlight", char)
                            hl.Name = "ESP_Highlight"
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                        end
                        
                        -- Criar Nome Flutuante
                        local espGui = head:FindFirstChild("ESP_1Item")
                        if not espGui then
                            espGui = Instance.new("BillboardGui", head)
                            espGui.Name = "ESP_1Item"
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
                        espGui.TextLabel.Text = "[ " .. p.Name .. " ]\nItem: " .. itens[1].Name
                    else
                        -- Se tiver 0 itens ou mais de 1 item, remove o ESP deste jogador
                        if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
                        if head:FindFirstChild("ESP_1Item") then head.ESP_1Item:Destroy() end
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
-- PÁGINA 2: SCANNER DE INVENTÁRIOS
-- ==========================================
local btnAtualizarPlayers = criarBotaoSimples("Atualizar Lista de Jogadores", pageScanner, Color3.fromRGB(0, 150, 100))
btnAtualizarPlayers.Position = UDim2.new(0.05, 0, 0.05, 0)

-- Lista de Jogadores
local listaJogadoresFrame = Instance.new("ScrollingFrame", pageScanner)
listaJogadoresFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
listaJogadoresFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
listaJogadoresFrame.BackgroundTransparency = 1
listaJogadoresFrame.ScrollBarThickness = 4
local listaLayout = Instance.new("UIListLayout", listaJogadoresFrame)
listaLayout.Padding = UDim.new(0, 5)

-- Container dos Itens do Jogador Selecionado (Escondido por padrão)
local itensContainer = Instance.new("Frame", pageScanner)
itensContainer.Size = UDim2.new(1, 0, 1, 0)
itensContainer.BackgroundTransparency = 1
itensContainer.Visible = false

local btnVoltar = criarBotaoSimples("← Voltar para Lista", itensContainer, Color3.fromRGB(80, 80, 80))
btnVoltar.Position = UDim2.new(0.05, 0, 0.05, 0)

local inputPesquisa = Instance.new("TextBox", itensContainer)
inputPesquisa.Size = UDim2.new(0.9, 0, 0, 30)
inputPesquisa.Position = UDim2.new(0.05, 0, 0.18, 0)
inputPesquisa.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputPesquisa.PlaceholderText = "Pesquisar item..."
inputPesquisa.Text = ""
inputPesquisa.TextColor3 = Color3.fromRGB(255, 255, 255)
inputPesquisa.Font = Enum.Font.Gotham; inputPesquisa.TextSize = 13
Instance.new("UICorner", inputPesquisa).CornerRadius = UDim.new(0, 6)

local listaItensScroll = Instance.new("ScrollingFrame", itensContainer)
listaItensScroll.Size = UDim2.new(0.9, 0, 0.6, 0)
listaItensScroll.Position = UDim2.new(0.05, 0, 0.3, 0)
listaItensScroll.BackgroundTransparency = 1
listaItensScroll.ScrollBarThickness = 4
local itensLayout = Instance.new("UIListLayout", listaItensScroll)
itensLayout.Padding = UDim.new(0, 5)

local jogadorAtualSelecionado = nil

-- Função para atualizar a lista de jogadores
btnAtualizarPlayers.MouseButton1Click:Connect(function()
    for _, child in pairs(listaJogadoresFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btnPlayer = Instance.new("TextButton", listaJogadoresFrame)
            btnPlayer.Size = UDim2.new(1, 0, 0, 35)
            btnPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            
            -- Pega a quantidade de itens só pra visualização
            local qtdItens = #obterItensJogador(p)
            btnPlayer.Text = p.Name .. " (" .. qtdItens .. " Itens)"
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

-- Função para carregar e pesquisar os itens do jogador selecionado
function carregarItensNaLista()
    for _, child in pairs(listaItensScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    if not jogadorAtualSelecionado or not jogadorAtualSelecionado.Parent then
        local aviso = Instance.new("TextLabel", listaItensScroll)
        aviso.Size = UDim2.new(1, 0, 0, 30); aviso.BackgroundTransparency = 1
        aviso.Text = "Jogador saiu do jogo."; aviso.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    local ferramentas = obterItensJogador(jogadorAtualSelecionado)
    local termoPesquisa = string.lower(inputPesquisa.Text)
    
    local encontrouAlgum = false

    for _, item in ipairs(ferramentas) do
        if termoPesquisa == "" or string.find(string.lower(item.Name), termoPesquisa) then
            encontrouAlgum = true
            local lblItem = Instance.new("TextLabel", listaItensScroll)
            lblItem.Size = UDim2.new(1, 0, 0, 30)
            lblItem.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            lblItem.Text = " ⚔️ " .. item.Name
            lblItem.TextColor3 = Color3.fromRGB(200, 200, 255)
            lblItem.TextXAlignment = Enum.TextXAlignment.Left
            lblItem.Font = Enum.Font.Gotham
            lblItem.TextSize = 13
            Instance.new("UICorner", lblItem).CornerRadius = UDim.new(0, 6)
        end
    end
    
    if not encontrouAlgum then
        local aviso = Instance.new("TextLabel", listaItensScroll)
        aviso.Size = UDim2.new(1, 0, 0, 30); aviso.BackgroundTransparency = 1
        aviso.Text = "Nenhum item encontrado."; aviso.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Filtro de Pesquisa em tempo real
inputPesquisa:GetPropertyChangedSignal("Text"):Connect(function()
    carregarItensNaLista()
end)

-- Botão Voltar
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
    limparTodosESPs()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false; pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 420, 0, 380), "Out", "Quad", 0.3, true)
        tabBar.Visible = true; pageContainer.Visible = true
    end
end)
