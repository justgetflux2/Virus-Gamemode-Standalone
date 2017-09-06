resource.AddFile("materials/hud/hud_infected_radar.vmt")
resource.AddFile("materials/hud/hud_infected_rank.vmt")
resource.AddFile("materials/hud/hud_infected_score.vmt")
resource.AddFile("materials/hud/hud_infected_time.vmt")

resource.AddFile("materials/hud/hud_survivor_radar.vmt")
resource.AddFile("materials/hud/hud_survivor_rank.vmt")
resource.AddFile("materials/hud/hud_survivor_score.vmt")
resource.AddFile("materials/hud/hud_survivor_time.vmt")

resource.AddFile("materials/hud/hud_survivor_ammo.vmt")

local materials = { -- TODO Consider adding prefixes to the materials here. It's unlikely there will be conflicts however.
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

local place

local function delayedGetPlace() -- Must be delayed because setting NW Ints takes a frame to catch up on clientside to obtain.
	timer.Simple(0.1, function()
		place = LocalPlayer():GetNWInt("place")
	end)
	return 0
end

local roundEndPhase = false
local transitionStarted = false

local function drawRoundEndPhase()
	place = place or delayedGetPlace()

	local ending = "th"
	if place % 10 == 1 then ending = "st" end
	if place % 10 == 2 then ending = "nd" end
	if place % 10 == 3 then ending = "rd" end

	if place != 0 then return end

	if !transitionStarted then
		timer.Simple(3, function()
			roundEndPhase = false
			transitionStarted = false
			place = nil
		end)

		transitionStarted = true
		playGamemodeMessage(place .. ending .. " Place")
	end
end

net.Receive("Virus drawRoundEndPhase", function()
	roundEndPhase = true
end)

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

	draw.DrawText(VIRUS.currentRound.number, "VirusHUD", xOffset + 48, 34, Color(255, 255, 255, 255),
		TEXT_ALIGN_CENTER)
end

local function drawAmmo()
	if LocalPlayer():GetNWInt("Virus") == 1 then return end

	local xOffset = ScrW() - 240
	local yOffset = ScrH() - 160

	surface.SetMaterial(materials.ammo)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(xOffset, ScrH() - 160, 200, 120)

	local activeWeapon = LocalPlayer():GetActiveWeapon()
	if activeWeapon == nil or activeWeapon:GetPrimaryAmmoType() == nil then return end

	local ammoCapacity = LocalPlayer():GetAmmoCount(activeWeapon:GetPrimaryAmmoType())
	local ammoCount = activeWeapon:Clip1() .. " / " .. ammoCapacity

	draw.DrawText(ammoCount, "VirusHUD", xOffset + 100, yOffset + 40, Color(255,255,255,255), TEXT_ALIGN_CENTER)
end

function GM:HUDPaint()
	if roundEndPhase then
		drawRoundEndPhase()
	else
		drawClock()
		drawRoundNumber()
		pcall(drawAmmo) -- Run through pcall() so errors aren't returned.
		--drawImportantMessage() TODO Reimplement
	end
end

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudDamageIndicator = true,
	CHudSecondaryAmmo = true
}

function GM:HUDShouldDraw(name)
	if (hide[name]) then
		return false
	end
	return true
end

local function initialiseRoundTimer()
	GAMEMODE.timeLeft = VIRUS.config.roundTime -- TODO Probably get rid of the use of global GAMEMODE usage, it doesn't need public privacy.

	timer.Create("Virus roundTimerDecrementer",1,0,function()
		GAMEMODE.timeLeft = GAMEMODE.timeLeft - 1

		if GAMEMODE.timeLeft == 0 then
			surface.PlaySound("gmodtower/virus/announce_survivorswin.wav")
			timer.Remove("Virus roundTimerDecrementer")
		end
	end)
end
net.Receive("Virus sendStartGUIRoundTimers", initialiseRoundTimer)
