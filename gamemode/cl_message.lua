local pendingMessages = {}
local currentlyPlayingMessage = false

function playGamemodeMessage(queueMessage, duration)
	local data = {
		msg = queueMessage,
		aliveTime = duration or 1
	}

	print("FOR " .. queueMessage)
	print(data.msg)
	print(data.aliveTime)

	if currentlyPlayingMessage then
		table.insert(pendingMessages, data)
		return
	end

	currentlyPlayingMessage = true

	surface.SetFont("Important")
	local textWidth = surface.GetTextSize(data.msg)

	local msgTextBackground = vgui.Create("DLabel")
	msgTextBackground:SetPos(ScrW() + 2, ScrH() / 2 + 2 - 20)
	msgTextBackground:SetSize(ScrW(), ScrH())
	msgTextBackground:SetText(data.msg)
	msgTextBackground:SetTextColor(Color(0,40,130))
	msgTextBackground:SetFont("Important")
	msgTextBackground:SetAlpha(0)
	msgTextBackground:SizeToContents()

	msgTextBackground:MoveTo(ScrW() / 2 + 2 - textWidth / 2,ScrH() / 2 + 2 - 20,data.aliveTime / 3,0)
	msgTextBackground:AlphaTo(255,data.aliveTime / 3)

	msgTextBackground:MoveTo(2,ScrH() / 2 + 2 - 20,data.aliveTime / 3,data.aliveTime / 3 * 2)
	msgTextBackground:AlphaTo(0,data.aliveTime / 3,data.aliveTime / 3 * 2)

	local msgText = vgui.Create("DLabel")
	msgText:SetPos(ScrW(), ScrH() / 2 - 20)
	msgText:SetSize(ScrW(), ScrH())
	msgText:SetText(data.msg)
	msgText:SetTextColor(Color(255,255,255))
	msgText:SetFont("Important")
	msgText:SetAlpha(0)
	msgText:SizeToContents()

	msgText:MoveTo(ScrW() / 2 - textWidth / 2,ScrH() / 2 - 20,data.aliveTime / 3,0)
	msgText:AlphaTo(255,data.aliveTime / 3)

	msgText:MoveTo(0,ScrH() / 2 - 20,data.aliveTime / 3,data.aliveTime / 3 * 2)
	msgText:AlphaTo(0,data.aliveTime / 3,data.aliveTime / 3 * 2)

	timer.Simple(data.aliveTime, function()
		msgText:Remove()
		msgTextBackground:Remove()

		currentlyPlayingMessage = false

		if pendingMessages[1] != nil then
			playGamemodeMessage(pendingMessages[1].msg, pendingMessages[1].aliveTime)
			table.remove(pendingMessages, 1)
		end
	end)
end

net.Receive("Virus sendGamemodeMessage", function()
	local msg = net.ReadString(32)
	local aliveTime = net.ReadInt(10)

	playGamemodeMessage(msg, aliveTime)
end)
