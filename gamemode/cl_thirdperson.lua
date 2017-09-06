CreateClientConVar("chasecam_bob", 1, false, false)
CreateClientConVar("chasecam_bobscale", 0.5, false, false)
CreateClientConVar("chasecam_back", 55, false, false)
CreateClientConVar("chasecam_right", -1, false, false)
CreateClientConVar("chasecam_up", 5, false, false)
CreateClientConVar("chasecam_smooth", 1, false, false)
CreateClientConVar("chasecam_smoothscale", 0.2, false, false)

local function calculateThirdPersonView(player, pos, angles, fov) -- TODO Preen
	local smooth = GetConVarNumber("chasecam_smooth") -- TODO Need to convert this to ConVar objects. This is deprecated.
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
		if player:GetVelocity():Dot(player:GetForward()) > 10 then
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

		-- Tweens to the target position.
		pos = player:GetVar("thirdperson_pos") or targetpos
		if smooth != 0 then
			pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale)
			pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale)
			pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
		else
			pos = targetpos
		end
		player:SetVar("thirdperson_pos", pos)

		-- Offset it by the stored amounts, but trace so it stays outside walls
		-- We don't tween this so the camera feels like its tightly following the mouse
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

		-- Tween the fov
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

hook.Add("CalcView", "calculateThirdPersonView", calculateThirdPersonView)
