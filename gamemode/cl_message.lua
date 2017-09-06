local pendingMessages = {}
local currentlyPlayingMessage = false

function playGamemodeMessage(queueMessage)
	local msg = net.ReadString(32) or queueMessage

	if currentlyPlayingMessage then
		table.insert(pendingMessages, msg)
		return
	end

	currentlyPlayingMessage = true

	if table.HasValue(pendingMessages, msg) then
		table.RemoveByValue(pendingMessages, msg)
	end

	surface.SetFont("Important")
	local textWidth = surface.GetTextSize(msg)

	local msgTextBackground = vgui.Create("DLabel")
	msgTextBackground:SetPos(ScrW() + 2, ScrH() / 2 + 2 - 20)
	msgTextBackground:SetSize(ScrW(), ScrH())
	msgTextBackground:SetText(msg)
	msgTextBackground:SetTextColor(Color(0,40,130))
	msgTextBackground:SetFont("Important")
	msgTextBackground:SetAlpha(0)
	msgTextBackground:SizeToContents()

	msgTextBackground:MoveTo(ScrW() / 2 + 2 - textWidth / 2,ScrH() / 2 + 2 - 20,1,0)
	msgTextBackground:AlphaTo(255,0.5)

	msgTextBackground:MoveTo(2,ScrH() / 2 + 2 - 20,1,2)
	msgTextBackground:AlphaTo(0,0.5,2)

	local msgText = vgui.Create("DLabel")
	msgText:SetPos(ScrW(), ScrH() / 2 - 20)
	msgText:SetSize(ScrW(), ScrH())
	msgText:SetText(msg)
	msgText:SetTextColor(Color(255,255,255))
	msgText:SetFont("Important")
	msgText:SetAlpha(0)
	msgText:SizeToContents()

	msgText:MoveTo(ScrW() / 2 - textWidth / 2,ScrH() / 2 - 20,1,0)
	msgText:AlphaTo(255,0.5)

	msgText:MoveTo(0,ScrH() / 2 - 20,1,2)
	msgText:AlphaTo(0,0.5,2)

	timer.Simple(3, function()
		msgText:Remove()
		msgTextBackground:Remove()

		currentlyPlayingMessage = false

		if pendingMessages[1] != nil then
			playGamemodeMessage(pendingMessages[1])
		end
	end)
end

net.Receive("Virus sendGamemodeMessage", playGamemodeMessage)
