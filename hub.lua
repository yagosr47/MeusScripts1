-- ==========================================
-- Hub Universal V17 - AIMBOT AUTOMÁTICO (MOBILE FRIENDLY)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
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
local aimbotAuto = true -- NOVO: Define se o Aimbot trava sozinho ou precisa segurar
local puloInfinitoAtivado = false
local hitboxAtivada = false
local fullbrightAtivado = false
local clickTpAtivado = false
local semDanoQuedaAtivado = false
local beybladeAtivado = false
local indexSpec = 1

local velocidadeAtual = 16
local puloAtual = 50

local godModeConnection = nil
local noclipConnection = nil
local aimbotConnection = nil
local hitboxConnection = nil
local noFallConnection = nil
local espConnection = nil
local beybladeObj = nil
local corTema = Color3.fromRGB(0, 170, 255) 

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE (COMPACTA)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubPremiumV17"
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
titleText.Text = "HUB UNIVERSAL V17"
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
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = nome; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    return btn
end

local tabScripts = criarAba("Scripts", 1)
local tabInv = criarAba("Inventário", 2)
local tabTroll = criarAba("Trolls", 3)
local tabConfig = criarAba("Interface", 4)
local tabSec = criarAba("Segurança", 5)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70)
pageContainer.BackgroundTransparency = 1

local function criarPagina()
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return page
end

local pageScripts = criarPagina()
local pageInv = criarPagina()
local pageTroll = criarPagina()
local pageConfig = criarPagina()
local pageSec = criarPagina()
pageScripts.Visible = true

local function mudarAba(ativa, paginaAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end
    ativa.TextColor3 = corTema
    pageScripts.Visible = false; pageInv.Visible = false; pageTroll.Visible = false; pageConfig.Visible = false; pageSec.Visible = false
    paginaAtiva.Visible = true
end

tabScripts.MouseButton1Click:Connect(function() mudarAba(tabScripts, pageScripts) end)
tabInv.MouseButton1Click:Connect(function() mudarAba(tabInv, pageInv) end)
tabTroll.MouseButton1Click:Connect(function() mudarAba(tabTroll, pageTroll) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)
tabSec.MouseButton1Click:Connect(function() mudarAba(tabSec, pageSec) end)
tabScripts.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES AUXILIARES DE UI E INPUTS
-- ==========================================
local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function criarLinhaEscala(texto, baseValue, parent, isJump)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 35); frame.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.7, 0, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.25, 0, 1, 0); input.Position = UDim2.new(0.75, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30); input.Text = "1"
    input.TextColor3 = corTema; input.Font = Enum.Font.GothamBold; input.TextSize = 15
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        local valor = tonumber(input.Text) or 1
        valor = math.clamp(valor, 1, 10); input.Text = tostring(valor)
        if isJump then puloAtual = baseValue * valor; if char and char:FindFirstChild("Humanoid") then char.Humanoid.UseJumpPower = true; char.Humanoid.JumpPower = puloAtual end
        else velocidadeAtual = baseValue * valor; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = velocidadeAtual end end
    end)
    return input
end

local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent)
    txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1
    txt.Text = "--- " .. texto .. " ---"
    txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
end

local isAimingInput = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then isAimingInput = true end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isAimingInput = false end
end)

-- AUTO-REAPLICAR NO RESPAWN
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
Instance.new("Frame", pageScripts).Size = UDim2.new(1,0,0,1)

criarDivisoria("Combate e Aimbot", pageScripts)
local btnAimbot = criarBotaoSimples("Ativar Aimbot", pageScripts, Color3.fromRGB(200, 50, 50))
local btnAimbotTrigger = criarBotaoSimples("Gatilho Aimbot: Automático (Sem Segurar)", pageScripts, Color3.fromRGB(180, 80, 120)) -- NOVO GATILHO
local btnAimbotMode = criarBotaoSimples("Modo Aimbot: Mais Próximo da Mira", pageScripts, Color3.fromRGB(150, 50, 100))
local btnHitbox = criarBotaoSimples("Expandir Hitbox (Acerto Fácil)", pageScripts, Color3.fromRGB(200, 100, 50))
local btnEsp = criarBotaoSimples("Ativar ESP (Com Distância)", pageScripts)

criarDivisoria("Movimentação Extrema", pageScripts)
local btnNoFall = criarBotaoSimples("Ignorar Dano de Queda", pageScripts, Color3.fromRGB(50, 150, 200))
local btnClickTp = criarBotaoSimples("Teleporte por Clique (CTRL + Click)", pageScripts, Color3.fromRGB(0, 150, 100))
local btnNoclip = criarBotaoSimples("Atravessar Parede (Noclip)", pageScripts, Color3.fromRGB(120, 60, 180))
local btnPuloInf = criarBotaoSimples("Ativar Pulo Infinito no Ar", pageScripts, Color3.fromRGB(0, 150, 200))
local inputVel = criarLinhaEscala("Aplicar Velocidade (1-10)", 16, pageScripts, false)
local inputPulo = criarLinhaEscala("Aplicar Pulo (1-10)", 50, pageScripts, true)

criarDivisoria("Utilidades do Jogador", pageScripts)
local btnFullbright = criarBotaoSimples("Visão Noturna (Claridade Máxima)", pageScripts, Color3.fromRGB(200, 200, 50))
local btnGodMode = criarBotaoSimples("Ativar Modo Deus (Client-Side)", pageScripts, Color3.fromRGB(150, 100, 0))
local btnInvis = criarBotaoSimples("Ativar Invisibilidade (Auto-Respawn)", pageScripts)
local btnSpec = criarBotaoSimples("Espionar Próximo Jogador", pageScripts)
local btnCloneSkin = criarBotaoSimples("Clonar Skin (Do Alvo Espiado)", pageScripts, Color3.fromRGB(180, 50, 150))
local btnUnspec = criarBotaoSimples("Parar Espionagem", pageScripts, Color3.fromRGB(100, 50, 50))

-- >>> LÓGICAS DA PÁGINA 1 <<<

-- Botão para alterar o Gatilho do Aimbot (Automático x Segurar)
btnAimbotTrigger.MouseButton1Click:Connect(function()
    aimbotAuto = not aimbotAuto
    btnAimbotTrigger.Text = aimbotAuto and "Gatilho Aimbot: Automático (Sem Segurar)" or "Gatilho Aimbot: Ao Segurar (Touch/Click/Shift)"
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
        btnCloneSkin.Text = "Skin Clonada: " .. alvo.Name; task.wait(2); btnCloneSkin.Text = "Clonar Skin (Do Alvo Espiado)"
    end
end)

btnAimbotMode.MouseButton1Click:Connect(function() aimbotModoMouse = not aimbotModoMouse; btnAimbotMode.Text = aimbotModoMouse and "Modo Aimbot: Mais Próximo da Mira" or "Modo Aimbot: Mais Próximo do Personagem" end)

local function pegarInimigoMaisProximo()
    local alvoMaisProximo = nil; local menorDistancia = math.huge; local camera = workspace.CurrentCamera
    local meuHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if player.Team ~= nil and p.Team ~= nil and player.Team == p.Team then continue end
            if aimbotModoMouse then
                local posTela, naTela = camera:WorldToViewportPoint(p.Character.Head.Position)
                if naTela then
                    local centroTela = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local distancia = (Vector2.new(posTela.X, posTela.Y) - centroTela).Magnitude
                    if distancia < menorDistancia then menorDistancia = distancia; alvoMaisProximo = p.Character.Head end
                end
            else
                if meuHrp and p.Character:FindFirstChild("HumanoidRootPart") then
                    local distancia = (p.Character.HumanoidRootPart.Position - meuHrp.Position).Magnitude
                    if distancia < menorDistancia then menorDistancia = distancia; alvoMaisProximo = p.Character.Head end
                end
            end
        end
    end
    return alvoMaisProximo
end

btnAimbot.MouseButton1Click:Connect(function()
    aimbotAtivado = not aimbotAtivado; btnAimbot.Text = aimbotAtivado and "Aimbot: ATIVADO" or "Ativar Aimbot"
    if aimbotAtivado then 
        aimbotConnection = RunService.RenderStepped:Connect(function() 
            -- Nova Lógica: Trava se estiver no modo Automático OU se a pessoa decidir segurar a tela/shift
            if aimbotAuto or isAimingInput or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                local alvo = pegarInimigoMaisProximo(); if alvo then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, alvo.Position) end 
            end
        end)
    else if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end end
end)

btnEsp.MouseButton1Click:Connect(function()
    espAtivado = not espAtivado; btnEsp.Text = espAtivado and "ESP: ATIVADO" or "Ativar ESP (Com Distância)"
    if espAtivado then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head; local tag = head:FindFirstChild("ESPTag")
                    if not tag then
                        local bgui = Instance.new("BillboardGui", head); bgui.Name = "ESPTag"; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(0, 255, 150); txt.TextStrokeTransparency = 0; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold; tag = bgui
                    end
                    local dist = 0; if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then dist = math.floor((player.Character.HumanoidRootPart.Position - head.Position).Magnitude) end
                    tag.TextLabel.Text = p.Name .. " (" .. tostring(dist) .. "m)"
                end
            end
        end)
    else
        if espConnection then espConnection:Disconnect(); espConnection = nil end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("ESPTag"); if tag then tag:Destroy() end end end
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
    fullbrightAtivado = not fullbrightAtivado; btnFullbright.Text = fullbrightAtivado and "Visão Noturna: ATIVADA" or "Visão Noturna (Claridade Máxima)"
    if fullbrightAtivado then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else Lighting.Brightness = 1; Lighting.FogEnd = 10000; Lighting.GlobalShadows = true end
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
    invisivel = not invisivel; btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ativar Invisibilidade (Auto-Respawn)"
    if player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = invisivel and 1 or 0 elseif part:IsA("Decal") then part.Transparency = invisivel and 1 or 0 end end end
end)

btnSpec.MouseButton1Click:Connect(function()
    local todos = Players:GetPlayers(); indexSpec = indexSpec + 1; if indexSpec > #todos then indexSpec = 1 end
    local alvo = todos[indexSpec]
    if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid; btnSpec.Text = "Espiando: " .. alvo.Name end
end)

btnUnspec.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character.Humanoid; btnSpec.Text = "Espionar Próximo Jogador" end end)

-- ==========================================
-- PÁGINA 2: INVENTÁRIO
-- ==========================================
Instance.new("Frame", pageInv).Size = UDim2.new(1,0,0,1)
local infoInv = Instance.new("TextLabel", pageInv)
infoInv.Size = UDim2.new(0.9, 0, 0, 45); infoInv.BackgroundTransparency = 1; infoInv.Text = "A maioria das edições de Itens aqui afetarão apenas a sua tela (Client-Side)."; infoInv.TextColor3 = Color3.fromRGB(255, 100, 100); infoInv.TextWrapped = true; infoInv.Font = Enum.Font.GothamBold; infoInv.TextSize = 12

local btnAtualizarInv = criarBotaoSimples("Atualizar Lista de Itens", pageInv, Color3.fromRGB(50, 100, 50))
local listaItensFrame = Instance.new("Frame", pageInv); listaItensFrame.Size = UDim2.new(0.9, 0, 0, 0); listaItensFrame.AutomaticSize = Enum.AutomaticSize.Y; listaItensFrame.BackgroundTransparency = 1
local listaItensLayout = Instance.new("UIListLayout", listaItensFrame); listaItensLayout.Padding = UDim.new(0, 5)

btnAtualizarInv.MouseButton1Click:Connect(function()
    for _, child in pairs(listaItensFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local itensEncontrados = {}
    if player:FindFirstChild("Backpack") then for _, item in pairs(player.Backpack:GetChildren()) do if item:IsA("Tool") or item:IsA("HopperBin") then table.insert(itensEncontrados, item) end end end
    if player.Character then for _, item in pairs(player.Character:GetChildren()) do if item:IsA("Tool") or item:IsA("HopperBin") then table.insert(itensEncontrados, item) end end end
    if #itensEncontrados == 0 then
        local txt = Instance.new("TextLabel", listaItensFrame); txt.Size = UDim2.new(1, 0, 0, 30); txt.BackgroundTransparency = 1; txt.Text = "Nenhum item encontrado no momento."; txt.TextColor3 = Color3.fromRGB(150, 150, 150); txt.Font = Enum.Font.Gotham; txt.TextSize = 13
        return
    end
    for _, item in ipairs(itensEncontrados) do
        local frameItem = Instance.new("Frame", listaItensFrame); frameItem.Size = UDim2.new(1, 0, 0, 40); frameItem.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", frameItem).CornerRadius = UDim.new(0, 8)
        local nomeItem = Instance.new("TextLabel", frameItem); nomeItem.Size = UDim2.new(0.6, 0, 1, 0); nomeItem.Position = UDim2.new(0.05, 0, 0, 0); nomeItem.BackgroundTransparency = 1; nomeItem.Text = item.Name; nomeItem.TextColor3 = Color3.fromRGB(255, 255, 255); nomeItem.TextXAlignment = Enum.TextXAlignment.Left; nomeItem.Font = Enum.Font.GothamSemibold; nomeItem.TextSize = 13
        local btnHackItem = Instance.new("TextButton", frameItem); btnHackItem.Size = UDim2.new(0.3, 0, 0.8, 0); btnHackItem.Position = UDim2.new(0.65, 0, 0.1, 0); btnHackItem.BackgroundColor3 = corTema; btnHackItem.Text = "Editar Local"; btnHackItem.TextColor3 = Color3.fromRGB(0, 0, 0); btnHackItem.Font = Enum.Font.GothamBold; btnHackItem.TextSize = 12; Instance.new("UICorner", btnHackItem).CornerRadius = UDim.new(0, 6)
        
        btnHackItem.MouseButton1Click:Connect(function()
            local editouAlgo = false
            for _, prop in pairs(item:GetDescendants()) do if prop:IsA("NumberValue") or prop:IsA("IntValue") then prop.Value = 99999; editouAlgo = true end end
            if editouAlgo then btnHackItem.Text = "Modificado!"; btnHackItem.BackgroundColor3 = Color3.fromRGB(50, 200, 50) else btnHackItem.Text = "Sem Valores"; btnHackItem.BackgroundColor3 = Color3.fromRGB(150, 50, 50) end
        end)
    end
end)

-- ==========================================
-- PÁGINA 3: TROLLS
-- ==========================================
Instance.new("Frame", pageTroll).Size = UDim2.new(1,0,0,1)

criarDivisoria("Física e Arremesso", pageTroll)
local btnBeyblade = criarBotaoSimples("Tornado Fling (Bata nos outros)", pageTroll, Color3.fromRGB(200, 100, 0))
local btnFoguete = criarBotaoSimples("Arremessar-se (Yeet)", pageTroll, Color3.fromRGB(100, 50, 200))

criarDivisoria("Ilusões Visuais (Apenas p/ Você)", pageTroll)
local btnFakeBan = criarBotaoSimples("Gerar Fake Ban (Chat)", pageTroll, Color3.fromRGB(200, 0, 0))
local btnFakeAdmin = criarBotaoSimples("Gerar Fake Admin (Chat)", pageTroll, Color3.fromRGB(0, 200, 0))

btnBeyblade.MouseButton1Click:Connect(function()
    beybladeAtivado = not beybladeAtivado
    btnBeyblade.Text = beybladeAtivado and "Tornado Fling: ATIVADO" or "Tornado Fling (Bata nos outros)"
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if beybladeAtivado and hrp then
        if not hrp:FindFirstChild("BeybladeFling") then
            local bav = Instance.new("BodyAngularVelocity"); bav.Name = "BeybladeFling"; bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bav.AngularVelocity = Vector3.new(0, 1500, 0); bav.Parent = hrp; beybladeObj = bav
        end
    else
        if beybladeObj then beybladeObj:Destroy(); beybladeObj = nil end
        if hrp and hrp:FindFirstChild("BeybladeFling") then hrp.BeybladeFling:Destroy() end
    end
end)

btnFoguete.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then local vel = Instance.new("BodyVelocity"); vel.MaxForce = Vector3.new(0, math.huge, 0); vel.Velocity = Vector3.new(0, 500, 0); vel.Parent = hrp; task.wait(0.5); vel:Destroy() end
end)

btnFakeBan.MouseButton1Click:Connect(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[SISTEMA]: A sua conta foi denunciada multiplas vezes por exploração. A moderação analisará seu cliente em 5 minutos.", Color = Color3.fromRGB(255, 0, 0), Font = Enum.Font.SourceSansBold, TextSize = 18}) end)
btnFakeAdmin.MouseButton1Click:Connect(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[SERVER]: O criador do jogo acabou de entrar no seu servidor.", Color = Color3.fromRGB(255, 255, 0), Font = Enum.Font.SourceSansBold, TextSize = 18}) end)

-- ==========================================
-- PÁGINA 4: CONFIGURAÇÕES DA INTERFACE
-- ==========================================
Instance.new("Frame", pageConfig).Size = UDim2.new(1,0,0,1)

local function criarTituloSecaoConfig(texto, parent)
    local txt = Instance.new("TextLabel", parent); txt.Size = UDim2.new(0.9, 0, 0, 25); txt.BackgroundTransparency = 1; txt.Text = texto; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.Font = Enum.Font.GothamBold; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left
end

criarTituloSecaoConfig("Cor Principal do Hub:", pageConfig)
local cores = {
    {"Azul Neon", Color3.fromRGB(0, 170, 255)}, {"Vermelho Sangue", Color3.fromRGB(255, 50, 50)},
    {"Verde Hacker", Color3.fromRGB(50, 255, 50)}, {"Rosa Choque", Color3.fromRGB(255, 0, 255)}
}
for _, dados in ipairs(cores) do
    local btnCor = criarBotaoSimples(dados[1], pageConfig, dados[2]); btnCor.Size = UDim2.new(0.9, 0, 0, 30); btnCor.TextColor3 = Color3.fromRGB(0,0,0)
    btnCor.MouseButton1Click:Connect(function()
        corTema = dados[2]; mainStroke.Color = corTema
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextBox") then obj.TextColor3 = corTema end end
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextLabel") and obj.Text:match("^%-%-%-") then obj.TextColor3 = corTema end end
        for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") and btn.Visible then if btn.TextColor3 ~= Color3.fromRGB(200,200,200) then btn.TextColor3 = corTema end end end
    end)
end

criarTituloSecaoConfig("Transparência do Fundo:", pageConfig)
local btnSido = criarBotaoSimples("Fundo Sólido (Normal)", pageConfig)
local btnTransp = criarBotaoSimples("Fundo Transparente (Vidro)", pageConfig)
btnSido.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0 end)
btnTransp.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.4 end)

criarTituloSecaoConfig("Estilo das Bordas:", pageConfig)
local btnOcultarBorda = criarBotaoSimples("Ligar/Desligar Linha Neon", pageConfig)
btnOcultarBorda.MouseButton1Click:Connect(function() mainStroke.Enabled = not mainStroke.Enabled end)

-- ==========================================
-- PÁGINA 5: SEGURANÇA (SCANNER)
-- ==========================================
Instance.new("Frame", pageSec).Size = UDim2.new(1,0,0,1)

local infoSec = Instance.new("TextLabel", pageSec)
infoSec.Size = UDim2.new(0.9, 0, 0, 60); infoSec.BackgroundTransparency = 1; infoSec.Text = "Este scanner verifica nomes de arquivos locais suspeitos. Ele não detecta anti-cheats de servidor!"; infoSec.TextColor3 = Color3.fromRGB(180, 180, 180); infoSec.TextWrapped = true; infoSec.Font = Enum.Font.Gotham; infoSec.TextSize = 12

local btnScan = criarBotaoSimples("Iniciar Verificação do Mapa", pageSec, Color3.fromRGB(80, 80, 80))
local resultadoSec = Instance.new("TextLabel", pageSec); resultadoSec.Size = UDim2.new(0.9, 0, 0, 80); resultadoSec.BackgroundTransparency = 1; resultadoSec.Text = "Status: Aguardando verificação..."; resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 255); resultadoSec.TextWrapped = true; resultadoSec.Font = Enum.Font.GothamBold; resultadoSec.TextSize = 14

btnScan.MouseButton1Click:Connect(function()
    btnScan.Text = "Escaneando..."; resultadoSec.Text = "Procurando scripts suspeitos..."; resultadoSec.TextColor3 = Color3.fromRGB(255, 255, 0); task.wait(1.5)
    local suspeito = false
    for _, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") then local nome = string.lower(v.Name); if string.find(nome, "anti") or string.find(nome, "cheat") or string.find(nome, "ban") or string.find(nome, "kick") then suspeito = true; break end end end
    btnScan.Text = "Refazer Verificação"
    if suspeito then resultadoSec.Text = "⚠️ ALERTA: Arquivos de Anti-Cheat detectados no cliente! Risco Alto."; resultadoSec.TextColor3 = Color3.fromRGB(255, 50, 50)
    else resultadoSec.Text = "✅ Aparentemente Seguro: Nenhum sistema básico de Anti-Cheat local foi encontrado."; resultadoSec.TextColor3 = Color3.fromRGB(50, 255, 50) end
end)

-- ==========================================
-- LÓGICA GERAL DA JANELA (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() minimizado = not minimizado; if minimizado then mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false else mainFrame:TweenSize(UDim2.new(0, 420, 0, 380), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end end)
