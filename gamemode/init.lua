AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_notice.lua")

include("shared.lua")

util.AddNetworkString("Virus updateCurrentRound")
util.AddNetworkString("Virus RoundMusic")

resource.AddFile("materials/hud_infected_radar.vmt")
resource.AddFile("materials/hud_infected_rank.vmt")
resource.AddFile("materials/hud_infected_score.vmt")
resource.AddFile("materials/hud_infected_time.vmt")

resource.AddFile("materials/hud_survivor_radar.vmt")
resource.AddFile("materials/hud_survivor_rank.vmt")
resource.AddFile("materials/hud_survivor_score.vmt")
resource.AddFile("materials/hud_survivor_time.vmt")

resource.AddFile("materials/hud_survivor_ammo.vmt")


--[[local model = LocalPlayer():GetInfo( "cl_playermodel" ) // TODO add custom models
local modelname = player_manager.TranslatePlayerModel( model )]]

Virus = { }				//infected players list
ModName = "Virus"

local config = {
	roundTime = 110
}

local models = {
	normal = Model("models/player/Group03/male_04.mdl"), // TODO: This needs to be multiple player models
	virus = Model("models/player/virusi.mdl"),
	thirdPerson = Model("models/error.mdl")
}

local currentRound = {
	number = 1,
	playerList = {},
	noOfPlayers = 0,
	noOfInfected = 0
}

local createdSprites = {}

function GM:Initialize()
	setupPhase();
end

function GM:PlayerInitialSpawn(ply)
	ply:SetCollisionGroup(11) // Disables collision with other players.
end

function GM:PlayerDisconnected(ply)
	for i, infected in pairs(Virus) do
		if infected == ply then
			table.remove(Virus, i)
			break;
		end
	end
end

function GM:CanPlayerSuicide(ply)
	//ply:PrintMessage( HUD_PRINTCONSOLE, "Trying to escape life I see.\n" )
	return false
end

function GM:PlayerDeath(victim, Inflictor, killer)
	victim.fireSprite.child:Remove()
	victim.fireSprite:Remove()
	victim:EmitSound("ambient/fire/ignite.waw")
end

local function makeSprite(pos, target, rate)
	local sprite = ents.Create("env_sprite")
	sprite:SetPos(pos)
	sprite:SetKeyValue("rendercolor", "70 255 70")
	sprite:SetKeyValue("renderamt", "150")
	sprite:SetKeyValue("rendermode", "5")
	sprite:SetKeyValue("renderfx", "0")
	sprite:SetKeyValue("model", "sprites/fire1.spr")
	sprite:SetKeyValue("glowproxysize", "32")
	sprite:SetKeyValue("scale", "0.4")
	sprite:SetKeyValue("framerate", rate)
	sprite:SetKeyValue("spawnflags", 1)
	sprite:SetParent(target)
	sprite:Spawn()

	table.insert(createdSprites, sprite)
	return sprite
end

local function attachFireSprite(target)
	local pos = target:GetPos() + Vector( 0, -10, 50 )
	local pos2 = target:GetPos() + Vector( 0, -10, 65 )

	local sprite1 = makeSprite(pos, target, "12")
	local sprite2 = makeSprite(pos2, target, "9")

	sprite1.child = sprite2
	target.flameSprite = sprite1
end

local function configurePlayerAsVirus(ply)
	ply:SetModel(models.virus)

	ply:SetWalkSpeed(320)
	ply:SetRunSpeed(530)

	ply:StripWeapons()
	ply:StripAmmo()

	attachFireSprite(ply)
	ply:EmitSound("gmodtower/virus/player_spawn.wav")
end

local function configurePlayerAsHuman(ply)
	ply:SetModel(models.normal)

	ply:SetWalkSpeed(300)
	ply:SetRunSpeed(525)

	ply:SetNWInt("Virus", 0)
	disableThirdPerson(ply)
end

local pistols = {}

pistols[1] = {
	"weapon_9mm",
	"weapon_dsilen"
}

pistols[2] = {
	"weapon_flakgun",
	"weapon_scifihandgun"
}

local otherWeaponsSet1 = {
	"weapon_thompson",
	"weapon_doublebarrel",
	"weapon_sniper",
	"weapon_sonicshotgun",
	"weapon_rcp120",
	"weapon_smg1"
}

function GM:PlayerLoadout(ply)
	if ply:GetNWInt("Virus") == 1 then
		configurePlayerAsVirus(ply)
	else
		configurePlayerAsHuman(ply)

		ply:GiveAmmo(42, "Pistol", true)
		ply:GiveAmmo(30, "SMG1", true)
		ply:GiveAmmo(64, "Buckshot", true)

		for k, wep in pairs(pistols[math.random(1,2)]) do
			ply:Give(wep)
		end

		ply:Give(otherWeaponsSet1[math.random(1, #otherWeaponsSet1)])
	end

	return true
end

function disableThirdPerson(ply)
	if ply:GetNWInt("thirdperson") == 0 then
		return
	end
	local entity = ply:GetViewEntity()
	ply:SetNWInt("thirdperson", 0)
	ply:SetViewEntity(ply)
	entity:Remove()
end

function enableThirdPerson(ply)
	if ply:GetNWInt("thirdperson") == 1 then
		return
	end

	local entity = ents.Create("prop_dynamic")
	entity:SetModel(models.thirdPerson)
	entity:Spawn()
	entity:SetAngles(ply:GetAngles())
	entity:SetMoveType(MOVETYPE_NONE)
	entity:SetParent(ply)
	entity:SetPos(ply:GetPos() + Vector(0, 0, 60))
	entity:SetRenderMode(RENDERMODE_NONE)
	entity:SetSolid(SOLID_NONE)
	entity:DrawShadow(false)

	ply:SetViewEntity(entity)
	ply:SetNWInt("thirdperson", 1)
end

util.AddNetworkString("Virus sendGamemodeMessage")
local function sendGamemodeMessage(text, survivorExclusive, infectedExclusive)
	if text == nil then return end
	survivorExclusive = survivorExclusive or false
	infectedExclusive = infectedExclusive or false

	if survivorExclusive then
		for k, ply in pairs(player.GetAll()) do
			if ply:GetNWInt("Virus") == 0 then
				net.Start("Virus sendGamemodeMessage")
				net.WriteString(text, 32)
				net.Send(ply)
			end
		end
	elseif infectedExclusive then
		for k, ply in pairs(player.GetAll()) do
			if ply:GetNWInt("Virus") == 1 then
				net.Start("Virus sendGamemodeMessage")
				net.WriteString(text, 32)
				net.Send(ply)
			end
		end
	else
		net.Start("Virus sendGamemodeMessage")
		net.WriteString(text, 32)
		net.Broadcast()
	end
end

function setupPhase()
	timer.Create("minPlayerCheckLoop", 2, 0, function()
		if  #player.GetAll() >= MINIMUM_PLAYER_AMOUNT then
			sendGamemodeMessage("Get ready for Round " .. currentRound.number, false, false)

			for k, ply in pairs(player.GetAll()) do
				ply:Respawn()
			end

			timer.Simple(2, function()
				sendGamemodeMessage("Ready!")
			end)

			timer.Simple(3, preparationBridge)

			timer.Remove("minPlayerCheckLoop")
		end
	end)
end

function preparationBridge()
	sendGamemodeMessage("Set!")
	timer.Simple(1, roundStart)
end

util.AddNetworkString("Virus sendStartGUIRoundTimers")

local function startClientsideRoundTimers()
	net.Start("Virus sendStartGUIRoundTimers")
	net.WriteInt(config.roundTime, 3)
	net.Broadcast()
end

local gracedPlayer

local function registerInfected(ply) // Internal function
	table.insert(Virus, ply)
	ply:SetNWInt("Virus", 1)
	ply:EmitSound("gmodtower/virus/stinger.mp3")
end

local function infectPlayer(ply)	// set ply to nil for a random player
	registerInfected(ply)

	enableThirdPerson(ply)
	configurePlayerAsVirus(ply)

	currentRound.noOfInfected = currentRound.noOfInfected + 1
	checkRoundState()
end

local function generateFirstInfected()
	local players = player.GetAll()
	local randomNumber = math.random(#players)

	if players[randomNumber] == gracedPlayer then
		if players[randomNumber + 1] != nil then
			randomNumber = randomNumber + 1
		elseif players[randomNumber - 1] != nil then
			randomNumber = randomNumber - 1
		else
			print("WARNING // Critical error in generation process.")
			debug.Trace()
			roundStart()
		end
	end

	gracedPlayer = players[randomNumber]
	infectPlayer(players[randomNumber])
end

function roundStart()
	currentRound.playerList = player.GetAll()
	currentRound.noOfPlayers = #currentRound.playerList
	currentRound.noOfInfected = 0

	generateFirstInfected()

	timer.Create("RoundTimer", config.roundTime, 1, roundFinish)

	sendGamemodeMessage("You're infected, take down the survivors!", false, true)
	sendGamemodeMessage("You're a survivor. Take down the infected!", true, false)
	sendGamemodeMessage("The round has begun!", false, false)

	startClientsideRoundTimers()

	net.Start("Virus updateCurrentRound")
		net.WriteInt(currentRound.number, 10)
	net.Broadcast()

	umsg.Start("VirusRoundMusic") // TODO Change to net messages
	umsg.End()
end

local function checkRoundState()
	local playerList = player.GetAll()

	if currentRound.noOfInfected == 0 && playerList != nil then
		local randomPlayer = playerList[math.random(1, #playerList)]
		generateFirstInfected() // TODO What happens when there is 1 player left and they get infected?
	end

	if currentRound.noOfPlayers == currentRound.noOfInfected then
		roundFinish(true)
	end
end

function GM:PlayerDisconnected(ply)
	if table.HasValue(currentRound.playerList, ply) then
		currentRound.noOfPlayers = currentRound.noOfPlayers - 1
		if ply:GetNWInt("Virus") == 1 then
			currentRound.noOfInfected = currentRound.noOfInfected - 1
		end
		checkRoundState()
	end
end

local function infectedRadialHitDetection()
	for i, infected in pairs(Virus) do
		if !infected:IsValid() then return end // check incase no viruses are there at all, caused by someone ragequitting right at round start

		local Objects = ents.FindInSphere( infected:GetPos( ), 30 ) // TODO: This radius was originally 20. Reconsider it if the detection radius is too forgiving.
		for _, ply in pairs(Objects) do
			if ply:IsPlayer( ) && ply:GetNWInt( "Virus" ) != 1 then
				infectPlayer(ply)
			end
		end
	end
end

function GM:Tick()
	infectedRadialHitDetection()
end

util.AddNetworkString("Virus drawRoundEndPhase")

function roundFinish(forced) // TODO: Remove or revise forced mechanic, unless if amount of players dips below a threshold we need to force end the game at some point.
	if !forced then timer.Remove( "RoundTimer"); end

	net.Start("Virus drawRoundEndPhase")
	net.Broadcast()

	for i, ply in ipairs( Virus ) do // TODO: This mechanic is slightly redundant. Players who start off infected should probably have their performance compared to other infected, not to the game in general.
		ply:SetNWInt("Place", #Virus - i + 2) // The +2 is here because if the player won without ever getting infected, he would inadvertantly get second place anyway, with no one being first place.
	end // TODO: It's a coinflip whether the place is set correctly or not. Need to fix this.

	timer.Simple(6, transitionToSetupPhase) // TODO: Fine tune the timer. Is it too long or necessary length for the show of rankings?
end

function transitionToSetupPhase()
	currentRound.number = currentRound.number + 1

	if (currentRound.number == 9) then
		Msg("Changing to the next map.")

		for k, ply in pairs( player.GetAll() ) do
			ply:ChatPrint("Changing to the next map!") // Announce it too all players, else they will be confused!
		end

		timer.Simple(5, function()  // Give the player 5 seconds to read that the map will change before actually changing it directly at round 4!
			RunConsoleCommand("changelevel", game.GetMapNext()) // TODO: GetMapNext() finds maps SET BY the mapcyclefile console command.
		end)

		return
	end

	for k, ent in pairs(createdSprites) do
		if ent == nil || !ent:IsValid() then continue end
		ent:Remove()
	end

	for k, ply in pairs(player.GetAll()) do
		configurePlayerAsHuman(ply) // TODO: Need to remove sprites from humans
		ply:Spawn()
	end

	createdSprites = {}
	Virus = {}

	setupPhase()
end

local function survivorNoDamage(target, dmginfo)
	if target:GetNWInt("Virus") == 0 && target:IsPlayer() then
		dmginfo:ScaleDamage(0)
	end
end

hook.Add("EntityTakeDamage", "survivorNoDamage", survivorNoDamage)
