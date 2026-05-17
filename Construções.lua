-- ==========================================
-- CONSTRUTOR HUB - CLIENT SIDE
-- ==========================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Criação da Interface (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ConstrutorHub"
ScreenGui.Parent = game.CoreGui or player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Construtor Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Função auxiliar para criar botões
local function CreateButton(text, yPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = UDim2.new(0.1, 0, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = MainFrame
    return button
end

local BtnHouse = CreateButton("Spawnar Casa (Local)", 80)
local BtnCar = CreateButton("Spawnar Carro (Local)", 140)
local BtnAnime = CreateButton("Spawnar NPC IA (Local)", 200)
local BtnClose = CreateButton("Fechar", 340)
BtnClose.BackgroundColor3 = Color3.fromRGB(150, 40, 40)

-- ==========================================
-- LÓGICA DE CONSTRUÇÃO
-- ==========================================

-- 1. Spawnar Casa com Física
BtnHouse.MouseButton1Click:Connect(function()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local spawnPos = rootPart.Position + Vector3.new(0, 0, -15) -- Spawna na frente do jogador
    
    local houseModel = Instance.new("Model")
    houseModel.Name = "LocalHouse"
    houseModel.Parent = workspace
    
    -- Chão
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(30, 1, 30)
    floor.Position = spawnPos
    floor.Anchored = true
    floor.BrickColor = BrickColor.new("Wood")
    floor.Material = Enum.Material.WoodPlanks
    floor.Parent = houseModel
    
    -- Paredes (Básicas)
    local wall1 = Instance.new("Part")
    wall1.Size = Vector3.new(30, 15, 1)
    wall1.Position = spawnPos + Vector3.new(0, 7.5, -14.5)
    wall1.Anchored = true
    wall1.Parent = houseModel
    
    -- Nota: Para uma casa completa, você replicaria a lógica das paredes em todos os lados 
    -- e adicionaria um teto. Isso demonstra a base de colisão invisível para o servidor, 
    -- mas sólida para você.
end)

-- 2. Spawnar Carro Funcional (Básico)
BtnCar.MouseButton1Click:Connect(function()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local spawnPos = rootPart.Position + Vector3.new(0, 5, -10)
    
    local carModel = Instance.new("Model")
    carModel.Name = "LocalCar"
    carModel.Parent = workspace
    
    -- Chassi
    local chassis = Instance.new("Part")
    chassis.Size = Vector3.new(6, 1, 10)
    chassis.Position = spawnPos
    chassis.BrickColor = BrickColor.new("Really black")
    chassis.Parent = carModel
    
    -- Assento de Veículo (Isso dá a funcionalidade de dirigir)
    local seat = Instance.new("VehicleSeat")
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = spawnPos + Vector3.new(0, 1, 0)
    seat.Parent = carModel
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = chassis
    weld.Part1 = seat
    weld.Parent = carModel
    
    -- Criar rodas e eixos (HingeConstraints) em um script local exige muita matemática de CFrame.
    -- O VehicleSeat por si só reconhece o jogador. Para as rodas girarem fisicamente via script,
    -- você precisaria anexar CylinderParts com HingeConstraints setados para 'Motor'.
    
    print("Protótipo de chassi gerado. Adicione HingeConstraints para rodas giratórias.")
end)

-- 3. Spawnar Personagem de Anime com IA
BtnAnime.MouseButton1Click:Connect(function()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local spawnPos = rootPart.Position + Vector3.new(5, 5, 5)
    
    -- Criando um Dummy básico (você substituiria os IDs de Mesh aqui para parecer um anime)
    local npc = Instance.new("Model")
    npc.Name = "AnimeNPC"
    npc.Parent = workspace
    
    local npcRoot = Instance.new("Part")
    npcRoot.Name = "HumanoidRootPart"
    npcRoot.Size = Vector3.new(2, 2, 1)
    npcRoot.Position = spawnPos
    npcRoot.Parent = npc
    
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = npc
    
    -- IA Básica de Perseguição (Follow Player)
    task.spawn(function()
        while task.wait(0.5) do
            if npc:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                npc.Humanoid:MoveTo(character.HumanoidRootPart.Position)
            end
        end
    end)
    
    -- Para adicionar animações, você precisa criar um objeto 'Animation' e dar Play() no Animator do Humanoid.
    -- Exemplo: local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://SEU_ID"
end)

-- Fechar GUI
BtnClose.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Permite arrastar o menu pela tela
local dragging
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
