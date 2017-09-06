util.AddNetworkString("Virus sendGamemodeMessage")

function sendGamemodeMessage(text, duration, survivorExclusive, infectedExclusive)
	if text == nil then return end
	duration = duration or 1
	survivorExclusive = survivorExclusive or false
	infectedExclusive = infectedExclusive or false

	if survivorExclusive then
		for k, ply in pairs(player.GetAll()) do
			if ply:GetNWInt("Virus") == 0 then
				net.Start("Virus sendGamemodeMessage")
				net.WriteString(text, 32)
				net.WriteInt(duration, 10)
				net.Send(ply)
			end
		end
	elseif infectedExclusive then
		for k, ply in pairs(player.GetAll()) do
			if ply:GetNWInt("Virus") == 1 then
				net.Start("Virus sendGamemodeMessage")
				net.WriteString(text, 32)
				net.WriteInt(duration, 10)
				net.Send(ply)
			end
		end
	else
		net.Start("Virus sendGamemodeMessage")
		net.WriteString(text, 32)
		net.WriteInt(duration, 10)
		net.Broadcast()
	end
end
