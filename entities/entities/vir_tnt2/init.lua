AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if IsMounted("hl2") then
		self:SetModel("models/weapons/w_vir_tnt.mdl")
	else
		self:SetModel("models/weapons/w_vir_tnt.mdl")
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		self:EmitSound( "weapons/tnt/timer.wav");
		phys:SetMass(3.7)
	end

	self.timeleft = CurTime() + 4.062 -- HOW LONG BEFORE EXPLOSION
	self:Think()
end

function ENT:Think()
	if self:GetNWInt("Virus") == 1 then
		self:Explosion()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explosion()
	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)
	util.Effect("Explosion", effectdata)

	util.BlastDamage(self, self.Owner, self:GetPos(), 380, 285)

	local shake = ents.Create("env_shake")
	shake:SetOwner(self.Owner)
	shake:SetPos(self:GetPos())
	shake:SetKeyValue("amplitude", "4000")	// Power of the shake
	shake:SetKeyValue("radius", "2500")		// Radius of the shake
	shake:SetKeyValue("duration", "1.5")	// Time of shake
	shake:SetKeyValue("frequency", "255")	// How har should the screenshake be
	shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
	shake:Spawn()
	shake:Activate()
	shake:Fire("StartShake", "", 0)

	self:EmitSound("weapons/tnt/explode.wav", self.Pos, 100, 100 )
	self:Remove()
end

/*---------------------------------------------------------
OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
end


/*---------------------------------------------------------
Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
end


/*---------------------------------------------------------
StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end


/*---------------------------------------------------------
EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end


/*---------------------------------------------------------
Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end
