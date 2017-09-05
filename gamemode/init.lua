AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_notice.lua" )

include( "shared.lua" )
util.AddNetworkString("Virus updateCurrentRound")
util.AddNetworkString("Virus RoundMusic")

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

function GM:PlayerDisconnected( ply )
	for i, infected in ipairs( Virus ) do
		if infected == ply then
			table.remove( Virus, i )
			break;
		end
	end
end

function GM:CanPlayerSuicide( ply )
	//ply:PrintMessage( HUD_PRINTCONSOLE, "Trying to escape life I see.\n" )
	return false
end

function GM:PlayerDeath( victim, Inflictor, killer )
	victim:EmitSound("ambient/fire/ignite.waw")
end

local function configurePlayerAsVirus(ply)
	ply:SetModel(models.virus)

	ply:SetWalkSpeed(320)
	ply:SetRunSpeed(530)
	ply:SetJumpPower(0)

	ply:EmitSound("gmodtower/virus/player_spawn.wav")
end

local function configurePlayerAsHuman(ply)
	ply:SetModel(models.normal)

	ply:SetWalkSpeed(300)
	ply:SetRunSpeed(525)
	ply:SetJumpPower(0)

	ply:SetNWInt("Virus", 0)
	disableThirdPerson(ply)
end

local weapons = {
	"weapon_9mm",
	"weapon_dsilen",
	"weapon_thompson",
	"weapon_doublebarrel",
	"weapon_sniper",
	"weapon_sonicshotgun",
	"weapon_flakgun",
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

		local assignedWeapons = {}
		for i = 0, 3 do
			local rolledNumber = math.random(1, #weapons)
			local randomWeapon = weapons[rolledNumber]

			while true do
				if table.HasValue(assignedWeapons, randomWeapon) then
					if rolledNumber > #weapons then
						rolledNumber = 0
					end

					randomWeapon = weapons[rolledNumber + 1]
				else
					break
				end
			end

			ply:Give(randomWeapon)
			table.insert(assignedWeapons, randomWeapon)
		end
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
	ply:SetViewEntity(entity)
	ply:SetNWInt("thirdperson", 1)
end

function setupPhase()
	timer.Create("minPlayerCheckLoop", 2, 0, function()
		if  #player.GetAll() >= MINIMUM_PLAYER_AMOUNT then
			SendMessage(nil, "Get ready for Round " .. currentRound.number .. "!", nil, 0);
			timer.Simple(2, function() SendMessage( nil, "Ready!", nil, 0 ) end)
			timer.Simple(3, preparationBridge)
			timer.Remove("minPlayerCheckLoop")
		end
	end)
end

function preparationBridge()
	SendMessage( nil, "Set!", nil, 0 )
	timer.Simple( 1, roundStart )
end

util.AddNetworkString("Virus sendStartGUIRoundTimers")
local function startClientsideRoundTimers()
	net.Start("Virus sendStartGUIRoundTimers")
	net.WriteInt(config.roundTime, 3)
	net.Broadcast()
end

function roundStart()
	currentRound.playerList = player.GetAll()
	currentRound.noOfPlayers = #currentRound.playerList
	currentRound.noOfInfected = 0

	if Virus[ 1 ] == nil then MakeVirus( nil ) end
	SendMessage( nil, "Survive!", Virus[ 1 ], 1 )
	SendMessage( Virus[ 1 ], "Infect!", nil, 1 )
	timer.Simple(2, function () SendMessage(nil, "", nil, 0) end)
	timer.Create("RoundTimer", config.roundTime, 1, roundFinish)
	startClientsideRoundTimers()

	net.Start("Virus updateCurrentRound")
		net.WriteInt(currentRound.number, 2)
	net.Broadcast()

	umsg.Start("VirusRoundMusic")
	umsg.End()
--[[for k, ply in pairs(player.GetAll()) do -- gotta fix this round problems
--ply.EmitSound("gmodtower/virus/roundplay" ..math.random(1,5).. ".mp3")
--RunConsoleCommand("play gmodtower/virus/roundplay1.mp3")
ply:EmitSound("gmodtower/virus/stinger.mp3")
end]]

end

function SendMessage( playerObject, message, without, duration )
	local rp = RecipientFilter()

	if playerObject != nil && playerObject:IsPlayer() then
		rp:AddPlayer( playerObject )
	else
		 rp:AddAllPlayers()
	end

	if without != nil &&  without:IsPlayer() then
		rp:RemovePlayer(without)
	end

	umsg.Start( "impText", rp )
	umsg.String( message )
	umsg.Short( duration )
	umsg.End()
end

local function checkRoundState()
	local playerList = player.GetAll()

	if currentRound.noOfInfected == 0 && playerList != nil then
		local randomPlayer = playerList[math.random(1, #playerList)]
		MakeVirus(randomPlayer)
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

function infectedRadialHitDetection()
	for i, infected in pairs(Virus) do
		if !infected:IsValid() then return end // check incase no viruses are there at all, caused by someone ragequitting right at round start
		local Objects = ents.FindInSphere( infected:GetPos( ), 30 ) // TODO: This radius was originally 20. Reconsider it if the detection radius is too forgiving.
		for _, ply in pairs(Objects) do
			if ply:IsPlayer( ) && ply:GetNWInt( "Virus" ) != 1 then
					MakeVirus( ply )
			end
		end
	end
end

function GM:Tick()
	infectedRadialHitDetection()
end

util.AddNetworkString("Virus drawRoundEndPhase")

function roundFinish(forced) // TODO: Remove or revise forced mechanic, unless if amount of players dips below a threshold we need to force end the game at some point.
	if !forced then timer.Remove( "RoundTimer" ); end

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
util.AddNetworkString("Virus forcePlayerModel")

function MakeVirus( ply )	// set ply to nil for a random player
	local newVirus = nil

	newVirus = VirusGenerator( ply )
	if newVirus == -1 then return; end
	newVirus = Virus[ newVirus ]
	FireVirus( newVirus )
	newVirus:SetWalkSpeed( 320 )
	newVirus:SetRunSpeed( 540 )
	newVirus:StripWeapons( )

	enableThirdPerson(newVirus)

	currentRound.noOfInfected = currentRound.noOfInfected + 1
	checkRoundState()

	//newVirus:SetViewOffset(Vector(-80, 0, 100))
	net.Start("Virus forcePlayerModel")
	net.Send(newVirus)
end

function FireVirus( Target )
	if Target:IsPlayer() then
		Target:SetModel(models.virus)
		local Pos = Target:GetPos( ) + Vector( 0, -10, 50 )
		local Pos2 = Target:GetPos( ) + Vector( 0, -10, 50 )
		MakeSprite( Pos, Target, "12" )
		MakeSprite( Pos2, Target, "9" )
	end
end

function MakeSprite( Pos, Target, Rate )
	local sprite = ents.Create( "env_sprite" )
	sprite:SetPos( Pos )
	sprite:SetKeyValue( "rendercolor", "70 255 70" )
	sprite:SetKeyValue( "renderamt", "150" )
	sprite:SetKeyValue( "rendermode", "5" )
	sprite:SetKeyValue( "renderfx", "0" )
	sprite:SetKeyValue( "model", "sprites/fire1.spr" )
	sprite:SetKeyValue( "glowproxysize", "32" )
	sprite:SetKeyValue( "scale", "0.4" )
	sprite:SetKeyValue( "framerate", Rate )
	sprite:SetKeyValue( "spawnflags", 1 )
	sprite:SetParent( Target )
	sprite:Spawn( )
	table.insert(createdSprites, sprite)
end

function VirusGenerator( ply )	// do not use outside 'MakeVirus( ply )'
	if ply == nil then	// Random Player becomes infected(Use only once!)
			local players = player.GetAll( )
			local randomNumber = math.random( #players )
			table.insert( Virus, players[ randomNumber ] )
			players[ randomNumber ]:SetNWInt( "Virus", 1 )
			return #Virus
	end
	if ply:IsPlayer() && ply:GetNWInt( "Virus" ) != 1 then	// Given player becomes infected
		table.insert( Virus, ply )
		ply:SetNWInt( "Virus", 1 )
		ply:EmitSound("gmodtower/virus/stinger.mp3")
		// SendMessage( nil, "Somebody has been infected!", nil, 0 ) -- testing
		return #Virus
	end
	// Bad call! EVIL!!!
	return -1
end

function Objectives( ply )
	umsg.Start( "ShowObjectives", ply )
	umsg.End()
end
hook.Add( "ShowHelp", "ShowObjectives", Objectives )

function Survivornodamage( target, dmginfo )
	if target:GetNWInt("Virus") == 0 then
	dmginfo:ScaleDamage( 0 )
	end

end

hook.Add("EntityTakeDamage", "Survivornodamage",Survivornodamage)

hook.Add( "PlayerSpawn", "PlayerCollision", function(ply) ply:SetCollisionGroup(11) end )
