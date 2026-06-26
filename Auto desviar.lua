local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local DISTANCIA_SEGURA = 15 -- Distância mínima permitida em studs

RunService.Heartbeat:Connect(function()
    local character = localPlayer.Character
    -- Verifica se o personagem e seus componentes essenciais existem
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then 
        return 
    end
    
    local myRoot = character.HumanoidRootPart
    local humanoid = character.Humanoid
    
    local nearestPlayer = nil
    local shortestDistance = DISTANCIA_SEGURA
    
    -- Verifica todos os jogadores no servidor
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            
            -- Encontra o jogador que está mais perto e dentro da zona de perigo
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    -- Lógica de Interrupção e Evasão
    if nearestPlayer then
        local targetRoot = nearestPlayer.Character.HumanoidRootPart
        
        -- Calcula a direção exata oposta ao jogador próximo
        local directionAway = (myRoot.Position - targetRoot.Position).Unit
        
        -- Define o ponto de fuga seguro ignorando o eixo Y (para não tentar voar ou enterrar)
        local fleeVector = Vector3.new(directionAway.X, 0, directionAway.Z)
        local safePosition = myRoot.Position + (fleeVector * DISTANCIA_SEGURA)
        
        -- MoveTo sobrescreve temporariamente o input analógico/teclado do usuário
        humanoid:MoveTo(safePosition)
    end
end)
