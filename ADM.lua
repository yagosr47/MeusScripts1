-- =========================================================
-- SISTEMA COMPLETO DE COMANDOS ADM (SERVER-SIDE)
-- =========================================================

local Players = game:GetService("Players")

-- =========================================================
-- CONFIGURAÇÕES
-- =========================================================
local Prefix = ";" -- O prefixo usado antes do comando (Ex: ;kill me)

-- Lista de Administradores. Adicione os nomes de usuário (Username, não DisplayName)
local Admins = {
    ["yagosr47"] = true,
    ["NomeDeOutroAdminAqui"] = true
}

-- =========================================================
-- FUNÇÕES AUXILIARES
-- =========================================================

-- Verifica se o jogador é admin
local function IsAdmin(player)
    return Admins[player.Name] == true
end

-- Função para encontrar o(s) alvo(s) baseado no texto digitado
local function GetTargets(caller, targetString)
    local targets = {}
    if not targetString then return targets end
    
    targetString = string.lower(targetString)
    
    if targetString == "me" then
        table.insert(targets, caller)
    elseif targetString == "all" then
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(targets, p)
        end
    elseif targetString == "others" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= caller then 
                table.insert(targets, p) 
            end
        end
    else
        -- Busca por parte do nome (ex: "yag" encontra "yagosr47")
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, #targetString) == targetString then
                table.insert(targets, p)
            end
        end
    end
    
    return targets
end

-- =========================================================
-- LISTA DE COMANDOS
-- =========================================================
local Commands = {}

-- Comando: Kill (Mata o jogador)
-- Uso: ;kill [jogador]
Commands["kill"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
end

-- Comando: Kick (Expulsa o jogador do servidor)
-- Uso: ;kick [jogador] [motivo]
Commands["kick"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    table.remove(args, 1) -- Remove o nome do alvo da lista de argumentos
    local reason = table.concat(args, " ")
    if reason == "" then reason = "Você foi expulso pelo Administrador." end

    for _, target in ipairs(targets) do
        target:Kick(reason)
    end
end

-- Comando: Speed / Ws (Altera a velocidade)
-- Uso: ;speed [jogador] [numero]
Commands["speed"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    local speedValue = tonumber(args[2]) or 16

    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = speedValue
        end
    end
end

-- Comando: Jump (Altera o pulo)
-- Uso: ;jump [jogador] [numero]
Commands["jump"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    local jumpValue = tonumber(args[2]) or 50

    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.JumpPower = jumpValue
            target.Character.Humanoid.UseJumpPower = true
        end
    end
end

-- Comando: God (Deixa o jogador invencível)
-- Uso: ;god [jogador]
Commands["god"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = math.huge
            target.Character.Humanoid.Health = math.huge
        end
    end
end

-- Comando: Ungod (Remove a invencibilidade)
-- Uso: ;ungod [jogador]
Commands["ungod"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = 100
            target.Character.Humanoid.Health = 100
        end
    end
end

-- Comando: Heal (Cura o jogador)
-- Uso: ;heal [jogador]
Commands["heal"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = target.Character.Humanoid.MaxHealth
        end
    end
end

-- Comando: Tp / Teleport (Teleporta o jogador A para o jogador B)
-- Uso: ;tp [jogador1] [jogador2]
Commands["tp"] = function(caller, args)
    local targetsA = GetTargets(caller, args[1])
    local targetsB = GetTargets(caller, args[2])
    
    if #targetsA > 0 and #targetsB > 0 then
        local destination = targetsB[1].Character
        if destination and destination:FindFirstChild("HumanoidRootPart") then
            for _, targetA in ipairs(targetsA) do
                if targetA.Character and targetA.Character:FindFirstChild("HumanoidRootPart") then
                    targetA.Character.HumanoidRootPart.CFrame = destination.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

-- Comando: Bring (Traz o jogador até você)
-- Uso: ;bring [jogador]
Commands["bring"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    if caller.Character and caller.Character:FindFirstChild("HumanoidRootPart") then
        local myCFrame = caller.Character.HumanoidRootPart.CFrame
        for _, target in ipairs(targets) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                -- Adiciona um pequeno offset para não nascer exatamente dentro de você
                target.Character.HumanoidRootPart.CFrame = myCFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

-- Comando: Goto (Vai até o jogador)
-- Uso: ;goto [jogador]
Commands["goto"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    if #targets > 0 then
        local destination = targets[1].Character
        if destination and destination:FindFirstChild("HumanoidRootPart") and caller.Character and caller.Character:FindFirstChild("HumanoidRootPart") then
            caller.Character.HumanoidRootPart.CFrame = destination.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

-- Comando: Freeze (Congela o jogador)
-- Uso: ;freeze [jogador]
Commands["freeze"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = true
        end
    end
end

-- Comando: Unfreeze (Descongela o jogador)
-- Uso: ;unfreeze [jogador]
Commands["unfreeze"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = false
        end
    end
end

-- Comando: Ff (Dá ForceField ao jogador)
-- Uso: ;ff [jogador]
Commands["ff"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character then
            if not target.Character:FindFirstChildOfClass("ForceField") then
                Instance.new("ForceField", target.Character)
            end
        end
    end
end

-- Comando: Unff (Remove o ForceField)
-- Uso: ;unff [jogador]
Commands["unff"] = function(caller, args)
    local targets = GetTargets(caller, args[1])
    for _, target in ipairs(targets) do
        if target.Character then
            for _, child in ipairs(target.Character:GetChildren()) do
                if child:IsA("ForceField") then
                    child:Destroy()
                end
            end
        end
    end
end

-- =========================================================
-- PROCESSADOR DE MENSAGENS (CHAT)
-- =========================================================

local function OnPlayerAdded(player)
    player.Chatted:Connect(function(message)
        -- Verifica se o jogador é admin e se a mensagem começa com o prefixo
        if IsAdmin(player) and string.sub(message, 1, #Prefix) == Prefix then
            
            -- Remove o prefixo da mensagem e divide em palavras
            local msgWithoutPrefix = string.sub(message, #Prefix + 1)
            local args = string.split(msgWithoutPrefix, " ")
            
            -- O primeiro argumento é o comando (tudo em minúsculo para facilitar)
            local commandName = string.lower(args[1])
            table.remove(args, 1) -- Remove o nome do comando da lista de argumentos
            
            -- Executa o comando se ele existir na tabela de Commands
            if Commands[commandName] then
                -- O 'pcall' evita que o script quebre se houver um erro durante a execução do comando
                local success, err = pcall(function()
                    Commands[commandName](player, args)
                end)
                
                if not success then
                    warn("Erro ao executar comando " .. commandName .. ": " .. tostring(err))
                end
            end
        end
    end)
end

-- Conecta a função aos jogadores que já estão no jogo e aos que entrarem
for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
