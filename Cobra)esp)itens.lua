-- ==========================================
-- Hub Universal V18 - BUSCADOR DE ITENS E COBRINHA
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local espAtivado = false
local espCor = Color3.fromRGB(0, 170, 255) -- Padrão Azul
local espDistanciaMax = 1000
local espAlvos = {}
local espGuis = {}
local espTick = 0

local corTema = Color3.fromRGB(0, 170, 255)

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubBuscadorSnake"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
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
titleText.Text = "BUSCADOR DE ITENS E JOGOS"
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
-- SISTEMA DE ABAS
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

local tabEsp = criarAba("Procurar Itens", 1)
local tabJogos = criarAba("Mini Jogos", 2)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local pageEsp = Instance.new("ScrollingFrame", pageContainer)
pageEsp.Size = UDim2.new(1, 0, 1, 0); pageEsp.BackgroundTransparency = 1; pageEsp.ScrollBarThickness = 4
local espLayout = Instance.new("UIListLayout", pageEsp)
espLayout.Padding = UDim.new(0, 8); espLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local pageJogos = Instance.new("Frame", pageContainer)
pageJogos.Size = UDim2.new(1, 0, 1, 0); pageJogos.BackgroundTransparency = 1; pageJogos.Visible = false

tabEsp.MouseButton1Click:Connect(function() pageEsp.Visible = true; pageJogos.Visible = false; tabEsp.TextColor3 = corTema; tabJogos.TextColor3 = Color3.fromRGB(200, 200, 200) end)
tabJogos.MouseButton1Click:Connect(function() pageEsp.Visible = false; pageJogos.Visible = true; tabEsp.TextColor3 = Color3.fromRGB(200, 200, 200); tabJogos.TextColor3 = corTema end)
tabEsp.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES UI
-- ==========================================
local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent)
    txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1
    txt.Text = texto; txt.TextColor3 = Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.GothamBold; txt.TextSize = 12; txt.TextXAlignment = Enum.TextXAlignment.Left
end

local function criarTextBox(placeholder, parent)
    local input = Instance.new("TextBox", parent)
    input.Size = UDim2.new(0.9, 0, 0, 35)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.PlaceholderText = placeholder
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham; input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    return input
end

local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- ==========================================
-- PÁGINA 1: BUSCADOR DE ITENS (ESP)
-- ==========================================
Instance.new("Frame", pageEsp).Size = UDim2.new(1,0,0,1)

criarDivisoria("Nome do Item (Ex: Espada, Chave):", pageEsp)
local inputNomeItem = criarTextBox("Digite o nome exato ou parte dele...", pageEsp)

criarDivisoria("Distância Máxima (Metros):", pageEsp)
local inputDistancia = criarTextBox("Ex: 500", pageEsp)
inputDistancia.Text = "1000"

criarDivisoria("Cor do Destaque:", pageEsp)
local colorFrame = Instance.new("Frame", pageEsp)
colorFrame.Size = UDim2.new(0.9, 0, 0, 30); colorFrame.BackgroundTransparency = 1
local colorLayout = Instance.new("UIListLayout", colorFrame)
colorLayout.FillDirection = Enum.FillDirection.Horizontal; colorLayout.Padding = UDim.new(0, 5)

local coresESP = {
    {Color3.fromRGB(0, 170, 255), "Azul"},
    {Color3.fromRGB(255, 50, 50), "Vermelho"},
    {Color3.fromRGB(50, 255, 50), "Verde"},
    {Color3.fromRGB(255, 255, 50), "Amarelo"},
    {Color3.fromRGB(255, 0, 255), "Rosa"}
}

for _, dados in ipairs(coresESP) do
    local btnC = Instance.new("TextButton", colorFrame)
    btnC.Size = UDim2.new(0, 30, 0, 30); btnC.BackgroundColor3 = dados[1]
    btnC.Text = ""; Instance.new("UICorner", btnC).CornerRadius = UDim.new(1, 0)
    btnC.MouseButton1Click:Connect(function() espCor = dados[1] end)
end

local btnAtivarEsp = criarBotaoSimples("Ligar Busca de Itens", pageEsp, Color3.fromRGB(0, 150, 100))

-- LÓGICA DO ESP DE ITENS
local function limparESP()
    for _, gui in pairs(espGuis) do gui:Destroy() end
    espGuis = {}
    espAlvos = {}
end

local function atualizarListaDeAlvos()
    local termo = string.lower(inputNomeItem.Text)
    if termo == "" then espAlvos = {}; return end
    
    local novosAlvos = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) and obj.Parent ~= player.Character then
            if string.find(string.lower(obj.Name), termo) then
                local posicaoObj = nil
                if obj:IsA("BasePart") then posicaoObj = obj
                elseif obj:IsA("Model") and obj.PrimaryPart then posicaoObj = obj.PrimaryPart
                elseif obj:IsA("Model") or obj:IsA("Tool") then
                    for _, p in pairs(obj:GetDescendants()) do if p:IsA("BasePart") then posicaoObj = p; break end end
                end
                if posicaoObj then table.insert(novosAlvos, {nome = obj.Name, part = posicaoObj}) end
            end
        end
    end
    espAlvos = novosAlvos
end

btnAtivarEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnAtivarEsp.Text = espAtivado and "Desligar Busca de Itens" or "Ligar Busca de Itens"
    btnAtivarEsp.BackgroundColor3 = espAtivado and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 150, 100)
    if not espAtivado then limparESP() else atualizarListaDeAlvos() end
end)

RunService.RenderStepped:Connect(function()
    if not espAtivado then return end
    espDistanciaMax = tonumber(inputDistancia.Text) or 1000
    
    -- Atualiza lista de tempos em tempos (para não dar lag procurando no workspace todo frame)
    if tick() - espTick > 2 then
        atualizarListaDeAlvos()
        espTick = tick()
    end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Remove antigas GUIs e recria atualizadas
    for _, gui in pairs(espGuis) do gui:Destroy() end
    espGuis = {}

    for _, alvo in ipairs(espAlvos) do
        if alvo.part and alvo.part.Parent then
            local dist = (hrp.Position - alvo.part.Position).Magnitude
            if dist <= espDistanciaMax then
                local bgui = Instance.new("BillboardGui", CoreGui)
                bgui.Name = "ItemESP"
                bgui.Adornee = alvo.part
                bgui.Size = UDim2.new(0, 200, 0, 50)
                bgui.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel", bgui)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = alvo.nome .. "\n[" .. math.floor(dist) .. "m]"
                txt.TextColor3 = espCor
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 12
                
                table.insert(espGuis, bgui)
            end
        end
    end
end)

-- ==========================================
-- PÁGINA 2: ABRIR JOGO DA COBRINHA
-- ==========================================
local btnAbrirSnake = Instance.new("TextButton", pageJogos)
btnAbrirSnake.Size = UDim2.new(0.8, 0, 0, 40)
btnAbrirSnake.Position = UDim2.new(0.1, 0, 0.2, 0)
btnAbrirSnake.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
btnAbrirSnake.Text = "🎮 ABRIR JOGO DA COBRINHA"
btnAbrirSnake.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAbrirSnake.Font = Enum.Font.GothamBold; btnAbrirSnake.TextSize = 14
Instance.new("UICorner", btnAbrirSnake).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- JANELA DO MINIJOGO DA COBRINHA
-- ==========================================
local snakeGui = Instance.new("Frame", screenGui)
snakeGui.Size = UDim2.new(0, 300, 0, 450)
snakeGui.Position = UDim2.new(0.5, 50, 0.5, -225)
snakeGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
snakeGui.BorderSizePixel = 0
snakeGui.Active = true
snakeGui.Draggable = true
snakeGui.Visible = false
Instance.new("UICorner", snakeGui).CornerRadius = UDim.new(0, 12)

local snakeTitleBar = Instance.new("Frame", snakeGui)
snakeTitleBar.Size = UDim2.new(1, 0, 0, 30)
snakeTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", snakeTitleBar).CornerRadius = UDim.new(0, 12)

local snakeTitle = Instance.new("TextLabel", snakeTitleBar)
snakeTitle.Size = UDim2.new(0.5, 0, 1, 0); snakeTitle.Position = UDim2.new(0.05, 0, 0, 0)
snakeTitle.BackgroundTransparency = 1; snakeTitle.Text = "SNAKE GAME"
snakeTitle.TextColor3 = Color3.fromRGB(0, 255, 100); snakeTitle.Font = Enum.Font.GothamBold; snakeTitle.TextXAlignment = Enum.TextXAlignment.Left

local snakeCloseBtn = Instance.new("TextButton", snakeTitleBar)
snakeCloseBtn.Size = UDim2.new(0, 25, 0, 25); snakeCloseBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
snakeCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); snakeCloseBtn.Text = "X"; snakeCloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", snakeCloseBtn).CornerRadius = UDim.new(0, 6)

local snakeMinBtn = Instance.new("TextButton", snakeTitleBar)
snakeMinBtn.Size = UDim2.new(0, 25, 0, 25); snakeMinBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
snakeMinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); snakeMinBtn.Text = "-"; snakeMinBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", snakeMinBtn).CornerRadius = UDim.new(0, 6)

local snakeContent = Instance.new("Frame", snakeGui)
snakeContent.Size = UDim2.new(1, 0, 1, -30); snakeContent.Position = UDim2.new(0, 0, 0, 30)
snakeContent.BackgroundTransparency = 1

local scoreLabel = Instance.new("TextLabel", snakeContent)
scoreLabel.Size = UDim2.new(1, 0, 0, 25)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Pontos: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.Font = Enum.Font.GothamBold; scoreLabel.TextSize = 14

local boardSize = 250
local gridCells = 15
local cellSize = boardSize / gridCells

local boardFrame = Instance.new("Frame", snakeContent)
boardFrame.Size = UDim2.new(0, boardSize, 0, boardSize)
boardFrame.Position = UDim2.new(0.5, -boardSize/2, 0, 30)
boardFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local boardStroke = Instance.new("UIStroke", boardFrame)
boardStroke.Color = Color3.fromRGB(0, 255, 100); boardStroke.Thickness = 2

local btnPlaySnake = Instance.new("TextButton", snakeContent)
btnPlaySnake.Size = UDim2.new(0.6, 0, 0, 30)
btnPlaySnake.Position = UDim2.new(0.2, 0, 0, boardSize + 40)
btnPlaySnake.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
btnPlaySnake.Text = "JOGAR / REINICIAR"
btnPlaySnake.TextColor3 = Color3.fromRGB(0, 0, 0)
btnPlaySnake.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnPlaySnake).CornerRadius = UDim.new(0, 8)

-- D-PAD PARA MOBILE/CONTROLE CLICÁVEL
local dpadFrame = Instance.new("Frame", snakeContent)
dpadFrame.Size = UDim2.new(0, 120, 0, 80)
dpadFrame.Position = UDim2.new(0.5, -60, 0, boardSize + 80)
dpadFrame.BackgroundTransparency = 1

local function criarSeta(texto, pos)
    local btn = Instance.new("TextButton", dpadFrame)
    btn.Size = UDim2.new(0, 35, 0, 35); btn.Position = pos; btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local btnCima = criarSeta("↑", UDim2.new(0.5, -17.5, 0, 0))
local btnBaixo = criarSeta("↓", UDim2.new(0.5, -17.5, 1, -35))
local btnEsq = criarSeta("←", UDim2.new(0, 0, 0.5, -17.5))
local btnDir = criarSeta("→", UDim2.new(1, -35, 0.5, -17.5))

btnAbrirSnake.MouseButton1Click:Connect(function() snakeGui.Visible = true end)
snakeCloseBtn.MouseButton1Click:Connect(function() snakeGui.Visible = false end)

local snakeMinimizado = false
snakeMinBtn.MouseButton1Click:Connect(function()
    snakeMinimizado = not snakeMinimizado
    if snakeMinimizado then
        snakeContent.Visible = false
        snakeGui:TweenSize(UDim2.new(0, 300, 0, 30), "Out", "Quad", 0.2, true)
    else
        snakeGui:TweenSize(UDim2.new(0, 300, 0, 450), "Out", "Quad", 0.2, true)
        task.wait(0.2)
        snakeContent.Visible = true
    end
end)

-- LÓGICA DO JOGO DA COBRINHA
local cobrinha = {}
local direcao = Vector2.new(1, 0)
local proxDirecao = Vector2.new(1, 0)
local comida = Vector2.new(5, 5)
local jogando = false
local pontos = 0
local blocosGui = {}

local function desenharBloco(x, y, cor)
    local frame = Instance.new("Frame", boardFrame)
    frame.Size = UDim2.new(0, cellSize, 0, cellSize)
    frame.Position = UDim2.new(0, (x-1)*cellSize, 0, (y-1)*cellSize)
    frame.BackgroundColor3 = cor
    frame.BorderSizePixel = 0
    table.insert(blocosGui, frame)
end

local function gerarComida()
    local livre = false
    while not livre do
        comida = Vector2.new(math.random(1, gridCells), math.random(1, gridCells))
        livre = true
        for _, parte in ipairs(cobrinha) do
            if parte.X == comida.X and parte.Y == comida.Y then livre = false; break end
        end
    end
end

local function gameOver()
    jogando = false
    scoreLabel.Text = "GAME OVER! Pontos: " .. pontos
    scoreLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
end

local function loopJogo()
    while jogando do
        task.wait(0.12) -- Velocidade do jogo
        if not jogando then break end
        
        direcao = proxDirecao
        local cabeca = cobrinha[1]
        local novaCabeca = Vector2.new(cabeca.X + direcao.X, cabeca.Y + direcao.Y)
        
        -- Bateu na Parede?
        if novaCabeca.X < 1 or novaCabeca.X > gridCells or novaCabeca.Y < 1 or novaCabeca.Y > gridCells then
            gameOver()
            break
        end
        
        -- Bateu nela mesma?
        for _, parte in ipairs(cobrinha) do
            if novaCabeca.X == parte.X and novaCabeca.Y == parte.Y then
                gameOver()
                break
            end
        end
        
        if not jogando then break end
        
        table.insert(cobrinha, 1, novaCabeca)
        
        -- Comeu a fruta?
        if novaCabeca.X == comida.X and novaCabeca.Y == comida.Y then
            pontos = pontos + 10
            scoreLabel.Text = "Pontos: " .. pontos
            gerarComida()
        else
            table.remove(cobrinha, #cobrinha) -- remove o rabo
        end
        
        -- Limpa e Desenha Frame
        for _, b in ipairs(blocosGui) do b:Destroy() end
        blocosGui = {}
        
        -- Desenha Comida
        desenharBloco(comida.X, comida.Y, Color3.fromRGB(255, 0, 0))
        
        -- Desenha Cobra
        for i, parte in ipairs(cobrinha) do
            local cor = i == 1 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 200, 50)
            desenharBloco(parte.X, parte.Y, cor)
        end
    end
end

btnPlaySnake.MouseButton1Click:Connect(function()
    jogando = false
    task.wait(0.2)
    pontos = 0
    scoreLabel.Text = "Pontos: 0"
    scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cobrinha = {Vector2.new(math.floor(gridCells/2), math.floor(gridCells/2))}
    direcao = Vector2.new(1, 0)
    proxDirecao = Vector2.new(1, 0)
    gerarComida()
    jogando = true
    task.spawn(loopJogo)
end)

-- CONTROLES (Prevenindo ir para trás)
local function mudarDirecao(x, y)
    if (direcao.X ~= -x or x == 0) and (direcao.Y ~= -y or y == 0) then
        proxDirecao = Vector2.new(x, y)
    end
end

btnCima.MouseButton1Click:Connect(function() mudarDirecao(0, -1) end)
btnBaixo.MouseButton1Click:Connect(function() mudarDirecao(0, 1) end)
btnEsq.MouseButton1Click:Connect(function() mudarDirecao(-1, 0) end)
btnDir.MouseButton1Click:Connect(function() mudarDirecao(1, 0) end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not jogando or not snakeGui.Visible then return end
    if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W then mudarDirecao(0, -1)
    elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then mudarDirecao(0, 1)
    elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then mudarDirecao(-1, 0)
    elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then mudarDirecao(1, 0) end
end)

-- ==========================================
-- LÓGICA DO HUB PRINCIPAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 35), "Out", "Quad", 0.3, true)
        tabBar.Visible = false; pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 350), "Out", "Quad", 0.3, true)
        tabBar.Visible = true; pageContainer.Visible = true
    end
end)
