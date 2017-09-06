local pendingMessages = {}
local currentlyPlayingMessage = false

function playGamemodeMessage(msg)
	if currentlyPlayingMessage then
		table.insert(pendingMessages, msg)
		return
	end
	print("Something's happening")
	currentlyPlayingMessage = true

	if table.HasValue(pendingMessages, msg) then
		table.RemoveByValue(pendingMessages, msg)
	end

	local msgText = vgui.Create("DLabel")
	msgText:SetPos(ScrW(), ScrH() / 2)
	msgText:SetText(msg)
	msgText:SizeToContents()
	msgText:SetFont("Important")
	msgText:SetAlpha(0)

	msgText:MoveTo(ScrW() / 2,ScrH() / 2,1,0,1)
	msgText:AlphaTo(255,0.5)

	msgText:MoveTo(0,ScrH() / 2,1,3,1)
	msgText:AlphaTo(0,0.5,3)

	timer.Simple(6, function()
		msgText:Remove()
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
