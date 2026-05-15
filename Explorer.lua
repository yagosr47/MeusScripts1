-- ==========================================
-- MINI STUDIO EDITOR (CLIENT-SIDE)
-- Permite selecionar e editar blocos do mapa localmente
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
frame.Size = UDim2.new(0, 250, 0, 220)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
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
selectionText.Position = UDim2.new(0.05, 0, 0.15, 0)
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
toggleSelectBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
toggleSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleSelectBtn.Text = "Ativar Seleção (Clique)"
toggleSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleSelectBtn.Font = Enum.Font.GothamBold
toggleSelectBtn.TextSize = 12
toggleSelectBtn.Parent = frame

-- Ferramentas de Edição
local btnDelete = Instance.new("TextButton")
btnDelete.Size = UDim2.new(0.42, 0, 0, 30)
btnDelete.Position = UDim2.new(0.05, 0, 0.5, 0)
btnDelete.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnDelete.Text = "Deletar (Del)"
btnDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDelete.Font = Enum.Font.GothamBold
btnDelete.TextSize = 12
btnDelete.Parent = frame

local btnInvisible = Instance.new("TextButton")
btnInvisible.Size = UDim2.new(0.42, 0, 0, 30)
btnInvisible.Position = UDim2.new(0.53, 0, 0.5, 0)
btnInvisible.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnInvisible.Text = "Invisível"
btnInvisible.TextColor3 = Color3.fromRGB(255, 255, 255)
btnInvisible.Font = Enum.Font.GothamBold
btnInvisible.TextSize = 12
btnInvisible.Parent = frame

local btnColor = Instance.new("TextButton")
btnColor.Size = UDim2.new(0.9, 0, 0, 30)
btnColor.Position = UDim2.new(0.05, 0, 0.68, 0)
btnColor.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
btnColor.Text = "Mudar Cor Aleatória"
btnColor.TextColor3 = Color3.fromRGB(255, 255, 255)
btnColor.Font = Enum.Font.GothamBold
btnColor.TextSize = 12
btnColor.Parent = frame

local btnNoclip = Instance.new("TextButton")
btnNoclip.Size = UDim2.new(0.9, 0, 0, 30)
btnNoclip.Position = UDim2.new(0.05, 0, 0.84, 0)
btnNoclip.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
btnNoclip.Text = "Remover Colisão"
btnNoclip.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNoclip.Font = Enum.Font.GothamBold
btnNoclip.TextSize = 12
btnNoclip.Parent = frame

-- Arredondar botões
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
local highlight = Instance.new("Highlight") -- Efeito de brilho na peça selecionada
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(0, 255, 255)

-- Função para atualizar a seleção
local function updateSelection(part)
    selectedPart = part
    if part then
        selectionText.Text = " Selecionado: " .. part.Name
        highlight.Parent = part
    else
        selectionText.Text = " Selecionado: Nenhum"
        highlight.Parent = nil
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
        -- Evita selecionar coisas do próprio personagem
        if not mouse.Target:IsDescendantOf(player.Character) then
            updateSelection(mouse.Target)
        end
    end
end)

-- Ações dos Botões de Edição
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
