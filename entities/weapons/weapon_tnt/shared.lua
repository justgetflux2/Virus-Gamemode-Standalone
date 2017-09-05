SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Babynade"
SWEP.Slot		 = 5
SWEP.SlotPos		 = 0

SWEP.ViewModel			 = "models/weapons/v_vir_tnt.mdl"
SWEP.WorldModel			 = "models/weapons/w_vir_tnt.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "grenade"

SWEP.AutoReload		 = true

SWEP.Primary.Delay	 = 1.6
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 0
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo	 = "SMG1_Grenade"

SWEP.Secondary		 = SWEP.Primary

--SWEP.SoundDeploy	 = "ambient/creatures/teddy.wav"

SWEP.Throw		 = 0
SWEP.ThrowHard		 = false
SWEP.ThrowMode		 = 0

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	

	self.Throw = CurTime()
	self.ThrowHard = true
	self.ThrowMode = 0

	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )

	self:Reload()
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Throw = CurTime()
	self.ThrowHard = false
	self.ThrowMode = 0

	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )

	self:Reload()
end

function SWEP:Think()
	if self.Throw == 0 then return end

	if CurTime() >= self.Throw + 0.5 && self.ThrowMode == 0 then

		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )

		local force = 200

		if self.ThrowHard then
			force = 2250
		end

		self:ShootEnt( "vir_tnt2", force )

		self.ThrowMode = 1

	elseif CurTime() >= self.Throw + 0.75 && self.ThrowMode == 1 then

		self.Weapon:StripWeapon("weapon_tnt")
		self.Throw = 0

	end
end

function SWEP:Reload()
	return false
end