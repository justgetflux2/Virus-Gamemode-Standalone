SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Raging Bull"
SWEP.Slot		 = 1
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_vir_flakhg.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_ragingb.mdl"
SWEP.HoldType		 = "pistol"

SWEP.Primary.Delay	 = 0.5
SWEP.Primary.Damage	 = {20, 25}
SWEP.Primary.ClipSize	 = 6
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Ammo	 = "357"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/flakhandgun/shoot.wav"
SWEP.Primary.Effect		= "toy_zap"

SWEP.Ricochet		 = false

SWEP.SoundReload	 = "GModTower/virus/weapons/flakhandgun/reload.wav"
SWEP.SoundDeploy	 = "GModTower/virus/weapons/flakhandgun/deploy.wav"

function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end


function SWEP:PrimaryAttack()
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end



end


SWEP.DamageType = bit.bor(DMG_SHOCK,DMG_DISSOLVE)

SWEP.TracerCount 		= 5 	--0 disables, otherwise, 1 in X chance

function SWEP:DoImpactEffect( tr, dmgtype )

	if( tr.HitSky ) then return true; end
	
	util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );
	sound.Play( "Weapon_Gamma.Shocking", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, 180 );
	

	
	-- is this even the correct way to handle this?
	if( game.SinglePlayer() or SERVER or not self:IsCarriedByLocalPlayer() or IsFirstTimePredicted() ) then

		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetNormal( tr.HitNormal );

		util.Effect( "Gamma_Impact", effect );
		

		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetStart( tr.StartPos );
		effect:SetDamageType( dmgtype );

		util.Effect( "RagdollImpact", effect );
		
	end

    return true;

end


function SWEP:ShootBullet( damage, num_bullets, aimcone )
	local bullet = {}
	bullet.Num 		= 5
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector( 0,0 ,0 )		
	bullet.Tracer	= 5			
    bullet.TracerName = "GammaLaser"	
	bullet.Force	= 5000									
	bullet.Damage	= 25
	bullet.AmmoType = "AR2AltFire"
	bullet.Callback = function(attacker,tr,dmginfo)
			ParticleEffect("electrical_arc_01_system",tr.HitPos,Angle(0,0,0),nil)
			end
	self.Owner:FireBullets( bullet )
	self:ShootEffects()
	
end

SWEP.Primary.NumShots	= 6		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 10	-- Base damage per bullet
