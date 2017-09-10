VIRUS = {} -- Gamemode class, NOT the same as the infected players list. TODO Probably change the name of the infected player list.

AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("cl_music.lua")
AddCSLuaFile("cl_message.lua")
AddCSLuaFile("cl_thirdperson.lua")
AddCSLuaFile("cl_hud.lua")

include("shared.lua")

include("sv_message.lua")
include("sv_thirdperson.lua")
include("sv_round.lua")

util.AddNetworkString("Virus updateCurrentRound")

util.AddNetworkString("Virus warmupPeriod")
util.AddNetworkString("Virus roundMusic")
util.AddNetworkString("Virus survivorsWin")

-- Sending file resources --

local files, directories = file.Find("sound/virus/*", "GAME")

for k, path in pairs(files) do
	resource.AddFile("sound/virus/" .. path)
end

-- Sending file resources --

--[[local model = LocalPlayer():GetInfo( "cl_playermodel" ) -- TODO add custom models
local modelname = player_manager.TranslatePlayerModel( model )]]

Virus = {} -- Infected players list
ModName = "Virus"

VIRUS.config = {
	roundTime = 120
}

local models = {
	normal = Model("models/player/Group03/male_04.mdl"), -- TODO: This needs to be multiple player models
	virus = Model("models/player/virusi.mdl")
}

VIRUS.currentRound = {
	number = 1,
	playerList = {},
	noOfPlayers = 0,
	noOfInfected = 0
}

VIRUS.createdSprites = {}

function GM:PlayerInitialSpawn(ply)
	ply:SetCollisionGroup(11) -- Disables collision with other players.
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
	return true -- TODO Change back to false when not debugging.
end

function GM:PlayerDeath(victim, Inflictor, killer)
	victim.fireSprite.child:Remove()
	victim.fireSprite:Remove()
	victim:EmitSound("ambient/fire/ignite.waw")

	if victim != killer then -- TODO If we disable suicide then get rid of this if statement
		killer:SetNWInt("Virus killCount", killer:GetNWInt("Virus killCount") + 1)
	end
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

	table.insert(VIRUS.createdSprites, sprite)
	return sprite
end

local function registerInfected(ply) -- Internal function
	table.insert(Virus, ply)
	ply:SetNWInt("Virus", 1)
end

local function attachFireSprite(target)
	local pos = target:GetPos() + Vector( 0, -10, 50 )
	local pos2 = target:GetPos() + Vector( 0, -10, 65 )

	local sprite1 = makeSprite(pos, target, "12")
	local sprite2 = makeSprite(pos2, target, "9")

	sprite1.child = sprite2
	target.fireSprite = sprite1
end

function VIRUS.configurePlayerAsVirus(ply)
	ply:SetModel(models.virus)

	ply:SetWalkSpeed(308)
	ply:SetRunSpeed(530)

	ply:StripWeapons()
	ply:StripAmmo()

	attachFireSprite(ply)
end

function VIRUS.configurePlayerAsHuman(ply)
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
		VIRUS.configurePlayerAsVirus(ply)
	else
		VIRUS.configurePlayerAsHuman(ply)

		ply:StripWeapons()
		ply:StripAmmo()

		ply:GiveAmmo(42, "Pistol", true)
		ply:GiveAmmo(30, "SMG1", true)
		ply:GiveAmmo(64, "Buckshot", true)

		for k, wep in pairs(pistols[math.random(1,2)]) do
			ply:Give(wep)
		end

		local options = table.Copy(otherWeaponsSet1)

		for i = 1, 3 do
			local rnd = math.random(#options)
			ply:Give(options[rnd])
			table.remove(options, rnd)
		end

		options = nil -- ready for garbage collection
	end

	return true
end

util.AddNetworkString("Virus onInfected")

local function infectPlayer(ply) -- set ply to nil for a random player
	registerInfected(ply)

	enableThirdPerson(ply)
	VIRUS.configurePlayerAsVirus(ply)

	VIRUS.currentRound.noOfInfected = VIRUS.currentRound.noOfInfected + 1

	net.Start("Virus onInfected")
	net.WriteString(ply:Nick(), 32)
	net.Broadcast()

	VIRUS.checkRoundState()
end

local gracedPlayer

function VIRUS.generateFirstInfected()
	local players = player.GetAll()
	local randomNumber = math.random(#players)

	if players[randomNumber] == gracedPlayer then
		if players[randomNumber + 1] != nil then
			randomNumber = randomNumber + 1
		elseif players[randomNumber - 1] != nil then
			randomNumber = randomNumber - 1
		else
			error("First infected couldn't be generated due to a mysterious lack of players.")
			VIRUS.roundStart()
		end
	end

	gracedPlayer = players[randomNumber]
	infectPlayer(players[randomNumber])
end

function GM:PlayerDisconnected(ply)
	if table.HasValue(VIRUS.currentRound.playerList, ply) then
		VIRUS.currentRound.noOfPlayers = VIRUS.currentRound.noOfPlayers - 1

		if ply:GetNWInt("Virus") == 1 then
			VIRUS.currentRound.noOfInfected = VIRUS.currentRound.noOfInfected - 1
		end

		VIRUS.checkRoundState()
	end
end

util.AddNetworkString("Virus hitDetection")

net.Receive("Virus hitDetection", function(len, ply)
	local target = net.ReadEntity()
	if target:GetNWInt("Virus") == 1 then return end
	if ply:Alive() == false then return end
	infectPlayer(target)
end)

util.AddNetworkString("Virus drawRoundEndPhase")

local function survivorNoDamage(target, dmginfo)
	if target:GetNWInt("Virus") == 0 && target:IsPlayer() then
		dmginfo:ScaleDamage(0)
	end
end

hook.Add("EntityTakeDamage", "survivorNoDamage", survivorNoDamage)

concommand.Add("endround", VIRUS.roundFinish)
concommand.Add("infect", function(ply, cmd, args, argStr) infectPlayer(ply) end)
