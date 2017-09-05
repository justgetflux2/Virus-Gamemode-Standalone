
EFFECT.Mat = Material( "effects/blueblacklargebeam" )


function EFFECT:Init( data )

	self.texcoord = math.Rand( 0, 20 )/3
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	

	self.Entity:SetCollisionBounds( self.StartPos -  self.EndPos, Vector( 110, 110, 110 ) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos, Vector()*8 )
	
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	
	self.Alpha = 255
	self.FlashA = 255
	
	self.WeaponEnt 		= data:GetEntity()
	self.Attachment 		= data:GetAttachment()
	
	self.Position 		= self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	

	
	local emitter 		= ParticleEmitter(self.Position)
					local particle = emitter:Add("effects/redflare", self.Position)
			particle:SetVelocity(500 * self.Forward + 15 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(1, 2))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(8, 12))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-5, 45))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))
			particle:SetColor(10, 50, 255)
			
								local particle = emitter:Add("effects/redflare", self.Position)
			particle:SetVelocity(500 * self.Forward + 15 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(1, 2))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(8, 12))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-5, 45))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))
			particle:SetColor(10, 50, 255)
			
			

	emitter:Finish()
	
	
end


function EFFECT:Think( )

	self.FlashA = self.FlashA - 1150 * FrameTime()
	if (self.FlashA < 0) then self.FlashA = 0 end

	self.Alpha = self.Alpha - 1350 * FrameTime()
	if (self.Alpha < 0) then return false end
	
	return true

end


function EFFECT:Render( )
	
	self.Length = (self.StartPos - self.EndPos):Length()
	
	local texcoord = self.texcoord
	
		render.SetMaterial( self.Mat )
		render.DrawBeam( self.StartPos, 										// Start
					 self.EndPos,											// End
					 7,													// Width
					 texcoord,														// Start tex coord
					 texcoord + self.Length / 256,									// End tex coord
					 Color( 205, 205, 205, math.Clamp(self.Alpha, 0,255)) )		// Color (optional)'
					 
end
