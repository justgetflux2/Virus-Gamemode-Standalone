SWEP.Base = "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Thompson"
SWEP.Slot		 = 4
SWEP.SlotPos		 = 1

SWEP.ViewModel			 = "models/weapons/v_vir_tom.mdl"
SWEP.WorldModel			 = "models/weapons/w_vir_tom.mdl"
SWEP.WepSelectIcon       = surface.GetTextureID("materials/gmod_tower/virus/icons/weapon_tommygun")
SWEP.ViewModelFlip		 = true
SWEP.HoldType			 = "ar2"

SWEP.Primary.Automatic	 = true
SWEP.Primary.Delay	 = 0.10
SWEP.Primary.Damage	 = {20, 15}
SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Sound	 = "GModTower/virus/weapons/thompson/thompsonfire.wav"
SWEP.SoundDeploy	 = "GModTower/virus/weapons/thompson/thompsondeploy.wav"
SWEP.Primary.Ammo	 = "SMG1"


function SWEP:PrimaryAttack()
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end

end

