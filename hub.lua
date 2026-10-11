-- ==========================================
-- Hub Universal V18 - UI PREMIUM & SISTEMAS ATUALIZADOS
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local espAtivado = false
local invisivel = false
local modoDeus = false
local noclipAtivado = false
local aimbotAtivado = false
local aimbotModoMouse = true 
local aimbotAuto = true
local puloInfinitoAtivado = false
local hitboxAtivada = false
local fullbrightAtivado = false
local clickTpAtivado = false
local semDanoQuedaAtivado = false
local indexSpec = 1

local velocidadeAtual = 16
local puloAtual = 50

local godModeConnection, noclipConnection, aimbotConnection
local hitboxConnection, noFallConnection, espConnection, fullbrightConnection
local corTema = Color3.fromRGB(0, 170, 255) 

-- ==========================================
-- ANIMAÇÕES E EFEITOS (TWEENS)
-- ==========================================
local function aplicarHover(botao, corNormal, corHover)
    botao.MouseEnter:Connect(function()
        TweenService:Create(botao, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = corHover}):Play()
    end)
    botao.MouseLeave:Connect(function()
        TweenService:Create(botao, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = corNormal}):Play()
    end)
end

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE PREMIUM
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubPremiumV18"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 440, 0, 400)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18) -- Fundo mais escuro e moderno
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true -- Essencial para o novo sistema de minimizar
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 1.5
mainStroke.Color = corTema
mainStroke.Transparency = 0.3

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.BorderSizePixel = 0

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.04, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HUB UNIVERSAL V18"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left

-- Botões estilo macOS flutuantes
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
closeBtn.Text = ""
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
aplicarHover(closeBtn, Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 120, 120))

local minBtn = Instance.new("TextButton", titleBar)
minBtn.AnchorPoint = Vector2.new(1, 0.5)
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -42, 0.5, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
minBtn.Text = ""
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
aplicarHover(minBtn, Color3.fromRGB(255, 180, 50), Color3.fromRGB(255, 210, 100))

local divisor = Instance.new("Frame", titleBar)
divisor.Size = UDim2.new(1, 0, 0, 1)
divisor.Position = UDim2.new(0, 0, 1, 0)
divisor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divisor.BackgroundTransparency = 0.9

-- ==========================================
-- SISTEMA DE ABAS E PÁGINAS
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 41)
tabBar.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(130, 130, 130)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.LayoutOrder = ordem
    return btn
end

local tabScripts = criarAba("Scripts", 1)
local tabConfig = criarAba("Interface", 2)
local tabSec = criarAba("Segurança", 3)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -80)
pageContainer.Position = UDim2.new(0, 0, 0, 80)
pageContainer.BackgroundTransparency = 1

local function criarPagina()
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, -10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = corTema
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local padding = Instance.new("UIPadding", page)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 15)
    
    return page
end

local pageScripts = criarPagina()
local pageConfig = criarPagina()
local pageSec = criarPagina()
pageScripts.Visible = true

local function mudarAba(ativa, paginaAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do 
        if btn:IsA("TextButton") then 
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(130, 130, 130)}):Play()
        end 
    end
    TweenService:Create(ativa, TweenInfo.new(0.3), {TextColor3 = corTema}):Play()
    pageScripts.Visible = false; pageConfig.Visible = false; pageSec.Visible = false
    paginaAtiva.Visible = true
end

tabScripts.MouseButton1Click:Connect(function() mudarAba(tabScripts, pageScripts) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)
tabSec.MouseButton1Click:Connect(function() mudarAba(tabSec, pageSec) end)
tabScripts.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES AUXILIARES DE UI PREMIUM
-- ==========================================
local function criarBotaoSimples(texto, parent, corBase)
    corBase = corBase or Color3.fromRGB(30, 30, 35)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.BackgroundColor3 = corBase
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Gera cor de hover dinamicamente (mais clara)
    local h, s, v = corBase:ToHSV()
    local corHover = Color3.fromHSV(h, s, math.clamp(v + 0.15, 0, 1))
    aplicarHover(btn, corBase, corHover)
    
    return btn
end

local function criarLinhaEscala(texto, baseValue, parent, isJump)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 38)
    frame.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.72, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    aplicarHover(btn, Color3.fromRGB(30, 30, 35), Color3.fromRGB(45, 45, 50))
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.25, 0, 1, 0)
    input.Position = UDim2.new(0.75, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    input.Text = "1"
    input.TextColor3 = corTema
    input.Font = Enum.Font.GothamBold
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        local valor = tonumber(input.Text) or 1
        valor = math.clamp(valor, 1, 10); input.Text = tostring(valor)
        if isJump then 
            puloAtual = baseValue * valor
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.UseJumpPower = true; char.Humanoid.JumpPower = puloAtual end
        else 
            velocidadeAtual = baseValue * valor
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = velocidadeAtual end 
        end
    end)
    return input
end

local function criarDivisoria(texto, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 25)
    frame.BackgroundTransparency = 1
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = texto
    txt.TextColor3 = corTema
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
end

-- Lógica de Inputs
local isAimingInput = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then isAimingInput = true end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isAimingInput = false end
end)

-- Auto-Reaplicar no Respawn
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        if velocidadeAtual ~= 16 then hum.WalkSpeed = velocidadeAtual end
        if puloAtual ~= 50 then hum.UseJumpPower = true; hum.JumpPower = puloAtual end
    end
    if invisivel then
        task.wait(0.5) 
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1
            elseif part:IsA("Decal") then part.Transparency = 1 end
        end
    end
end)

-- ==========================================
-- PÁGINA 1: SCRIPTS GERAIS
-- ==========================================
criarDivisoria("COMBATE E VISÃO", pageScripts)
local btnAimbot = criarBotaoSimples("Ativar Aimbot", pageScripts, Color3.fromRGB(160, 40, 40))
local btnAimbotTrigger = criarBotaoSimples("Gatilho Aimbot: Automático", pageScripts)
local btnAimbotMode = criarBotaoSimples("Modo Aimbot: Mais Próximo da Mira", pageScripts)
local btnHitbox = criarBotaoSimples("Expandir Hitbox (Acerto Fácil)", pageScripts)
local btnEsp = criarBotaoSimples("Ativar ESP (Vermelho Inimigo / Verde Aliado)", pageScripts)

criarDivisoria("MOVIMENTAÇÃO", pageScripts)
local btnNoFall = criarBotaoSimples("Ignorar Dano de Queda", pageScripts)
local btnClickTp = criarBotaoSimples("Teleporte por Clique (CTRL + Click)", pageScripts)
local btnNoclip = criarBotaoSimples("Atravessar Parede (Noclip)", pageScripts)
local btnPuloInf = criarBotaoSimples("Ativar Pulo Infinito no Ar", pageScripts)
local inputVel = criarLinhaEscala("Aplicar Velocidade (1-10)", 16, pageScripts, false)
local inputPulo = criarLinhaEscala("Aplicar Pulo (1-10)", 50, pageScripts, true)

criarDivisoria("UTILIDADES", pageScripts)
local btnFullbright = criarBotaoSimples("Visão Noturna (Forçar Claridade)", pageScripts)
local btnGodMode = criarBotaoSimples("Ativar Modo Deus (Client-Side)", pageScripts, Color3.fromRGB(150, 100, 0))
local btnInvis = criarBotaoSimples("Ativar Invisibilidade", pageScripts)
local btnSpec = criarBotaoSimples("Espionar Próximo Jogador", pageScripts)
local btnCloneSkin = criarBotaoSimples("Clonar Skin do Alvo", pageScripts)
local btnUnspec = criarBotaoSimples("Parar Espionagem", pageScripts, Color3.fromRGB(100, 40, 40))

-- Funções da Página 1
btnAimbotTrigger.MouseButton1Click:Connect(function()
    aimbotAuto = not aimbotAuto
    btnAimbotTrigger.Text = aimbotAuto and "Gatilho Aimbot: Automático" or "Gatilho Aimbot: Segurar (Touch/Click/Shift)"
end)

btnCloneSkin.MouseButton1Click:Connect(function()
    local alvo = Players:GetPlayers()[indexSpec] 
    if alvo and alvo ~= player and alvo.Character and player.Character then
        local meuChar = player.Character; local alvoChar = alvo.Character
        for _, v in pairs(meuChar:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then v:Destroy() end end
        for _, v in pairs(alvoChar:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then v:Clone().Parent = meuChar end end
        local myHead = meuChar:FindFirstChild("Head"); local targetHead = alvoChar:FindFirstChild("Head")
        if myHead and targetHead then
            local myFace = myHead:FindFirstChildOfClass("Decal"); local targetFace = targetHead:FindFirstChildOfClass("Decal")
            if myFace and targetFace then myFace.Texture = targetFace.Texture elseif targetFace and not myFace then targetFace:Clone().Parent = myHead end
        end
        btnCloneSkin.Text = "Skin Clonada!"; task.wait(2); btnCloneSkin.Text = "Clonar Skin do Alvo"
    end
end)

btnAimbotMode.MouseButton1Click:Connect(function() aimbotModoMouse = not aimbotModoMouse; btnAimbotMode.Text = aimbotModoMouse and "Modo Aimbot: Mais Próximo da Mira" or "Modo Aimbot: Mais Próximo do Personagem" end)

local function pegarInimigoMaisProximo()
    local alvoVisivel = nil
    local alvoOculto = nil
    local distVisivel = math.huge
    local distOculta = math.huge
    local camera = workspace.CurrentCamera
    local meuHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    if player.Character then raycastParams.FilterDescendantsInstances = {player.Character} end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if player.Team ~= nil and p.Team ~= nil and player.Team == p.Team then continue end

            local head = p.Character.Head
            local dist = math.huge
            local naTela = false

            if aimbotModoMouse then
                local posTela, estaNaTela = camera:WorldToViewportPoint(head.Position)
                if estaNaTela then
                    dist = (Vector2.new(posTela.X, posTela.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    naTela = true
                end
            else
                if meuHrp and p.Character:FindFirstChild("HumanoidRootPart") then
                    dist = (p.Character.HumanoidRootPart.Position - meuHrp.Position).Magnitude
                    naTela = true
                end
            end

            if naTela then
                local direcao = head.Position - camera.CFrame.Position
                local rayResult = workspace:Raycast(camera.CFrame.Position, direcao, raycastParams)
                local visivel = (rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(p.Character))
                
                if visivel then
                    if dist < distVisivel then distVisivel = dist; alvoVisivel = head end
                else
                    if dist < distOculta then distOculta = dist; alvoOculto = head end
                end
            end
        end
    end
    return alvoVisivel or alvoOculto
end

btnAimbot.MouseButton1Click:Connect(function()
    aimbotAtivado = not aimbotAtivado; btnAimbot.Text = aimbotAtivado and "Aimbot: ATIVADO" or "Ativar Aimbot"
    if aimbotAtivado then 
        aimbotConnection = RunService.RenderStepped:Connect(function() 
            if aimbotAuto or isAimingInput or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                local alvo = pegarInimigoMaisProximo(); if alvo then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, alvo.Position) end 
            end
        end)
    else if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end end
end)

btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado
    btnEsp.Text = espAtivado and "ESP Equipe: ATIVADO" or "Ativar ESP (Vermelho Inimigo / Verde Aliado)"
    if espAtivado then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local isAlly = (player.Team ~= nil and p.Team ~= nil and player.Team == p.Team)
                    local h = p.Character:FindFirstChild("ESPHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "ESPHighlight"
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    if isAlly then
                        h.FillColor = Color3.fromRGB(0, 255, 0); h.OutlineColor = Color3.fromRGB(0, 150, 0)
                    else
                        h.FillColor = Color3.fromRGB(255, 0, 0); h.OutlineColor = Color3.fromRGB(150, 0, 0)
                    end
                end
            end
        end)
    else
        if espConnection then espConnection:Disconnect(); espConnection = nil end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight:Destroy() end end
    end
end)

btnNoFall.MouseButton1Click:Connect(function()
    semDanoQuedaAtivado = not semDanoQuedaAtivado; btnNoFall.Text = semDanoQuedaAtivado and "Ignorar Dano de Queda: ATIVADO" or "Ignorar Dano de Queda"
    if semDanoQuedaAtivado then
        noFallConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.AssemblyLinearVelocity.Y < -40 then char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(char.HumanoidRootPart.AssemblyLinearVelocity.X, -40, char.HumanoidRootPart.AssemblyLinearVelocity.Z) end
        end)
    else if noFallConnection then noFallConnection:Disconnect(); noFallConnection = nil end end
end)

btnHitbox.MouseButton1Click:Connect(function()
    hitboxAtivada = not hitboxAtivada; btnHitbox.Text = hitboxAtivada and "Hitbox Expandida: ATIVADA" or "Expandir Hitbox (Acerto Fácil)"
    if hitboxAtivada then
        hitboxConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Team ~= nil and p.Team ~= nil and player.Team == p.Team then continue end
                    local hrp = p.Character.HumanoidRootPart; hrp.Size = Vector3.new(15, 15, 15); hrp.Transparency = 0.5
                    hrp.BrickColor = BrickColor.new("Bright blue"); hrp.Material = Enum.Material.Neon; hrp.CanCollide = false
                end
            end
        end)
    else
        if hitboxConnection then hitboxConnection:Disconnect(); hitboxConnection = nil end
        for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); p.Character.HumanoidRootPart.Transparency = 1 end end
    end
end)

btnFullbright.MouseButton1Click:Connect(function()
    fullbrightAtivado = not fullbrightAtivado; 
    btnFullbright.Text = fullbrightAtivado and "Visão Noturna: ATIVADA (Forçada)" or "Visão Noturna (Forçar Claridade)"
    if fullbrightAtivado then 
        fullbrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
    else 
        if fullbrightConnection then fullbrightConnection:Disconnect(); fullbrightConnection = nil end
        Lighting.Brightness = 1; Lighting.FogEnd = 10000; Lighting.GlobalShadows = true 
    end
end)

btnClickTp.MouseButton1Click:Connect(function() clickTpAtivado = not clickTpAtivado; btnClickTp.Text = clickTpAtivado and "Click TP: ATIVADO (Use CTRL+Click)" or "Teleporte por Clique (CTRL + Click)" end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and clickTpAtivado and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and mouse.Hit then player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

btnPuloInf.MouseButton1Click:Connect(function() puloInfinitoAtivado = not puloInfinitoAtivado; btnPuloInf.Text = puloInfinitoAtivado and "Pulo Infinito: ATIVADO" or "Ativar Pulo Infinito no Ar" end)
UserInputService.JumpRequest:Connect(function() if puloInfinitoAtivado and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivado = not noclipAtivado; btnNoclip.Text = noclipAtivado and "Atravessar Parede: ATIVADO" or "Atravessar Parede (Noclip)"
    if noclipAtivado then noclipConnection = RunService.Stepped:Connect(function() if player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end)
    else if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end end
end)

btnGodMode.MouseButton1Click:Connect(function()
    modoDeus = not modoDeus; btnGodMode.Text = modoDeus and "Modo Deus: ATIVADO" or "Ativar Modo Deus (Client-Side)"
    if modoDeus then godModeConnection = RunService.RenderStepped:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.MaxHealth = math.huge; player.Character.Humanoid.Health = math.huge end end)
    else if godModeConnection then godModeConnection:Disconnect() end end
end)

btnInvis.MouseButton1Click:Connect(function()
    invisivel = not invisivel; btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ativar Invisibilidade"
    if player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = invisivel and 1 or 0 elseif part:IsA("Decal") then part.Transparency = invisivel and 1 or 0 end end end
end)

btnSpec.MouseButton1Click:Connect(function()
    local todos = Players:GetPlayers(); indexSpec = indexSpec + 1; if indexSpec > #todos then indexSpec = 1 end
    local alvo = todos[indexSpec]
    if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid; btnSpec.Text = "Espiando: " .. alvo.Name end
end)

btnUnspec.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character.Humanoid; btnSpec.Text = "Espionar Próximo Jogador" end end)

-- ==========================================
-- PÁGINA 2: CONFIGURAÇÕES DA INTERFACE
-- ==========================================
criarDivisoria("CUSTOMIZAÇÃO", pageConfig)
local cores = {
    {"Azul Ciano", Color3.fromRGB(0, 170, 255)}, 
    {"Vermelho Carmesim", Color3.fromRGB(230, 50, 50)},
    {"Verde Esmeralda", Color3.fromRGB(40, 220, 100)}, 
    {"Roxo Neon", Color3.fromRGB(150, 50, 255)}
}
for _, dados in ipairs(cores) do
    local btnCor = criarBotaoSimples(dados[1], pageConfig, Color3.fromRGB(30, 30, 35))
    btnCor.TextColor3 = dados[2]
    btnCor.MouseButton1Click:Connect(function()
        corTema = dados[2]
        mainStroke.Color = corTema
        pageScripts.ScrollBarImageColor3 = corTema
        pageConfig.ScrollBarImageColor3 = corTema
        pageSec.ScrollBarImageColor3 = corTema
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextBox") then TweenService:Create(obj, TweenInfo.new(0.3), {TextColor3 = corTema}):Play() end end
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextLabel") and obj.TextXAlignment == Enum.TextXAlignment.Left then TweenService:Create(obj, TweenInfo.new(0.3), {TextColor3 = corTema}):Play() end end
        for _, obj in pairs(pageConfig:GetDescendants()) do if obj:IsA("TextLabel") and obj.TextXAlignment == Enum.TextXAlignment.Left then TweenService:Create(obj, TweenInfo.new(0.3), {TextColor3 = corTema}):Play() end end
        for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") and btn.Visible and btn.TextColor3 ~= Color3.fromRGB(130, 130, 130) then TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = corTema}):Play() end end
    end)
end

criarDivisoria("ESTILO DE FUNDO", pageConfig)
local btnSido = criarBotaoSimples("Fundo Sólido (Normal)", pageConfig)
local btnTransp = criarBotaoSimples("Fundo Transparente (Vidro)", pageConfig)
btnSido.MouseButton1Click:Connect(function() TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end)
btnTransp.MouseButton1Click:Connect(function() TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.35}):Play() end)

-- ==========================================
-- PÁGINA 3: SEGURANÇA (SCANNER)
-- ==========================================
local infoSec = Instance.new("TextLabel", pageSec)
infoSec.Size = UDim2.new(0.92, 0, 0, 60)
infoSec.BackgroundTransparency = 1
infoSec.Text = "Este scanner verifica nomes de arquivos locais suspeitos. Ele não detecta anti-cheats de servidor!"
infoSec.TextColor3 = Color3.fromRGB(170, 170, 170)
infoSec.TextWrapped = true
infoSec.Font = Enum.Font.Gotham
infoSec.TextSize = 11

local btnScan = criarBotaoSimples("Iniciar Verificação do Mapa", pageSec, Color3.fromRGB(60, 60, 70))
local resultadoSec = Instance.new("TextLabel", pageSec)
resultadoSec.Size = UDim2.new(0.92, 0, 0, 80)
resultadoSec.BackgroundTransparency = 1
resultadoSec.Text = "Status: Aguardando verificação..."
resultadoSec.TextColor3 = Color3.fromRGB(240, 240, 240)
resultadoSec.TextWrapped = true
resultadoSec.Font = Enum.Font.GothamMedium
resultadoSec.TextSize = 12

btnScan.MouseButton1Click:Connect(function()
    btnScan.Text = "Escaneando..."
    resultadoSec.Text = "Procurando scripts suspeitos..."
    resultadoSec.TextColor3 = Color3.fromRGB(255, 200, 50)
    task.wait(1)
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
        resultadoSec.TextColor3 = Color3.fromRGB(255, 80, 80)
    else 
        resultadoSec.Text = "✅ Aparentemente Seguro: Nenhum sistema básico de Anti-Cheat local foi encontrado."
        resultadoSec.TextColor3 = Color3.fromRGB(80, 255, 80) 
    end
end)

-- ==========================================
-- LÓGICA GERAL DA JANELA (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

minBtn.MouseButton1Click:Connect(function() 
    minimizado = not minimizado
    
    if minimizado then 
        -- Fade Out nos elementos internos
        TweenService:Create(titleText, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(tabBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        for _, v in pairs(tabBar:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {TextTransparency = 1}):Play() end end
        pageContainer.Visible = false
        
        -- Encolhe a janela para uma pílula flutuante (diminui X e Y)
        mainFrame:TweenSize(UDim2.new(0, 90, 0, 40), "Out", "Quart", 0.4, true)
        
    else 
        -- Restaura o tamanho da janela
        mainFrame:TweenSize(UDim2.new(0, 440, 0, 400), "Out", "Quart", 0.4, true)
        
        -- Fade In nos elementos internos
        task.wait(0.2)
        TweenService:Create(titleText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        for _, v in pairs(tabBar:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end end
        pageContainer.Visible = true
    end 
end)
