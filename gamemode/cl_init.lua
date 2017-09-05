include( "shared.lua" )
include( "cl_notice.lua" )

local materials = { // TODO Consider adding prefixes to the materials here. It's unlikely there will be conflicts however.
	clock = {
		normal = Material("gmod_tower/virus/hud_survivor_time"),
		infected = Material("gmod_tower/virus/hud_infected_time")
	},
	round = {
		normal = Material("gmod_tower/virus/hud_survivor_round"),
		infected = Material("gmod_tower/virus/hud_infected_round")
	},
	radar = {
		normal = Material("gmod_tower/virus/hud_survivor_radar"),
		infected = Material("gmod_tower/virus/hud_infected_radar")
	},
	score = {
		normal = Material("gmod_tower/virus/hud_survivor_score"),
		infected = Material("gmod_tower/virus/hud_infected_score")
	},
	rank = {
		normal = Material("gmod_tower/virus/hud_survivor_rank"),
		infected = Material("gmod_tower/virus/hud_infected_rank")
	},
	ammo = Material("gmod_tower/virus/hud_survivor_ammo")
}

local config = {
	roundTime = 110 -- 180 by default
}

local currentRound = {
	   number = 1,
	   playerList = {},
	   noOfPlayers = 0,
	   noOfInfected = 0
}

function GM:Initialize()
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

	GAMEMODE.message = "Waiting for at least 4 players..."
	GAMEMODE.timeLeft = 0
end

function GM:PlayerBindPress(ply, bind, pressed)
	if not pressed then return false end

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

local pendingMessages = {}
local currentlyPlayingMessage = false

local function playGamemodeMessage(msg)
	if currentlyPlayingMessage then
		table.insert(pendingMessages, msg)
		return
	end

	currentlyPlayingMessage = true

	if table.HasValue(pendingMessages, msg) then
		table.RemoveByValue(pendingMessages, msg)
	end

	surface.SetFont("Important")
	local maxWidth = surface.GetTextSize(msg)

	local msgTextBackground = vgui.Create("DLabel")
	msgTextBackground:SetPos(ScrW() + 2, ScrH() / 2 - 20 + 2)
	msgTextBackground:SetText(msg)
	msgTextBackground:SetFont("Important")
	msgTextBackground:SetTextColor(Color(0,30,120))
	msgTextBackground:SetSize(800,400)
	msgTextBackground:SetAlpha(0)
	msgTextBackground:SizeToContents()

	msgTextBackground:MoveTo(ScrW() / 2 - maxWidth / 2 + 2,ScrH() / 2 - 20 + 2,1,0,1)
	msgTextBackground:AlphaTo(255,0.5)

	msgTextBackground:MoveTo(2,ScrH() / 2 - 20 + 2,1,2,1)
	msgTextBackground:AlphaTo(0,0.5,2)

	local msgText = vgui.Create("DLabel")
	msgText:SetPos(ScrW(), ScrH() / 2 - 20)
	msgText:SetText(msg)
	msgText:SetFont("Important")
	msgText:SetTextColor(Color(255,255,255))
	msgText:SetSize(800,400)
	msgText:SetAlpha(0)
	msgText:SizeToContents()

	msgText:MoveTo(ScrW() / 2 - maxWidth / 2,ScrH() / 2 - 20,1,0,1)
	msgText:AlphaTo(255,0.5)

	msgText:MoveTo(0,ScrH() / 2 - 20,1,2,1)
	msgText:AlphaTo(0,0.5,2)

	timer.Simple(3, function() // Messages take 3 seconds.
		msgText:Remove()
		msgTextBackground:Remove()

		currentlyPlayingMessage = false

		if pendingMessages[1] != nil then
			playGamemodeMessage(pendingMessages[1])
		end
	end)
end

net.Receive("Virus sendGamemodeMessage", function()
	local msg = net.ReadString(32)
	playGamemodeMessage(msg)
end)

local roundEndPhase = false
local transitionStarted = false
local place

local function delayedGetPlace() // Must be delayed because setting NW Ints takes a frame to catch up on clientside to obtain.
	timer.Simple(0.1, function()
		place = LocalPlayer():GetNWInt("place")
	end)
	return 0
end

local function drawRoundEndPhase()
	place = place or delayedGetPlace()

	local ending = "th"
	if place % 10 == 1 then ending = "st";end
	if place % 10 == 2 then ending = "nd";end
	if place % 10 == 3 then ending = "rd";end

	if place != 0 then
		playGamemodeMessage(place .. ending .. " Place")
	end

	if !transitionStarted then
		timer.Simple(3, function()
			roundEndPhase = false
			place = nil
			transitionStarted = false
		end)
	end
end

local function drawClock()
	local mins = math.floor(GAMEMODE.timeLeft / 60)
	local secs = GAMEMODE.timeLeft % 60
	local separator = ":"
	if secs < 10 then separator = ":0" end

	local xOffset = ScrW() / 2 - 96

	surface.SetDrawColor(Color(255, 255, 255, 255))

	if LocalPlayer():GetNWInt("Virus") == 0 then
		surface.SetMaterial(materials.clock.normal)
		surface.DrawTexturedRect(xOffset, 0, 96, 96, Color(255, 255, 255, 255))
	elseif LocalPlayer():GetNWInt("Virus") == 1 then
		surface.SetMaterial(materials.clock.infected)
		surface.DrawTexturedRect(xOffset, 0, 96, 96, Color(255, 255, 255, 255))
	end

	draw.DrawText(mins .. separator .. secs, "VirusHUD", xOffset + 48, 34, Color(255,255,255,255),
		TEXT_ALIGN_CENTER)
end

local function drawRoundNumber()
	local xOffset = ScrW() / 2

	surface.SetDrawColor(Color(255, 255, 255, 255))

	if LocalPlayer():GetNWInt("Virus") == 0 then
		surface.SetMaterial(materials.round.normal)
		surface.DrawTexturedRect(xOffset, 0, 96, 96)
	elseif LocalPlayer():GetNWInt("Virus") == 1 then
		surface.SetMaterial(materials.round.infected)
		surface.DrawTexturedRect(xOffset, 0, 96, 96)
	end

	draw.DrawText(currentRound.number, "VirusHUD", xOffset + 48, 34, Color(255, 255, 255, 255),
		TEXT_ALIGN_CENTER)
end

local function drawAmmo()
	if LocalPlayer():GetNWInt("Virus") == 1 then return end
	local xOffset = ScrW() - 240
	local yOffset = ScrH() - 160

	surface.SetMaterial(materials.ammo)
	surface.SetDrawColor(Color(41, 128, 185, 255))
	surface.DrawTexturedRect(xOffset, ScrH() - 160, 200, 120, Color(41, 128, 185, 255))

	local activeWeapon = LocalPlayer():GetActiveWeapon()
	if activeWeapon == nil then return end
	if activeWeapon:GetPrimaryAmmoType() == nil then return end

	local ammoCapacity = LocalPlayer():GetAmmoCount(activeWeapon:GetPrimaryAmmoType())
	local ammoCount = activeWeapon:Clip1() .. " / " .. ammoCapacity

	draw.DrawText(ammoCount, "VirusHUD", xOffset + 100, yOffset + 40, Color(255,255,255,255), TEXT_ALIGN_CENTER)
end

function GM:HUDPaint()
	//self.BaseClass:HUDPaint() // TODO: Stop using the base class HUD paint and do something else.
	if roundEndPhase then // TODO: we should try to handle the states another way.
		drawRoundEndPhase()
	else
		drawClock()
		drawRoundNumber()
		drawAmmo()
		//self:PaintNotes
		//drawPendingHUDNotes() // TODO: Reimplement HUD notes.
	end
end

net.Receive("Virus drawRoundEndPhase", function() roundEndPhase = true end)

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudDamageIndicator = true,
	CHudSecondaryAmmo = true
}

function GM:HUDShouldDraw(name) // Stops the default HUD from drawing
	if (hide[name]) then
		return false
	end
	return true
end

function VirusMusicTest( um )
	surface.PlaySound("gmodtower/virus/roundplay" .. math.random(1,5) .. ".mp3")
	surface.PlaySound("gmodtower/virus/stinger.mp3")
end
usermessage.Hook("VirusRoundMusic", VirusMusicTest)

function SurvivorsWin( um )
	surface.PlaySound( "gmodtower/virus/roundend_survivors.mp3")
	surface.PlaySound("gmodtower/virus/announce_survivorswin.wav")
	surface.PlaySound("gmodtower/virus/ui/menu.wav")
end
usermessage.Hook("SurvivorsWin", SurvivorsWin)

function VirusWaitForInfected( um )
	surface.PlaySound("gmodtower/virus/waiting_forinfection"..math.random(1,8)..".mp3")
end
usermessage.Hook("VirusWaitForInfected", VirusWaitForInfected)

local function initialiseRoundTimer()
	GAMEMODE.timeLeft = config.roundTime

	timer.Create("Virus roundTimerDecrementer",1,0,function()
		GAMEMODE.timeLeft = GAMEMODE.timeLeft - 1

		if GAMEMODE.timeLeft == 0 then
			surface.PlaySound("gmodtower/virus/announce_survivorswin.wav")
			timer.Remove("Virus roundTimerDecrementer")
		end
	end)
end
net.Receive("Virus sendStartGUIRoundTimers", initialiseRoundTimer)

hook.Add("Think", "Virus infectedGlow", function() // TODO Move out of think hook, change how this works. It's likely only one variable has to be updated per frame.
	local infectedglow = DynamicLight(LocalPlayer():EntIndex())

	if infectedglow and LocalPlayer():GetNWInt("Virus") == 1 then
		infectedglow.pos = LocalPlayer():GetShootPos()
		infectedglow.r = 70
		infectedglow.g = 255
		infectedglow.b = 70
		infectedglow.brightness = 40
		infectedglow.Decay = 100
		infectedglow.Size = 90
		infectedglow.DieTime = CurTime() + 1
	end
end)

net.Receive("Virus updateCurrentRound", function()
	currentRound.number = net.ReadInt(10)
end)

CreateClientConVar("chasecam_bob", 1, false, false)
CreateClientConVar("chasecam_bobscale", 0.5, false, false)
CreateClientConVar("chasecam_back", 55, false, false)
CreateClientConVar("chasecam_right", -1, false, false)
CreateClientConVar("chasecam_up", 5, false, false)
CreateClientConVar("chasecam_smooth", 1, false, false)
CreateClientConVar("chasecam_smoothscale", 0.2, false, false)

local ThirdPerson = {}

-- I apologize for copying all of this code from something else.
function ThirdPerson.CalcView(player, pos, angles, fov) // TODO Preen
	local smooth = GetConVarNumber("chasecam_smooth")
	local smoothscale = GetConVarNumber("chasecam_smoothscale")
	if player:GetNWInt("thirdperson") == 1 then
		angles = player:GetAimVector():Angle()

		local targetpos = Vector(0, 0, 60)
		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = 50
			else
				targetpos.z = 40
			end
		end

		player:SetAngles(angles)
		local targetfov = fov
		if player:GetVelocity():DotProduct(player:GetForward()) > 10 then
			if player:KeyDown(IN_SPEED) then
				targetpos = targetpos + player:GetForward() * -10
				if GetConVarNumber("chasecam_bob") != 0 and player:OnGround() then
					angles.pitch = angles.pitch + GetConVarNumber("chasecam_bobscale") * math.sin(CurTime() * 10)
					angles.roll = angles.roll + GetConVarNumber("chasecam_bobscale") * math.cos(CurTime() * 10)
					targetfov = targetfov + 3
				end
			else
				targetpos = targetpos + player:GetForward() * -5
			end
		end

		// tween to the target position
		pos = player:GetVar("thirdperson_pos") or targetpos
		if smooth != 0 then
			pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale)
			pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale)
			pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
		else
			pos = targetpos
		end
		player:SetVar("thirdperson_pos", pos)

		// offset it by the stored amounts, but trace so it stays outside walls
		// we don't tween this so the camera feels like its tightly following the mouse
		local offset = Vector(5, 5, 5)
		if player:GetVar("thirdperson_zoom") != 1 then
			offset.x = GetConVarNumber("chasecam_back")
			offset.y = GetConVarNumber("chasecam_right")
			offset.z = GetConVarNumber("chasecam_up")
		end
		local t = {}
		t.start = player:GetPos() + pos
		t.endpos = t.start + angles:Forward() * -offset.x
		t.endpos = t.endpos + angles:Right() * offset.y
		t.endpos = t.endpos + angles:Up() * offset.z
		t.filter = player

			local tr = util.TraceLine(t)
			pos = tr.HitPos
			if tr.Fraction < 1.0 then
				pos = pos + tr.HitNormal * 5
			end

		player:SetVar("thirdperson_viewpos", pos)

		// tween the fov
		fov = player:GetVar("thirdperson_fov") or targetfov
		if smooth != 0 then
			fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
		else
			fov = targetfov
		end
		player:SetVar("thirdperson_fov", fov)

		return GAMEMODE:CalcView(player, pos, angles, fov)
	end
end
hook.Add("CalcView", "ThirdPerson.CalcView", ThirdPerson.CalcView)
