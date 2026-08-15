-- ==========================================
-- Hub IA Universal - Integração Google Gemini
-- Cria e executa scripts (Auto Farm, ESP) por comando de texto!
-- ==========================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ==========================================
-- 🔴 INSIRA SUA CHAVE DA API DO GOOGLE AQUI 🔴
-- Pegue gratuitamente em: aistudio.google.com/app/apikey
-- ==========================================
local API_KEY = "AQ.Ab8RN6I78ou7ZVMudZ4BntCfHelOErkAvhRwwR-dxPTnBT8pGA" 
local API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. API_KEY

-- Verifica qual função HTTP o executor suporta
local httprequest = (syn and syn.request) or (http and http.request) or http_request or fluxus and fluxus.request or request
if not httprequest then
    warn("Seu executor não suporta requisições HTTP!")
    return
end

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE (CHAT IA)
-- ==========================================
for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "HubIA_Gemini" then v:Destroy() end end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubIA_Gemini"; screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 150, 255); stroke.Thickness = 2

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -40, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1; title.Text = "🤖 IA Assistant (Google Gemini)"
title.TextColor3 = Color3.fromRGB(0, 150, 255); title.Font = Enum.Font.GothamBold
title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1; closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50); closeBtn.Font = Enum.Font.GothamBold

-- Chat Histórico
local chatFrame = Instance.new("ScrollingFrame", mainFrame)
chatFrame.Size = UDim2.new(1, -20, 1, -85); chatFrame.Position = UDim2.new(0, 10, 0, 40)
chatFrame.BackgroundTransparency = 1; chatFrame.ScrollBarThickness = 4
local chatLayout = Instance.new("UIListLayout", chatFrame)
chatLayout.Padding = UDim.new(0, 5); chatLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Input e Botão
local inputBar = Instance.new("TextBox", mainFrame)
inputBar.Size = UDim2.new(1, -70, 0, 35); inputBar.Position = UDim2.new(0, 10, 1, -40)
inputBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30); inputBar.TextColor3 = Color3.fromRGB(255,255,255)
inputBar.PlaceholderText = "Ex: Crie um ESP para todos os jogadores..."
inputBar.Font = Enum.Font.Gotham; inputBar.TextSize = 13; inputBar.ClearTextOnFocus = false
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 6)

local sendBtn = Instance.new("TextButton", mainFrame)
sendBtn.Size = UDim2.new(0, 50, 0, 35); sendBtn.Position = UDim2.new(1, -60, 1, -40)
sendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); sendBtn.Text = "Enviar"
sendBtn.TextColor3 = Color3.fromRGB(255,255,255); sendBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 2. FUNÇÕES DE CHAT E EXECUÇÃO
-- ==========================================
local function adicionarMensagem(autor, texto, cor)
    local msgLbl = Instance.new("TextLabel", chatFrame)
    msgLbl.Size = UDim2.new(1, 0, 0, 0)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = "[" .. autor .. "]: " .. texto
    msgLbl.TextColor3 = cor
    msgLbl.Font = Enum.Font.Gotham; msgLbl.TextSize = 13
    msgLbl.TextWrapped = true; msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Auto-scroll para baixo
    task.delay(0.1, function() chatFrame.CanvasPosition = Vector2.new(0, chatFrame.AbsoluteWindowSize.Y + 1000) end)
end

local promptSistema = [[
Você é uma IA embutida em um executor do Roblox. Seu objetivo é ajudar o usuário gerando APENAS código Lua puro (Luau) que possa ser executado imediatamente usando a função loadstring().
Se o usuário pedir um Auto Farm, ESP, ou para buscar itens, escreva o código.
REGRAS:
1. Responda APENAS com o código. Não diga "Aqui está o código", não explique nada.
2. NÃO use formatação markdown como ```lua ou ```. Escreva apenas o código bruto.
3. O script será executado no Client-Side (LocalScript). Use game:GetService("Players").LocalPlayer.
4. Se for algo conversacional e não precisar de script, use a função print() para responder no console.
]]

local function enviarParaIA(mensagem)
    if API_KEY == "COLOQUE_SUA_CHAVE_AQUI" then
        adicionarMensagem("SISTEMA", "Erro: Você precisa colocar sua API Key do Google no script!", Color3.fromRGB(255, 50, 50))
        return
    end

    adicionarMensagem("Você", mensagem, Color3.fromRGB(200, 200, 200))
    inputBar.Text = ""
    adicionarMensagem("IA", "Pensando e programando...", Color3.fromRGB(100, 100, 100))

    local bodyInfo = {
        contents = {
            { parts = { { text = promptSistema .. "\nPedido do usuário: " .. mensagem } } }
        }
    }

    local jsonData = HttpService:JSONEncode(bodyInfo)

    task.spawn(function()
        local response = httprequest({
            Url = API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })

        if response.Success then
            local decoded = HttpService:JSONDecode(response.Body)
            if decoded.candidates and decoded.candidates[1] then
                local codigoIA = decoded.candidates[1].content.parts[1].text
                
                -- Limpa formatações indesejadas da IA
                codigoIA = string.gsub(codigoIA, "```lua", "")
                codigoIA = string.gsub(codigoIA, "```", "")

                adicionarMensagem("IA", "Código gerado! Executando no jogo...", Color3.fromRGB(0, 255, 100))
                
                -- Tenta executar o código criado pela IA
                local sucesso, erro = pcall(function()
                    local func = loadstring(codigoIA)
                    if func then
                        func()
                    else
                        error("A IA gerou um código com erro de sintaxe.")
                    end
                end)

                if not sucesso then
                    adicionarMensagem("ERRO DE EXECUÇÃO", erro, Color3.fromRGB(255, 0, 0))
                end
            else
                adicionarMensagem("SISTEMA", "Erro ao ler a resposta da IA.", Color3.fromRGB(255, 50, 50))
            end
        else
            adicionarMensagem("SISTEMA", "Erro HTTP ("..tostring(response.StatusCode).."). Verifique sua API Key.", Color3.fromRGB(255, 50, 50))
        end
    end)
end

sendBtn.MouseButton1Click:Connect(function()
    if inputBar.Text ~= "" then enviarParaIA(inputBar.Text) end
end)

inputBar.FocusLost:Connect(function(enterPressed)
    if enterPressed and inputBar.Text ~= "" then enviarParaIA(inputBar.Text) end
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

adicionarMensagem("SISTEMA", "Bem-vindo! Peça para a IA fazer algo. Ex: 'Faça meu personagem pular infinitamente' ou 'Crie um ESP vermelho para todos os players'.", Color3.fromRGB(255, 255, 0))
