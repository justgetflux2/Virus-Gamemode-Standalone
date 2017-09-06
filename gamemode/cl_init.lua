include("shared.lua")

include("cl_music.lua")
include("cl_message.lua")
include("cl_thirdperson.lua")
include("cl_hud.lua")

VIRUS = {}

VIRUS.config = {
	roundTime = 110 -- 180 by default
}

VIRUS.currentRound = {
	   number = 1,
	   playerList = {},
	   noOfPlayers = 0,
	   noOfInfected = 0
}

surface.CreateFont( "VirusHUD", {
	font = "Impact",
	size = 36,
	weight = 200,
	antialias = true,
	additive = false,
	outline = true
})

surface.CreateFont( "Important", {
	font = "Arial",
	size = 72,
	weight = 200,
	antialias = true,
	additive = false,
})

surface.CreateFont( "fuckhd", {
	font = "reactor-sans",
	size = 28,
	weight = 200,
	antialias = true,
	additive = false,
})

function GM:Initialize()
	GAMEMODE.message = "Waiting for at least 4 players..." -- TODO Change how this works. Public privacy is not needed.
	GAMEMODE.timeLeft = 0
end

function GM:PlayerBindPress(ply, bind, pressed)
	if !pressed then return false end

	if (bind == "+zoom") then
		return true
	end

	if (bind == "+speed") then
		return true
	end

	if (bind == "+jump") then
		return true
	end

	if (bind == "+duck") then
		return true
	end

	if (bind == "+menu") then
		RunConsoleCommand("lastinv")
		return true
	end
end

function GM:GetFallDamage( ply, speed )
	return false
end

function GM:HUDWeaponPickedUp( Weapon )
	return false
end

function GM:PlayerCanPickupItem( ply, item )
	return false
end

hook.Add("Think", "Virus infectedGlow", function() -- TODO We need to make this visible to other players. Sprite system?
	local infectedglow = DynamicLight(LocalPlayer():EntIndex())

	if infectedglow and LocalPlayer():GetNWInt("Virus") == 1 then
		infectedglow.pos = LocalPlayer():GetShootPos()
		infectedglow.r = 70
		infectedglow.g = 255
		infectedglow.b = 70
		infectedglow.brightness = 8
		infectedglow.Decay = 100
		infectedglow.Size = 90
		infectedglow.DieTime = CurTime() + 1
	end
end)

net.Receive("Virus updateCurrentRound", function()
	VIRUS.currentRound.number = net.ReadInt(10)
end)
