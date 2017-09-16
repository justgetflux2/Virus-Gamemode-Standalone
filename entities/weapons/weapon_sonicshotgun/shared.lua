SWEP.Base = "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Sonic Shotgun W.I.P Edition"
SWEP.Slot		 = 3
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_vir_scattergun.mdl"
SWEP.WorldModel		 = "models/weapons/w_vir_scattergun.mdl"
SWEP.WepSelectIcon       = "materials/gmod_tower/virus/icons/weapon_sonicshotgun"
SWEP.HoldType		 = "shotgun"
SWEP.ViewModelFlip	 = false

SWEP.Primary.Delay	 = 0.3
SWEP.Primary.Damage	 = {20, 15}
SWEP.Primary.ClipSize	 = 12
SWEP.Primary.DefaultClip = 42
SWEP.Primary.Ammo	 = "buckshot"

SWEP.Primary.Sound	 = {"GModTower/virus/weapons/sonicdispersionshotgun/shoot1.wav",
			    "GModTower/virus/weapons/sonicdispersionshotgun/shoot2.wav"}
SWEP.Primary.Cone	 = 0.15
SWEP.Primary.NumShots	 = 8
SWEP.MuzzleEffect			= "muzzle" 
SWEP.MuzzleAttachment		= "muzzle" 
SWEP.ShellEjectAttachment	= "2"



--SWEP.SoundReload	 = "GModTower/pvpbattle/RagingBull/bullreload.wav"
--SWEP.SoundDeploy	 = "GModTower/pvpbattle/RagingBull/bulldraw.wav"

--[[function SWEP:SecondaryAttack()
	if self:KeyDown( IN_ATTACK2 ) then 
self.Weapon:SendWeaponAnim( ACT_SHOTGUN_PUMP ) 
    elseif self:KeyReleased( IN_ATTACK2 ) then 
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.05 )
end]]

function SWEP:Initialize()
	self.BaseClass.Initialize(self.Weapon)
    self:SetWeaponHoldType( self.HoldType )
	--RegisterNWTable(self, { {"reloading", false, NWTYPE_BOOLEAN} })
end

function SWEP:ShootEffects(sound, recoil)
	self.BaseClass.ShootEffects(self.Weapon, sound, recoil)
end

function SWEP:CanSecondaryAttack()
return false
end
