SWEP.Base = "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Dual Silencer Pistols"
SWEP.Slot		 = 2
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_vir_dsilen.mdl"
SWEP.WorldModel		 = "models/weapons/w_vir_dsilen.mdl"
SWEP.WepSelectIcon   = surface.GetTextureID("materials/gmod_tower/virus/icons/weapon_silencers")
SWEP.ViewModelFlip	 = true

SWEP.HoldType		= "duel"

SWEP.Primary.Delay	 = 0.3
SWEP.Primary.Damage	 = {12, 18}
SWEP.Primary.Cone	 = 0.04
SWEP.Primary.ClipSize	 = 24
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Ammo	 = "pistol"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/dualsilencer/shoot.wav" 

SWEP.Secondary = SWEP.Primary


function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end


function SWEP:PrimaryAttack()
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end

	self:SetNextSecondaryFire( CurTime() + 0.05 )
end

function SWEP:SecondaryAttack()
	if self.BaseClass.SecondaryAttack(self.Weapon) then return end

	self:SetNextPrimaryFire( CurTime() + 0.05 )
end