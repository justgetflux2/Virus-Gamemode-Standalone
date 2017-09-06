local dummyModel = Model("models/error.mdl")

function disableThirdPerson(ply)
	if ply:GetNWInt("thirdperson") == 0 then
		return
	end

	local entity = ply:GetViewEntity()
	ply:SetNWInt("thirdperson", 0)
	ply:SetViewEntity(ply)
	entity:Remove()
end

function enableThirdPerson(ply)
	if ply:GetNWInt("thirdperson") == 1 then
		return
	end

	local entity = ents.Create("prop_dynamic")
	entity:SetModel(dummyModel)
	entity:Spawn()
	entity:SetAngles(ply:GetAngles())
	entity:SetMoveType(MOVETYPE_NONE)
	entity:SetParent(ply)
	entity:SetPos(ply:GetPos() + Vector(0, 0, 60))
	entity:SetRenderMode(RENDERMODE_NONE)
	entity:SetSolid(SOLID_NONE)
	entity:DrawShadow(false)

	ply:SetViewEntity(entity)
	ply:SetNWInt("thirdperson", 1)
end
