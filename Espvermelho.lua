-- ==========================================
-- Hub Universal V21 - ESP CHAMS VERMELHO
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

local corTema = Color3.fromRGB(255, 0, 0) -- Tema Vermelho

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubEspVermelho"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 200)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
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
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB V21 - ESP VERMELHO"
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
infoText.Size = UDim2.new(0.9, 0, 0, 50); infoText.Position = UDim2.new(0.05, 0, 0.1, 0)
infoText.BackgroundTransparency = 1; infoText.TextWrapped = true
infoText.Text = "Pinta todos os outros jogadores de vermelho para que fiquem visíveis através das paredes. Nenhum nome ou distância será exibido."
infoText.TextColor3 = Color3.fromRGB(200, 200, 200); infoText.Font = Enum.Font.Gotham; infoText.TextSize = 12

local btnEsp = Instance.new("TextButton", pageContainer)
btnEsp.Size = UDim2.new(0.8, 0, 0, 45); btnEsp.Position = UDim2.new(0.1, 0, 0.5, 0)
btnEsp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnEsp.Text = "ATIVAR ESP VERMELHO"; btnEsp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEsp.Font = Enum.Font.GothamBold; btnEsp.TextSize = 14
Instance.new("UICorner", btnEsp).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- LÓGICA DO ESP (HIGHLIGHT)
-- ==========================================
local function removerESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESPVermelho") then
            p.Character.ESPVermelho:Destroy()
        end
    end
end

btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnEsp.Text = espAtivado and "DESATIVAR ESP" or "ATIVAR ESP VERMELHO"
    btnEsp.BackgroundColor3 = espAtivado and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
    
    if espAtivado then
        -- Loop constante para garantir que os jogadores fiquem vermelhos mesmo se respawnarem
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    -- Verifica se o jogador já tem o efeito, se não tiver, adiciona
                    if not p.Character:FindFirstChild("ESPVermelho") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESPVermelho"
                        hl.FillColor = Color3.fromRGB(255, 0, 0) -- Preenchimento Vermelho
                        hl.OutlineColor = Color3.fromRGB(255, 0, 0) -- Borda Vermelha
                        hl.FillTransparency = 0.4 -- Define a transparência do corpo (0.4 é ideal)
                        hl.OutlineTransparency = 0 -- Borda 100% visível
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Função MÁGICA: Faz ver através das paredes
                        hl.Parent = p.Character
                    end
                end
            end
        end)
    else
        -- Desliga a conexão e limpa a tela de todo mundo
        if espConnection then 
            espConnection:Disconnect() 
            espConnection = nil 
        end
        removerESP()
    end
end)

-- Limpa o ESP de um jogador específico quando ele sair do jogo para evitar acúmulo de dados (Opcional, mas boa prática)
Players.PlayerRemoving:Connect(function(p)
    if p.Character and p.Character:FindFirstChild("ESPVermelho") then
        p.Character.ESPVermelho:Destroy()
    end
end)

-- ==========================================
-- LÓGICA GERAL (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() 
    if espConnection then espConnection:Disconnect() end
    removerESP()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 35), "Out", "Quad", 0.3, true)
        pageContainer.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 200), "Out", "Quad", 0.3, true)
        pageContainer.Visible = true
    end
end)
