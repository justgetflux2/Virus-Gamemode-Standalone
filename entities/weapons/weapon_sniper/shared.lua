SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Sniper Rifle"
SWEP.Slot		 = 4
SWEP.SlotPos		 = 1

SWEP.ViewModel			 = "models/weapons/v_vir_snp.mdl"
SWEP.WorldModel			 = "models/weapons/w_vir_snp.mdl"
SWEP.HoldType			 = "ar2"

SWEP.Primary.Delay	 = 1
SWEP.Primary.Damage	 = {25, 40}
SWEP.Primary.Recoil	 = 4
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo	 = "SniperRound"
SWEP.Primary.Effect	 = "sniper_trace"
SWEP.Primary.Sound	 = "GModTower/virus/weapons/Sniper/shoot.wav"

SWEP.SoundEmpty		 = "Weapon_Pistol.Empty"

if CLIENT then
	SWEP.SniperHUD = surface.GetTextureID( "gmod_tower/virus/zoom" )
end

SWEP.SoundZoom		= "GModTower/virus/weapons/iron_in.wav"
SWEP.SoundUnZoom	= "GModTower/virus/weapons/iron_out.wav"

function SWEP:Initialize()
	self.BaseClass.Initialize(self.Weapon)

	--RegisterNWTable(self, { {"Zoomed", false, NWTYPE_BOOLEAN} })
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end

	self:ShootZoom( 20, 0.5 )
end

function SWEP:CanSecondaryAttack()
	return true
end

function SWEP:Deploy()
	self:ClearZoom()
	return true
end

function SWEP:Holster()
	self:ClearZoom()
	return true
end

function SWEP:SpecialReload()
	self:ClearZoom()
end

function SWEP:ClearZoom()
	if self.Zoomed then
		self.Zoomed = false
		self:UnZoom()
	end
end

function SWEP:ShootZoom( fov, delay )
	self.NextZoom = self.NextZoom || CurTime()
	if CurTime() < self.NextZoom then return end
	self.NextZoom = CurTime() + delay

	local zoomed = self.Zoomed
	self.Zoomed = !zoomed

	if zoomed then
		self:UnZoom()
	else
		if SERVER then
			self.Owner.PrevFOV = self.Owner:GetFOV()
			self.Owner:SetFOV( fov, 0.2 )
		else
			surface.PlaySound( self.SoundZoom )
		end
	end
end

function SWEP:UnZoom()
	if SERVER then
		self.Owner:SetFOV( ( self.Owner.PrevFOV ), 0.2 )
	else
		surface.PlaySound( self.SoundUnZoom )
	end
end

function SWEP:DrawHUD()
	if self.Zoomed then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, math.random( 230, 255 ), 0, math.random(10, 15) ) )
		surface.SetTexture( self.SniperHUD )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawLine( 0, ScrH() / 2, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW(), ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, 0, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW() / 2, ScrH() )
	end
end
