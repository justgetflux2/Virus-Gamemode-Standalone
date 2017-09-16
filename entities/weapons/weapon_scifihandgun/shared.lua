SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "9MM Pistol"
SWEP.Slot		 = 2
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_vir_scifihg.mdl"
SWEP.WorldModel		 = "models/weapons/w_vir_9mm1.mdl"
SWEP.WepSelectIcon       = surface.GetTextureID("materials/gmod_tower/virus/icons/weapon_scifihandgun")
SWEP.ViewModelFlip	 = true

SWEP.HoldType		= "pistol"

SWEP.Primary.Delay	 = 0.3
SWEP.Primary.Damage	 = {12, 10}
SWEP.Primary.Cone	 = 0.04
SWEP.Primary.ClipSize	 = 10
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Ammo	 = "pistol"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/9mm/shoot.wav"
SWEP.Primary.Effect		= "toy_zap"

SWEP.Secondary = SWEP.Primary

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	-- if self.BaseClass.PrimaryAttack(self.Weapon) then
	-- 	self.Primary.Effect
	-- 	return
	-- end TODO This probably needs to be resolved...
end

SWEP.DamageType = bit.bor(DMG_SHOCK,DMG_DISSOLVE)

SWEP.TracerCount 		= 1 	--0 disables, otherwise, 1 in X chance

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
	bullet.Num 		= 1
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( 0,0 ,0 )
	bullet.Tracer	= 1
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

SWEP.Primary.NumShots	= 1		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 16	-- Base damage per bullet
