util.AddNetworkString("Virus roundMusic")
util.AddNetworkString("Virus sendStartGUIRoundTimers")

local function startClientsideRoundTimers()
	net.Start("Virus sendStartGUIRoundTimers")
	net.WriteInt(VIRUS.config.roundTime, 3)
	net.Broadcast()
end

function VIRUS.roundStart()
	VIRUS.currentRound.playerList = player.GetAll()
	VIRUS.currentRound.noOfPlayers = #VIRUS.currentRound.playerList
	VIRUS.currentRound.noOfInfected = 0

	VIRUS.generateFirstInfected()

	timer.Create("RoundTimer", VIRUS.config.roundTime, 1, VIRUS.roundFinish)

	sendGamemodeMessage("You're infected, take down the survivors!", 2, false, true)
	sendGamemodeMessage("You're a survivor. Take down the infected!", 2, true)

	startClientsideRoundTimers()

	for k, ply in pairs(player.GetAll()) do
		ply:SetNWInt("Virus killCount", 0)
	end

	net.Start("Virus updateCurrentRound")
		net.WriteInt(VIRUS.currentRound.number, 10)
	net.Broadcast()

	net.Start("Virus roundMusic")
	net.Broadcast()
end

local function setupPhase()
	net.Start("Virus warmupPeriod")
	net.Broadcast()

	timer.Create("minPlayerCheckLoop", 2, 0, function()
		net.Start("Virus warmupPeriod") -- Makes sure the warmup period plays for new players too.
		net.Broadcast()

		if  #player.GetAll() >= MINIMUM_PLAYER_AMOUNT then
			sendGamemodeMessage("Get ready for Round " .. VIRUS.currentRound.number, 3)

			for k, ply in pairs(player.GetAll()) do
				ply:Respawn()
			end

			timer.Simple(7, function()
				sendGamemodeMessage("Ready!", 1)
				sendGamemodeMessage("Set!", 1)
			end)

			timer.Simple(9, VIRUS.roundStart)

			timer.Remove("minPlayerCheckLoop")
		end
	end)
end

function GM:Initialize()
	setupPhase();
end

local function transitionToSetupPhase()
	VIRUS.currentRound.number = VIRUS.currentRound.number + 1

	if (VIRUS.currentRound.number == 9) then
		Msg("Changing to the next map.")

		for k, ply in pairs( player.GetAll() ) do
			ply:ChatPrint("Changing to the next map!") -- Announce it too all players, else they will be confused!
		end

		timer.Simple(5, function()  -- Give the player 5 seconds to read that the map will change before actually changing it directly at round 4!
			RunConsoleCommand("changelevel", game.GetMapNext()) -- TODO: GetMapNext() finds maps SET BY the mapcyclefile console command.
		end)

		return
	end

	for k, ent in pairs(VIRUS.createdSprites) do
		if ent == nil || !ent:IsValid() then continue end
		ent:Remove()
	end

	for k, ply in pairs(player.GetAll()) do
		VIRUS.configurePlayerAsHuman(ply) -- TODO: Need to remove sprites from humans
		ply:Spawn()
	end

	VIRUS.createdSprites = {}
	Virus = {}

	setupPhase()
end

function VIRUS.roundFinish() -- TODO: Remove or revise forced mechanic, unless if amount of players dips below a threshold we need to force end the game at some point.
	timer.Remove("RoundTimer")

	local leaderboard = {}

	for k, ply in pairs(player.GetAll()) do
		table.insert(leaderboard, ply)
	end

	table.sort(leaderboard, function(a, b)
		return a:GetNWInt("kills") > b:GetNWInt("kills")
	end)

	for k, ply in pairs(player.GetAll()) do
		net.Start("Virus drawRoundEndPhase")
		print(table.KeyFromValue(leaderboard,ply))
		net.WriteInt(table.KeyFromValue(leaderboard, ply), 2)
		net.Send(ply)
	end

	net.Start("Virus survivorsWin") -- TODO Sometimes survivors don't win. Obviously.
	net.Broadcast()

	timer.Simple(6, transitionToSetupPhase) -- TODO: Fine tune the timer. Is it too long or necessary length for the show of rankings?
end

function VIRUS.checkRoundState()
	local playerList = player.GetAll()

	if VIRUS.currentRound.noOfInfected == 0 && playerList != nil then
		VIRUS.generateFirstInfected() -- TODO What happens when there is 1 player left and they get infected?
	end

	if VIRUS.currentRound.noOfPlayers == VIRUS.currentRound.noOfInfected then
		VIRUS.roundFinish()
	end
end
