SWEP.Base = "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "9MM Pistol"
SWEP.Slot		 = 2
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_vir_9mm1.mdl"
SWEP.WorldModel		 = "models/weapons/w_vir_9mm1.mdl"
SWEP.ViewModelFlip	 = true
SWEP.ViewModelFOV = 81.74036340625



SWEP.HoldType		= "pistol"

SWEP.Primary.Delay	 = 0.3
SWEP.Primary.Damage	 = {12, 10}
SWEP.Primary.Cone	 = 0.04
SWEP.Primary.ClipSize	 = 10
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Ammo	 = "pistol"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/9mm/shoot.wav" 

SWEP.Secondary = SWEP.Primary


function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end


function SWEP:PrimaryAttack()
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end

end

function SWEP:CanSecondaryAttack()
return false
end
