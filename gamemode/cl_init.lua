include( "shared.lua" )
include( "cl_notice.lua" )

local InfectedClock = Material("gmod_tower/virus/hud_infected_time")
local Clock = Material("gmod_tower/virus/hud_survivor_time")
local RoundHudInfected  = Material("gmod_tower/virus/hud_infected_time")
local RoundHud = Material("gmod_tower/virus/hud_survivor_time")
local RadarHudInfected  = Material("gmod_tower/virus/hud_infected_rank")
local RadarHud = Material("gmod_tower/virus/hud_survivor_radar")
local ScoreHudInfected  = Material("gmod_tower/virus/hud_infected_score")
local ScoreHud = Material("gmod_tower/virus/hud_survivor_scor")
local RankHudIfected  = Material("gmod_tower/virus/hud_infected_rank")
local RankHud = Material("gmod_tower/virus/hud_survivor_rank")

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
	surface.CreateFont( "Small", {
		font = "Arial",
		size = 24,
		weight = 200,
		antialias = true,
		additive = false,
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


	GAMEMODE.message = "The virus didn't spread yet"
	GAMEMODE.size = 0
	GAMEMODE.timeLeft = 0
	GAMEMODE.LastState = 0
end

function GM:PlayerBindPress( ply, bind, pressed )
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

function ImportantText( text )

	if GAMEMODE.size == 0 then
		draw.DrawText(text, "Small", ScrW() / 2, ScrH() -20, Color(255,255,255,200),TEXT_ALIGN_CENTER)
	else
		draw.SimpleTextOutlined( text, "Important", ScrW() / 2, ScrH() / 2, Color(255,255,255,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,100) )
	end

end

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

	if place != 0 then ImportantText( place .. ending .. " Place" ) end
	if !transitionStarted then
		timer.Simple(3, function()
			roundEndPhase = false
			place = nil
			transitionStarted = false
		end)
	end
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint( ) -- TODO: Stop using the base class HUD paint and do something else.
	if roundEndPhase then -- TODO: we should try to handle the states another way.
		drawRoundEndPhase()
	else
		DrawClock()
		ImportantText(GAMEMODE.message)
		--self:PaintNotes
		--drawPendingHUDNotes() -- TODO: Reimplement HUD notes.
	end
end

net.Receive("Virus drawRoundEndPhase", function() roundEndPhase = true end)

function DrawClock()
	local mins = math.floor(GAMEMODE.timeLeft / 60)
	local secs = GAMEMODE.timeLeft % 60
	local separator = ":"
	if secs < 10 then separator = ":0" end

if LocalPlayer( ):GetNWInt("Virus") == 0 then
surface.SetMaterial(Clock)
surface.SetDrawColor(Color(255, 255, 255, 255))
surface.DrawTexturedRect(900, -20, 120, 120, Color(255, 255, 255, 255))
elseif LocalPlayer( ):GetNWInt("Virus") == 1 then
surface.SetMaterial(InfectedClock)
surface.SetDrawColor(Color(255, 255, 255, 255))
surface.DrawTexturedRect(900, -20, 120, 120, Color(255, 255, 255, 255))
end
	draw.DrawText(mins .. separator .. secs, "Small", ScrW() / 2, 25,
		Color(255,255,255,255),
		TEXT_ALIGN_CENTER)
end

function GM:Think()
	local state = GAMEMODE.LastState -- TODO: What is going on here? Redo the LastState variable.
	GAMEMODE.LastState = LocalPlayer( ):GetNWInt( "Virus" )
	if GAMEMODE.LastState != state then
		GAMEMODE:AddNotify( "You have been infected, You must spread the virus", NOTIFY_HINT, 7)
		GAMEMODE:AddNotify( "to everyone by touching them", NOTIFY_HINT, 7)
	end
end

function ShowObjectives(msg)
		GAMEMODE:AddNotify( "You must avoid touching the infected(they have green flames)", NOTIFY_HINT, 13 )
		GAMEMODE:AddNotify( "in any way you can, run or kill", NOTIFY_HINT, 13 )
		GAMEMODE:AddNotify( "if you get infected you must spread the virus as fast as possible", NOTIFY_HINT, 13 )
		GAMEMODE:AddNotify( "by simply touching uninfected people", NOTIFY_HINT, 13 )
end
usermessage.Hook("ShowObjectives", ShowObjectives)

function changeMessage( um )
	GAMEMODE.message = um:ReadString( )
	GAMEMODE.size = 1
end
usermessage.Hook("impText", changeMessage)

function VirusMusicTest( um )
surface.PlaySound( "gmodtower/virus/roundplay" ..math.random(1,5).. ".mp3")
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

CreateClientConVar("chasecam_bob", 1, true, false)
CreateClientConVar("chasecam_bobscale", 0.5, true, false)
CreateClientConVar("chasecam_back", 55, true, false)
CreateClientConVar("chasecam_right", -1, true, false)
CreateClientConVar("chasecam_up", 5, true, false)
CreateClientConVar("chasecam_smooth", 1, true, false)
CreateClientConVar("chasecam_smoothscale", 0.2, true, false)

local ThirdPerson = {}
-- I apologize for copying all of this code from something else.
function ThirdPerson.CalcView(player, pos, angles, fov)
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

---
--Layer: 1
-- Move this OUT of the HUDPaint hook in order to make sure your HUD is efficient
--local Texture1 = Material("gmod_tower/virus/hud_survivor_ammo")
--[[surface.SetMaterial(Texture1)
surface.SetDrawColor(Color(41, 128, 185, 255))
surface.DrawTexturedRect(ScrW()-260, ScrH()-125, 200, 120, Color(41, 128, 185, 255))]]

hook.Add( "Think", "Think_infectedglow", function()
	local infectedglow = DynamicLight( LocalPlayer():EntIndex() )
	if ( infectedglow ) and LocalPlayer( ):GetNWInt("Virus") == 1 then
		infectedglow.pos = LocalPlayer():GetShootPos()
		infectedglow.r = 70
		infectedglow.g = 255
		infectedglow.b = 70
		infectedglow.brightness = 7.9
		infectedglow.Decay = 100
		infectedglow.Size = 90
		infectedglow.DieTime = CurTime() + 1
	end
end)

local function DrawRound()
	if LocalPlayer( ):GetNWInt("Virus") == 0 then
		surface.SetMaterial(RoundHud)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(ScrW()-160, 35, 120, 120, Color(41, 128, 185, 255))
	elseif LocalPlayer( ):GetNWInt("Virus") == 1 then
		surface.SetMaterial(RoundHudInfected)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(ScrW()-160, 35, 120, 120, Color(41, 128, 185, 255)) -- I will be fixing the placements
	end

   draw.DrawText(currentRound.number, "Small", ScrW() / 2, 25,
   	   Color(255,255,255,255),
   	   TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "DrawRound", DrawRound)

net.Receive("Virus updateCurrentRound", function()
    currentRound.number = net.ReadInt(2)
end)

--[[net.Receive("Virus RoundMusic", function()
    --currentRound.number = net.ReadInt(2)
    --print("hello world")
    --surface.PlaySound( "gmodtower/virus/roundplay" ..math.random(1,5).. ".mp3" )
    sound.Play( "gmodtower/virus/roundplay" ..math.random(1,5).. ".mp3" )
end)]]
