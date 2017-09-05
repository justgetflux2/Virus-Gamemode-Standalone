
/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)
	
	self.WeaponEnt 		= data:GetEntity()
	self.Attachment 		= data:GetAttachment()
	
	self.Position 		= self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	
	local AddVel 		= self.WeaponEnt:GetOwner():GetVelocity()
	
	local emitter 		= ParticleEmitter(self.Position)

		for i = 1, 32 do
	
			local particle = emitter:Add("effects/yellowflare", self.Position)
		
				particle:SetVelocity(((self.Forward + VectorRand() * 0.4) * math.Rand(100, 200)))
				particle:SetDieTime(math.Rand(0.2, 0.3))
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(10)
				particle:SetEndSize(5)
				particle:SetRoll(255)
				particle:SetGravity(Vector(0, 0, -20))
				particle:SetCollide(false)
				particle:SetBounce(.8)
				particle:SetAirResistance(1)
				particle:SetStartLength(0.2)
				particle:SetEndLength(0)
				particle:SetVelocityScale(true)
				particle:SetCollide(true)
				particle:SetColor( 25, 205, 25, 255)
		end

		local particle = emitter:Add("effects/yellowflare", self.Position + 8 * self.Forward)

			particle:SetVelocity(self.Forward + 1.1 * AddVel)
			particle:SetAirResistance(160)

			particle:SetDieTime(0.35)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(20)
			particle:SetEndSize(10)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor( 25, 205, 25, 255)	

	emitter:Finish()
	
		local light = DynamicLight( 0 );
	if( light ) then
		
		light.Pos = self.Position;
		light.Size = 200;
		light.Decay = 400;
		light.R = 25;
		light.G = 205;
		light.B = 25;
		light.Brightness = 4;
		light.DieTime = CurTime() + .05;

	end
	
end

/*---------------------------------------------------------
	EFFECT:Think()
---------------------------------------------------------*/
function EFFECT:Think()

	return false
end

/*---------------------------------------------------------
	EFFECT:Render()
---------------------------------------------------------*/
function EFFECT:Render()
end
