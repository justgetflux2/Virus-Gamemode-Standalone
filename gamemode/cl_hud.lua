resource.AddFile("materials/hud/virus/hud_infected_radar.vmt")
resource.AddFile("materials/hud/virus/hud_infected_rank.vmt")
resource.AddFile("materials/hud/virus/hud_infected_score.vmt")
resource.AddFile("materials/hud/virus/hud_infected_time.vmt")

resource.AddFile("materials/hud/virus/hud_survivor_radar.vmt")
resource.AddFile("materials/hud/virus/hud_survivor_rank.vmt")
resource.AddFile("materials/hud/virus/hud_survivor_score.vmt")
resource.AddFile("materials/hud/virus/hud_survivor_time.vmt")

resource.AddFile("materials/hud/virus/hud_survivor_ammo.vmt")

local files = file.Find("materials/hud/virus/*", "GAME")

for k, path in pairs(files) do
	resource.AddFile("materials/hud/virus/" .. path)
end

local materials = {
	clock = {
		normal = Material("hud/virus/hud_survivor_time"),
		infected = Material("hud/virus/hud_infected_time")
	},
	round = {
		normal = Material("hud/virus/hud_survivor_round"),
		infected = Material("hud/virus/hud_infected_round")
	},
	radar = {
		normal = Material("hud/virus/hud_survivor_radar"),
		infected = Material("hud/virus/hud_infected_radar")
	},
	score = {
		normal = Material("hud/virus/hud_survivor_score"),
		infected = Material("hud/virus/hud_infected_score")
	},
	rank = {
		normal = Material("hud/virus/hud_survivor_rank"),
		infected = Material("hud/virus/hud_infected_rank")
	},
	ammo = Material("hud/virus/hud_survivor_ammo"),
	overlay = Material("hud/virus/waitingForPlayers.png")
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

local function drawRoundEndPhase()
	local place = net.ReadInt(2)
	if place == nil then return end

	local ending = "th"

	if place % 10 == 1 then ending = "st" end
	if place % 10 == 2 then ending = "nd" end
	if place % 10 == 3 then ending = "rd" end

	playGamemodeMessage(place .. ending .. " Place", 6)
end

net.Receive("Virus drawRoundEndPhase", drawRoundEndPhase)

local function drawClock()
	local mins = math.floor(VIRUS.currentRound.timeLeft / 60)
	local secs = VIRUS.currentRound.timeLeft % 60
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

local activeOverlay = false

function GM:HUDPaint()
	if activeOverlay then return end

	drawClock()
	drawRoundNumber()
	pcall(drawAmmo) -- Run through pcall() so errors aren't returned.
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
	VIRUS.currentRound.timeLeft = VIRUS.config.roundTime

	timer.Create("Virus roundTimerDecrementer",1,0,function()
		VIRUS.currentRound.timeLeft = VIRUS.currentRound.timeLeft - 1

		if VIRUS.currentRound.timeLeft == 0 then
			timer.Remove("Virus roundTimerDecrementer")
		end
	end)
end
net.Receive("Virus sendStartGUIRoundTimers", initialiseRoundTimer)

local waitingForPlayersText = nil

surface.SetFont("Important")
local minWidth = surface.GetTextSize("Waiting for players...")

local drawWaitingForPlayers_Path = function()
	if waitingForPlayersText == nil then
		timer.Remove("Virus drawWaitingForPlayers path")
		return
	end
	waitingForPlayersText:MoveTo(ScrW() / 2 + 30 - minWidth / 2,ScrH() / 2,1,0,-0.3)
	waitingForPlayersText:MoveTo(ScrW() / 2 - minWidth / 2,ScrH() / 2 + 30,1,1,-0.3)
	waitingForPlayersText:MoveTo(ScrW() / 2 - 30 - minWidth / 2,ScrH() / 2,1,2,-0.3)
	waitingForPlayersText:MoveTo(ScrW() / 2 - minWidth / 2,ScrH() / 2 - 30,1,3,-0.3)
end

local function drawWaitingForPlayers()
	waitingForPlayersText = vgui.Create("DLabel")
	waitingForPlayersText:SetPos(ScrW() / 2 + 30 - minWidth / 2, ScrH() / 2)
	waitingForPlayersText:SetFont("Important")
	waitingForPlayersText:SetText("Waiting for players...")
	waitingForPlayersText:SetTextColor(Color(0, 30, 120))
	waitingForPlayersText:SizeToContents()
	drawWaitingForPlayers_Path()
	timer.Create("Virus drawWaitingForPlayers path",4,0,drawWaitingForPlayers_Path)
end

local function waitingForPlayers()
	if activeOverlay then return end
	activeOverlay = true
	Music.playWaitingForPlayers()
	drawWaitingForPlayers()
end
net.Receive("Virus waitingForPlayers", waitingForPlayers)

local saturationData = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 0.1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

function GM:RenderScreenspaceEffects()
	if activeOverlay then
		DrawColorModify(saturationData)
	end
end

net.Receive("Virus warmupPeriod",function()
	if waitingForPlayersText == nil then return end
	activeOverlay = false
	waitingForPlayersText:Remove()
	waitingForPlayersText = nil
	Music.playWarmupPeriod()
end)

net.Receive("Virus onInfected",function()
	local nick = net.ReadString(32) or "Someone"
	playGamemodeMessage(nick .. " has been infected!", 2)
end)
