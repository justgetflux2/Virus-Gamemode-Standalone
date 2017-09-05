
EFFECT.Duration			= 0.25;
EFFECT.Size				= 32;

local MaterialGlow		= Material( "effects/yellowflare" );



function EFFECT:Init( data )

	self.Position = data:GetOrigin();
	self.Normal = data:GetNormal();
	self.LifeTime = self.Duration;

	-- particles
	local emitter = ParticleEmitter( self.Position );
	if( emitter ) then
		
		for i = 1, 32 do

			local particle = emitter:Add( "effects/yellowflare", self.Position + self.Normal * 2 );
			particle:SetVelocity( ( self.Normal + VectorRand() * 0.75 ):GetNormal() * math.Rand( 75, 125 ) );
			particle:SetDieTime( math.Rand( 0.5, 1.25 ) );
			particle:SetStartAlpha( 255 );
			particle:SetEndAlpha( 0 );
			particle:SetStartSize( math.Rand( 10, 25 ) );
			particle:SetEndSize( 0 );
			particle:SetRoll( 0 );
			particle:SetColor( 25, 205, 25, 255);
			particle:SetGravity( Vector( 0, 0, -250 ) );
			particle:SetCollide( true );
			particle:SetBounce( 0.4 );
			particle:SetAirResistance( 0 );

		end

		emitter:Finish();

	end
	
	-- light
	local light = DynamicLight( 1 );
	if( light ) then

		light.Pos = self.Position;
		light.Size = 165;
		light.Decay = 256;
		light.R = 25;
		light.G = 205;
		light.B = 25;
		light.Brightness = 3;
		light.DieTime = 100000;

	end

end


function EFFECT:Think()

	self.LifeTime = self.LifeTime - FrameTime();
	return self.LifeTime > 0;

end


function EFFECT:Render()

	local frac = math.max( 0, self.LifeTime / self.Duration );
	local rgb = 255 * frac;
	local color = Color( rgb, rgb, rgb, 255 );

	render.SetMaterial( MaterialGlow );
	render.DrawQuadEasy( self.Position + self.Normal, self.Normal, self.Size, self.Size, color );

end
