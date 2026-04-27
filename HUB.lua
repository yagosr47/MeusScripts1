-- =========================================================
-- HUB DE ANIMAÇÕES E INTERFACE DO JOGADOR
-- =========================================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- 1. Criação da Interface Principal (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteHub"
screenGui.ResetOnSpawn = false -- Evita que a UI suma ao resetar
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 2. Botão Lateral para abrir/fechar o painel
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -30)
toggleBtn.Text = "Emotes"
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
local cornerToggle = Instance.new("UICorner", toggleBtn)
cornerToggle.CornerRadius = UDim.new(0, 12)
toggleBtn.Parent = screenGui

-- 3. Painel Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 350)
mainFrame.Position = UDim2.new(0, 90, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
local cornerMain = Instance.new("UICorner", mainFrame)
cornerMain.CornerRadius = UDim.new(0, 10)
mainFrame.Parent = screenGui

-- 4. Título do Painel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Animações"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = mainFrame

-- 5. Área Rolável (ScrollingFrame) para os botões
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollFrame

-- Lógica do botão de abrir/fechar
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- =========================================================
-- BANCO DE DADOS DE ANIMAÇÕES
-- =========================================================
-- Substitua os IDs abaixo pelos IDs das suas próprias animações.
-- Atualmente, usa IDs padrão da Roblox.

local animations = {
    {Name = "Acenar", Id = "rbxassetid://507770239"},
    {Name = "Apontar", Id = "rbxassetid://507770453"},
    {Name = "Dançar 1", Id = "rbxassetid://507771019"},
    {Name = "Dançar 2", Id = "rbxassetid://507771955"},
    {Name = "Rir", Id = "rbxassetid://507770818"},
    {Name = "Torcer", Id = "rbxassetid://507770677"}
}

local loadedTracks = {}
local currentTrack = nil

-- Função para atualizar variáveis caso o jogador morra (Respawn)
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")
    loadedTracks = {} -- Reseta o cache de animações
    if currentTrack then currentTrack:Stop() end
end)

-- =========================================================
-- GERAÇÃO DOS BOTÕES E LÓGICA DE EXECUÇÃO
-- =========================================================

for _, animData in ipairs(animations) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = animData.Name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = true
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    btn.Parent = scrollFrame

    btn.MouseButton1Click:Connect(function()
        if not character or not humanoid or humanoid.Health <= 0 then return end
        
        -- Para a animação atual se houver alguma tocando
        if currentTrack then
            currentTrack:Stop()
        end

        -- Carrega a animação no Animator caso ainda não tenha sido carregada
        if not loadedTracks[animData.Name] then
            local animInstance = Instance.new("Animation")
            animInstance.AnimationId = animData.Id
            loadedTracks[animData.Name] = animator:LoadAnimation(animInstance)
        end

        -- Toca a animação selecionada
        currentTrack = loadedTracks[animData.Name]
        currentTrack:Play()
    end)
end

-- =========================================================
-- ITEM EXTRA: BOTÃO DE PARAR ANIMAÇÃO
-- =========================================================
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, 0, 0, 35)
stopBtn.Text = "Parar Emote"
stopBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Font = Enum.Font.GothamBold
local stopCorner = Instance.new("UICorner", stopBtn)
stopCorner.CornerRadius = UDim.new(0, 6)
stopBtn.Parent = scrollFrame

stopBtn.MouseButton1Click:Connect(function()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
end)

-- Ajusta o tamanho da área de rolagem dinamicamente com base no número de botões
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)
