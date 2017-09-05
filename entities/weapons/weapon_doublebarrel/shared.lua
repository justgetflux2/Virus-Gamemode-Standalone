SWEP.Base = "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Double-Barrel"
SWEP.Slot		 = 3
SWEP.SlotPos		 = 0

SWEP.ViewModel		 = "models/weapons/v_vir_doubleb.mdl"
SWEP.WorldModel		 = "models/weapons/w_vir_doubleb.mdl"
SWEP.HoldType		 = "shotgun"
--SWEP.ViewModelFlip			= true
SWEP.ViewModelFlip			= false
SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.8
SWEP.Primary.Damage	 = {22, 20}
SWEP.Primary.Cone	 = 0.15
SWEP.Primary.NumShots	 = 7
SWEP.Primary.ClipSize	 = 2
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Ammo	 = "Buckshot"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/doublebarrel/shoot.wav" 
SWEP.MuzzleEffect			= "muzzle" 
SWEP.MuzzleAttachment		= "muzzle" 
SWEP.ShellEjectAttachment	= "2"

function SWEP:Initialize()
	self.BaseClass.Initialize(self.Weapon)
    self:SetWeaponHoldType( self.HoldType )
	--RegisterNWTable(self, { {"reloading", false, NWTYPE_BOOLEAN} })
end

function SWEP:ShootEffects(sound, recoil)
	self.BaseClass.ShootEffects(self.Weapon, sound, recoil)
    self:CustomParticles()
end

function SWEP:CanPrimaryAttack()
	if self.reloading then
		if self.Weapon:GetVar( "interrupt", 0 ) == 0 then
			self.Weapon:SetVar( "interrupt", 1 )
		end

		return false
	end

	return self.BaseClass.CanPrimaryAttack(self.Weapon)
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SpecialReload()
	if self.reloading then return true end

	self.reloading = true

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
    self.Weapon:EmitSound("GModTower/virus/weapons/doublebarrel/reload_start.wav")

	self.Weapon:SetVar( "interrupt", 0 )
	
	self.Owner:SetAnimation( PLAYER_RELOAD )

	return true
end

function SWEP:Think()
	if !self.reloading then return end
	if CurTime() < self.Weapon:GetVar( "reloadtimer", 0) then return end

	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 2 then
		self.reloading = false
		self.Weapon:SetNextPrimaryFire( CurTime() + .4 )
		return
	end

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
    self.Weapon:EmitSound("GModTower/virus/weapons/doublebarrel/shell_insert.wav")

	self.Owner:SetAnimation( PLAYER_RELOAD )
			
	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 1 then
		self.Weapon:SetVar( "interrupt", 2 )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
        self.Weapon:EmitSound("GModTower/virus/weapons/doublebarrel/reload_finish.wav")
	end
end

--SWEP.CanSecondaryAttack = SWEP.CanPrimaryAttack

function SWEP:CustomParticles()
local vm = self.Owner:GetViewModel()
if self.Owner:GetActiveWeapon() == nil then return end
if self.Owner:GetNWBool("Silencer") == true then
ParticleEffectAttach("muzzleflash_suppressed",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment(self.MuzzleAttachment or "muzzle"))
else
--[[timer.Create("fuckfire",0.0,1,function()ParticleEffectAttach("muzzleflash_ak74",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment(self.MuzzleAttachment or "muzzle")) end)
timer.Create("fuckfire",0.0,2,function()ParticleEffectAttach("muzzleflash_m14",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment(self.MuzzleAttachment or "muzzle")) end)]]
timer.Create("fuck2fire",1,1,function()ParticleEffectAttach("VIEW_Weaponry_AfterSmoke_FX",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment(self.MuzzleAttachment or "muzzle")) end)
ParticleEffectAttach(self.MuzzleName or "btb_vm_small",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment(self.MuzzleAttachment or "muzzle"))
end
end


function SWEP:DispatchEffect(EFFECTSTR)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer:GetViewModel(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end

function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "anim_attachment_rh" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end