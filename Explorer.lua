-- ==========================================
-- MINI STUDIO EDITOR (CLIENT-SIDE) V2
-- Permite selecionar, editar blocos e o mundo localmente
-- ==========================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- Evita duplicar a interface
if CoreGui:FindFirstChild("MiniStudioGUI") then
    CoreGui.MiniStudioGUI:Destroy()
end

-- ==========================================
-- 1. CRIANDO A INTERFACE (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiniStudioGUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
-- Aumentei a altura para 440 para caber os novos botões
frame.Size = UDim2.new(0, 250, 0, 440) 
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🛠️ Mini Studio (Local)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- Texto mostrando o objeto selecionado
local selectionText = Instance.new("TextLabel")
selectionText.Size = UDim2.new(0.9, 0, 0, 25)
selectionText.Position = UDim2.new(0.05, 0, 0, 35)
selectionText.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
selectionText.Text = " Selecionado: Nenhum"
selectionText.TextColor3 = Color3.fromRGB(200, 200, 200)
selectionText.TextXAlignment = Enum.TextXAlignment.Left
selectionText.Font = Enum.Font.Gotham
selectionText.TextSize = 12
selectionText.Parent = frame

-- Botão de Ativar Ferramenta de Seleção
local toggleSelectBtn = Instance.new("TextButton")
toggleSelectBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleSelectBtn.Position = UDim2.new(0.05, 0, 0, 65)
toggleSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleSelectBtn.Text = "Ativar Seleção (Clique)"
toggleSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleSelectBtn.Font = Enum.Font.GothamBold
toggleSelectBtn.TextSize = 12
toggleSelectBtn.Parent = frame

-- ================== FERRAMENTAS ORIGINAIS ==================

local btnDelete = Instance.new("TextButton")
btnDelete.Size = UDim2.new(0.42, 0, 0, 30)
btnDelete.Position = UDim2.new(0.05, 0, 0, 105)
btnDelete.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnDelete.Text = "Deletar (Del)"
btnDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDelete.Font = Enum.Font.GothamBold
btnDelete.TextSize = 12
btnDelete.Parent = frame

local btnInvisible = Instance.new("TextButton")
btnInvisible.Size = UDim2.new(0.42, 0, 0, 30)
btnInvisible.Position = UDim2.new(0.53, 0, 0, 105)
btnInvisible.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnInvisible.Text = "Invisível"
btnInvisible.TextColor3 = Color3.fromRGB(255, 255, 255)
btnInvisible.Font = Enum.Font.GothamBold
btnInvisible.TextSize = 12
btnInvisible.Parent = frame

local btnColor = Instance.new("TextButton")
btnColor.Size = UDim2.new(0.9, 0, 0, 30)
btnColor.Position = UDim2.new(0.05, 0, 0, 145)
btnColor.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
btnColor.Text = "Mudar Cor Aleatória"
btnColor.TextColor3 = Color3.fromRGB(255, 255, 255)
btnColor.Font = Enum.Font.GothamBold
btnColor.TextSize = 12
btnColor.Parent = frame

local btnNoclip = Instance.new("TextButton")
btnNoclip.Size = UDim2.new(0.9, 0, 0, 30)
btnNoclip.Position = UDim2.new(0.05, 0, 0, 185)
btnNoclip.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
btnNoclip.Text = "Remover Colisão"
btnNoclip.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNoclip.Font = Enum.Font.GothamBold
btnNoclip.TextSize = 12
btnNoclip.Parent = frame

-- ================== NOVAS FERRAMENTAS ==================

local btnPhysics = Instance.new("TextButton")
btnPhysics.Size = UDim2.new(0.42, 0, 0, 30)
btnPhysics.Position = UDim2.new(0.05, 0, 0, 225)
btnPhysics.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
btnPhysics.Text = "Soltar (Física)"
btnPhysics.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPhysics.Font = Enum.Font.GothamBold
btnPhysics.TextSize = 12
btnPhysics.Parent = frame

local btnClone = Instance.new("TextButton")
btnClone.Size = UDim2.new(0.42, 0, 0, 30)
btnClone.Position = UDim2.new(0.53, 0, 0, 225)
btnClone.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
btnClone.Text = "Clonar Bloco"
btnClone.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClone.Font = Enum.Font.GothamBold
btnClone.TextSize = 12
btnClone.Parent = frame

local btnScale = Instance.new("TextButton")
btnScale.Size = UDim2.new(0.9, 0, 0, 30)
btnScale.Position = UDim2.new(0.05, 0, 0, 265)
btnScale.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
btnScale.Text = "Aumentar Tamanho (1.5x)"
btnScale.TextColor3 = Color3.fromRGB(255, 255, 255)
btnScale.Font = Enum.Font.GothamBold
btnScale.TextSize = 12
btnScale.Parent = frame

local btnGravity = Instance.new("TextButton")
btnGravity.Size = UDim2.new(0.9, 0, 0, 30)
btnGravity.Position = UDim2.new(0.05, 0, 0, 305)
btnGravity.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
btnGravity.Text = "Modificar Gravidade"
btnGravity.TextColor3 = Color3.fromRGB(255, 255, 255)
btnGravity.Font = Enum.Font.GothamBold
btnGravity.TextSize = 12
btnGravity.Parent = frame

local btnSpeed = Instance.new("TextButton")
btnSpeed.Size = UDim2.new(0.9, 0, 0, 30)
btnSpeed.Position = UDim2.new(0.05, 0, 0, 345)
btnSpeed.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
btnSpeed.Text = "Super Velocidade"
btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.TextSize = 12
btnSpeed.Parent = frame

local btnTime = Instance.new("TextButton")
btnTime.Size = UDim2.new(0.9, 0, 0, 30)
btnTime.Position = UDim2.new(0.05, 0, 0, 385)
btnTime.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
btnTime.Text = "Avançar Tempo (+4h)"
btnTime.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTime.Font = Enum.Font.GothamBold
btnTime.TextSize = 12
btnTime.Parent = frame

-- Arredondar todos os botões automaticamente
for _, obj in ipairs(frame:GetChildren()) do
    if obj:IsA("TextButton") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = obj
    end
end

-- ==========================================
-- 2. LÓGICA DO EDITOR
-- ==========================================
local isSelecting = false
local selectedPart = nil
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(0, 255, 255)

-- Função para atualizar a seleção
local function updateSelection(part)
    selectedPart = part
    if part then
        selectionText.Text = " Selecionado: " .. part.Name
        highlight.Parent = part
        
        -- Atualizar texto de física se o bloco mudar
        if part.Anchored then
            btnPhysics.Text = "Soltar (Física)"
            btnPhysics.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        else
            btnPhysics.Text = "Congelar (Ancorar)"
            btnPhysics.BackgroundColor3 = Color3.fromRGB(50, 200, 150)
        end
    else
        selectionText.Text = " Selecionado: Nenhum"
        highlight.Parent = nil
        btnPhysics.Text = "Soltar (Física)"
    end
end

-- Ativar/Desativar Ferramenta de Seleção
toggleSelectBtn.MouseButton1Click:Connect(function()
    isSelecting = not isSelecting
    if isSelecting then
        toggleSelectBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        toggleSelectBtn.Text = "Modo Seleção: ATIVADO"
    else
        toggleSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        toggleSelectBtn.Text = "Ativar Seleção (Clique)"
        updateSelection(nil)
    end
end)

-- Detectar clique do mouse nas peças do jogo
mouse.Button1Down:Connect(function()
    if isSelecting and mouse.Target then
        if not mouse.Target:IsDescendantOf(player.Character) then
            updateSelection(mouse.Target)
        end
    end
end)

-- ================= AÇÕES DOS BOTÕES =================

btnDelete.MouseButton1Click:Connect(function()
    if selectedPart then
        selectedPart:Destroy()
        updateSelection(nil)
    end
end)

btnInvisible.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        if selectedPart.Transparency == 1 then
            selectedPart.Transparency = 0
            btnInvisible.Text = "Invisível"
        else
            selectedPart.Transparency = 1
            btnInvisible.Text = "Visível"
        end
    end
end)

btnColor.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        selectedPart.BrickColor = BrickColor.Random()
    end
end)

btnNoclip.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        selectedPart.CanCollide = not selectedPart.CanCollide
        if selectedPart.CanCollide then
            btnNoclip.Text = "Remover Colisão"
            btnNoclip.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        else
            btnNoclip.Text = "Restaurar Colisão"
            btnNoclip.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
        end
    end
end)

btnPhysics.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        selectedPart.Anchored = not selectedPart.Anchored
        if selectedPart.Anchored then
            btnPhysics.Text = "Soltar (Física)"
            btnPhysics.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        else
            btnPhysics.Text = "Congelar (Ancorar)"
            btnPhysics.BackgroundColor3 = Color3.fromRGB(50, 200, 150)
        end
    end
end)

btnClone.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        local clone = selectedPart:Clone()
        clone.Parent = selectedPart.Parent
        -- Posiciona o clone exatamente em cima da peça original
        clone.Position = selectedPart.Position + Vector3.new(0, selectedPart.Size.Y, 0)
        updateSelection(clone) -- Seleciona o novo clone automaticamente
    end
end)

btnScale.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        -- Aumenta o tamanho em 50%
        selectedPart.Size = selectedPart.Size * 1.5 
    end
end)

btnGravity.MouseButton1Click:Connect(function()
    -- Gravidade normal do Roblox é 196.2
    if workspace.Gravity > 50 then
        workspace.Gravity = 30 -- Gravidade Lunar
        btnGravity.Text = "Gravidade: LUNAR"
        btnGravity.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    else
        workspace.Gravity = 196.2 -- Gravidade Normal
        btnGravity.Text = "Modificar Gravidade"
        btnGravity.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    end
end)

local isFast = false
btnSpeed.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        isFast = not isFast
        if isFast then
            char.Humanoid.WalkSpeed = 100
            btnSpeed.Text = "Velocidade: RÁPIDA (100)"
            btnSpeed.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
        else
            char.Humanoid.WalkSpeed = 16 -- Velocidade padrão do Roblox
            btnSpeed.Text = "Super Velocidade"
            btnSpeed.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        end
    end
end)

btnTime.MouseButton1Click:Connect(function()
    local lighting = game:GetService("Lighting")
    lighting.ClockTime = (lighting.ClockTime + 4) % 24
end)
