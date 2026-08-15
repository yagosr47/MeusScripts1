-- ==========================================
-- Hub Universal V20 - SERVER HOPPER AVANÇADO
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local corTema = Color3.fromRGB(255, 150, 0) -- Laranja para o tema de Teleporte

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubServerHopper"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 320)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
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
titleText.Text = "HUB V20 - SERVER HOPPER"
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
-- CONTEÚDO DA PÁGINA
-- ==========================================
local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -35); pageContainer.Position = UDim2.new(0, 0, 0, 35)
pageContainer.BackgroundTransparency = 1

local infoText = Instance.new("TextLabel", pageContainer)
infoText.Size = UDim2.new(0.9, 0, 0, 50); infoText.Position = UDim2.new(0.05, 0, 0.05, 0)
infoText.BackgroundTransparency = 1; infoText.TextWrapped = true
infoText.Text = "Pule de servidor instantaneamente sem fechar o jogo. Escolha se quer um servidor tranquilo (vazio) ou um movimentado (cheio com vagas)."
infoText.TextColor3 = Color3.fromRGB(200, 200, 200); infoText.Font = Enum.Font.Gotham; infoText.TextSize = 12

local statusLabel = Instance.new("TextLabel", pageContainer)
statusLabel.Size = UDim2.new(0.9, 0, 0, 30); statusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1; statusLabel.TextWrapped = true
statusLabel.Text = "Status: Aguardando comando..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0); statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextSize = 13

local function criarBotaoSimples(texto, parent, cor, pos)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 45); btn.Position = pos
    btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local btnVazio = criarBotaoSimples("🌍 Procurar Servidor VAZIO (Menos Pessoas)", pageContainer, Color3.fromRGB(0, 150, 100), UDim2.new(0.05, 0, 0.3, 0))
local btnCheio = criarBotaoSimples("🔥 Procurar Servidor CHEIO (Com Vagas)", pageContainer, Color3.fromRGB(200, 80, 0), UDim2.new(0.05, 0, 0.5, 0))
local btnRandom = criarBotaoSimples("🎲 Pular para Servidor ALEATÓRIO", pageContainer, Color3.fromRGB(80, 80, 200), UDim2.new(0.05, 0, 0.7, 0))

-- ==========================================
-- LÓGICA DO SERVER HOPPER
-- ==========================================
local function pularServidor(modo)
    statusLabel.Text = "Status: Escaneando servidores do Roblox..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    
    -- Define a ordem de busca: Ascendente para vazio, Descendente para cheio
    local sortOrder = (modo == "vazio") and "Asc" or "Desc"
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
    
    -- Usando pcall e game:HttpGet (Padrão em executores de script)
    local sucesso, resultado = pcall(function()
        return game:HttpGet(url)
    end)
    
    if sucesso and resultado then
        local dados = HttpService:JSONDecode(resultado)
        if dados and dados.data then
            local servidoresEncontrados = dados.data
            local servidorAlvo = nil
            
            -- Embaralha a lista caso seja modo aleatório
            if modo == "aleatorio" then
                for i = #servidoresEncontrados, 2, -1 do
                    local j = math.random(i)
                    servidoresEncontrados[i], servidoresEncontrados[j] = servidoresEncontrados[j], servidoresEncontrados[i]
                end
            end

            for _, server in ipairs(servidoresEncontrados) do
                -- Ignora o servidor que você já está
                if server.id ~= game.JobId and server.playing and server.maxPlayers then
                    
                    if modo == "vazio" then
                        -- Pega o primeiro que tiver menos que a metade do maxPlayers
                        if server.playing < server.maxPlayers then
                            servidorAlvo = server.id
                            break
                        end
                        
                    elseif modo == "cheio" then
                        -- Pega um servidor muito cheio, mas deixa PELO MENOS 2 vagas para evitar tela de erro
                        if server.playing >= (server.maxPlayers * 0.7) and server.playing <= (server.maxPlayers - 2) then
                            servidorAlvo = server.id
                            break
                        end
                        
                    elseif modo == "aleatorio" then
                        if server.playing < server.maxPlayers then
                            servidorAlvo = server.id
                            break
                        end
                    end
                end
            end
            
            if servidorAlvo then
                statusLabel.Text = "Status: Servidor encontrado! Teleportando..."
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                -- Executa o teleporte instantâneo
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servidorAlvo, player)
            else
                statusLabel.Text = "Status: Nenhum servidor ideal encontrado."
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        else
            statusLabel.Text = "Status: Erro ao ler dados da API do Roblox."
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        statusLabel.Text = "Status: O seu executor não suporta requisições HttpGet."
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

-- Botões clicáveis chamando a função com seu respectivo modo
btnVazio.MouseButton1Click:Connect(function() pularServidor("vazio") end)
btnCheio.MouseButton1Click:Connect(function() pularServidor("cheio") end)
btnRandom.MouseButton1Click:Connect(function() pularServidor("aleatorio") end)

-- ==========================================
-- LÓGICA GERAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() 
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 35), "Out", "Quad", 0.3, true)
        pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 320), "Out", "Quad", 0.3, true)
        pageContainer.Visible = true
    end
end)
