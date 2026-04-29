-- ==========================================================
-- DEATH NOTE: Sistema de Gerenciamento de Modos de Jogo
-- Script Base para Servidor (ServerScriptService)
-- ==========================================================

local GameManager = {}

-- Enumeração dos Modos de Jogo disponíveis baseados na Wiki
GameManager.GameModes = {
	ShinigamisGrave = "Shinigami's Grave",
	LsGame = "L's Game",
	DeathNote = "Death Note",
	DeathNoteHard = "Death Note (Hard)",
	RemsGame = "Rem's Game",
	NearsGame = "Near's Game",
	MisasGame = "Misa's Game",
	MellosGame = "Mello's Game",
	XKira = "X-Kira",
	RLGL = "Red Light Green Light"
}

-- Enumeração de Papéis (Roles)
GameManager.Roles = {
	Innocent = "Innocent",
	Kira = "Kira",
	L = "L",
	Mello = "Mello",
	Gelus = "Gelus",
	Near = "Near",
	Misa = "Misa",
	Takada = "Takada",
	XKira = "X-Kira",
	Shinigami = "Shinigami",
	Sinner = "Sinner"
}

-- Variáveis de Estado da Partida
local currentMode = nil
local activePlayers = {} -- Jogadores vivos
local playerRoles = {} -- Tabela mapeando [Player] = Role
local isVotingPhase = false

-- ==========================================================
-- FUNÇÕES DE UTILIDADE
-- ==========================================================

-- Retorna um jogador aleatório da lista e o remove da pool de seleção
local function getRandomPlayer(pool)
	if #pool == 0 then return nil end
	local index = math.random(1, #pool)
	local player = pool[index]
	table.remove(pool, index)
	return player
end

-- ==========================================================
-- LÓGICA DE DISTRIBUIÇÃO DE PAPÉIS
-- ==========================================================

function GameManager.AssignRoles(mode, players)
	playerRoles = {}
	activePlayers = {}
	
	-- Copia os jogadores para a pool de sorteio
	local pool = {}
	for _, p in ipairs(players) do
		table.insert(pool, p)
		table.insert(activePlayers, p)
	end
	
	if mode == GameManager.GameModes.LsGame then
		-- L's Game: 1 L, 1 Gelus, 1 Mello, 2 Kiras, resto Innocent
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.L
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Gelus
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Mello
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Kira
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Kira
		
		-- O resto é inocente
		for _, p in ipairs(pool) do
			playerRoles[p] = GameManager.Roles.Innocent
		end

	elseif mode == GameManager.GameModes.ShinigamisGrave then
		-- 2 Shinigamis, resto Sinners
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Shinigami
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Shinigami
		for _, p in ipairs(pool) do
			playerRoles[p] = GameManager.Roles.Sinner
		end
		
	elseif mode == GameManager.GameModes.MellosGame then
		-- Mello, Near, Kira, Takada, Innocent
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Mello
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Near
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Kira
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.Takada
		for _, p in ipairs(pool) do
			playerRoles[p] = GameManager.Roles.Innocent
		end
		
	elseif mode == GameManager.GameModes.XKira then
		-- 1 X-Kira, 0 a 2 Takadas dependendo do tamanho do servidor
		playerRoles[getRandomPlayer(pool)] = GameManager.Roles.XKira
		
		local numTakadas = #players > 10 and 2 or 1
		for i = 1, numTakadas do
			local t = getRandomPlayer(pool)
			if t then playerRoles[t] = GameManager.Roles.Takada end
		end
		
		for _, p in ipairs(pool) do
			playerRoles[p] = GameManager.Roles.Innocent
		end
	end
	
	-- (Outros modos seguem lógicas similares baseadas na Wiki)
	print("Papéis distribuídos para o modo: " .. mode)
end

-- ==========================================================
-- MECÂNICAS ESPECÍFICAS DE AÇÕES DURANTE O ROUND
-- ==========================================================

-- Lógica para o Gelus proteger alguém (L's Game)
function GameManager.GelusProtect(gelusPlayer, targetPlayer)
	if playerRoles[gelusPlayer] == GameManager.Roles.Gelus then
		targetPlayer:SetAttribute("ProtectedByGelus", true)
		print(targetPlayer.Name .. " foi protegido por Gelus!")
	end
end

-- Lógica para Kira matar (Geral)
function GameManager.KiraAttemptKill(kiraPlayer, targetPlayer)
	local role = playerRoles[kiraPlayer]
	if role == GameManager.Roles.Kira or role == GameManager.Roles.XKira or role == GameManager.Roles.Misa then
		
		-- Verifica se o jogador está protegido (Gelus) ou confinado (Mello)
		if targetPlayer:GetAttribute("ProtectedByGelus") then
			print("Assassinato falhou: Jogador protegido.")
			targetPlayer:SetAttribute("ProtectedByGelus", false) -- Remove proteção após o uso
			return false
		end
		
		if kiraPlayer:GetAttribute("ConfinedByMello") then
			print("Assassinato cancelado: Kira está confinado por Mello.")
			return false
		end
		
		-- Executa a morte
		GameManager.EliminatePlayer(targetPlayer)
		return true
	end
end

-- Lógica para o Mello Confinar / Atirar
function GameManager.MelloAction(melloPlayer, targetPlayer, actionType)
	if playerRoles[melloPlayer] ~= GameManager.Roles.Mello then return end
	
	if actionType == "Confine" and not melloPlayer:GetAttribute("HasActed") then
		targetPlayer:SetAttribute("ConfinedByMello", true)
		melloPlayer:SetAttribute("ConfinedTarget", targetPlayer.Name)
		melloPlayer:SetAttribute("HasActed", true)
		print(targetPlayer.Name .. " foi confinado por Mello.")
		
	elseif actionType == "Shoot" then
		-- Mello só pode atirar se o alvo for Kira e estiver confinado (segundo a wiki)
		local isTargetKira = (playerRoles[targetPlayer] == GameManager.Roles.Kira)
		
		if isTargetKira then
			print("Mello atirou e matou Kira!")
			GameManager.EliminatePlayer(targetPlayer)
		else
			print("Mello atirou na pessoa errada. Ação desperdiçada.")
		end
		melloPlayer:SetAttribute("HasActed", true)
	end
end

-- Lógica de Scanear IDs (L e Near)
function GameManager.ScanID(detectivePlayer, targetPlayer)
	local role = playerRoles[detectivePlayer]
	if role == GameManager.Roles.L or role == GameManager.Roles.Near then
		local targetRole = playerRoles[targetPlayer]
		
		-- Tratamento do Perk "Memory Loss"
		if targetPlayer:GetAttribute("HasMemoryLossPerk") then
			return GameManager.Roles.Innocent
		end
		
		-- Takada aparece como Kira para L/Near no modo X-Kira
		if targetRole == GameManager.Roles.Takada then
			return GameManager.Roles.Kira
		end
		
		return targetRole
	end
end

-- ==========================================================
-- SISTEMA DE ELIMINAÇÃO E FASE DE VOTAÇÃO
-- ==========================================================

function GameManager.EliminatePlayer(player)
	-- Lógica de substituição da Takada
	local role = playerRoles[player]
	if role == GameManager.Roles.Kira and currentMode == GameManager.GameModes.MellosGame then
		-- Procura se há uma Takada viva para assumir
		for p, r in pairs(playerRoles) do
			if r == GameManager.Roles.Takada and table.find(activePlayers, p) then
				playerRoles[p] = GameManager.Roles.Kira
				print("Takada assumiu o papel de Kira!")
				break
			end
		end
	end
	
	-- Remove dos ativos
	local index = table.find(activePlayers, player)
	if index then
		table.remove(activePlayers, index)
	end
	print(player.Name .. " foi eliminado.")
	
	GameManager.CheckWinCondition()
end

function GameManager.StartVotingPhase()
	isVotingPhase = true
	print("Votação iniciada. Todos teletransportados para a sala de reunião.")
	-- Aqui entraria a lógica de UI de contagem de votos
	-- Após os votos:
	-- local mostVotedPlayer = CalculateVotes()
	-- GameManager.EliminatePlayer(mostVotedPlayer)
	isVotingPhase = false
end

-- ==========================================================
-- CONDIÇÕES DE VITÓRIA
-- ==========================================================

function GameManager.CheckWinCondition()
	local kirasAlive = 0
	local innocentsAlive = 0
	local shinigamisAlive = 0
	
	for _, player in ipairs(activePlayers) do
		local r = playerRoles[player]
		if r == GameManager.Roles.Kira or r == GameManager.Roles.XKira or r == GameManager.Roles.Misa then
			kirasAlive = kirasAlive + 1
		elseif r == GameManager.Roles.Shinigami then
			shinigamisAlive = shinigamisAlive + 1
		else
			innocentsAlive = innocentsAlive + 1
		end
	end
	
	if currentMode == GameManager.GameModes.ShinigamisGrave then
		if innocentsAlive == 0 then print("Shinigamis Venceram!") end
	elseif currentMode == GameManager.GameModes.RemsGame then
		if #activePlayers == 2 then
			print("Restam 2 jogadores! Eles se tornam Shinigamis para a batalha final!")
			-- Lógica de transformar ambos em Shinigami
		end
	else
		-- Modos padrão
		if kirasAlive == 0 then
			print("Inocentes Venceram! Nenhum Kira restante.")
		elseif innocentsAlive == 0 then
			print("Kira Venceu! Todos os inocentes foram eliminados.")
		end
	end
end

return GameManager
