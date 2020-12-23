
if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 7
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Broom"
	SWEP.DrawCrosshair = true
end

SWEP.Author			= "Nforce"
SWEP.Instructions	= "Primary Fire: Sweep"
SWEP.Purpose 		= "Sweeping."
SWEP.Contact 		= ""
SWEP.AdminSpawnable = true
SWEP.ViewModel      = ""
SWEP.WorldModel   	= ""
SWEP.HoldType 		= "broom"

SWEP.FireWhenLowered	= true
SWEP.IsAlwaysLowered	= true

SWEP.Primary.Delay			= 2 	--In seconds
SWEP.Primary.Damage			= 0		--Damage per Bullet
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.ClipSize		= -1	--Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= -1	--Number of shots in next clip
SWEP.Primary.Automatic   	= false	--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "none"	--Ammo Type

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo	= ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

if (SERVER) then
	function SWEP:Deploy()
		self:CreateBroom()
	end

	function SWEP:Holster()
		if (IsValid(self.Owner.broomProp)) then
			self.Owner.broomProp:Remove()
			self.Owner:ForceSequence(false)
		end

		return true
	end

	function SWEP:CreateBroom()
		local animClass = ix.anim.GetModelClass(self.Owner:GetModel())

		if (animClass == "vortigaunt") then
			self.Owner.broomProp = ents.Create("prop_dynamic")

			self.Owner.broomProp:SetModel("models/props_c17/pushbroom.mdl")
			self.Owner.broomProp:DrawShadow(true)
			self.Owner.broomProp:SetMoveType(MOVETYPE_NOCLIP)
			self.Owner.broomProp:SetParent(self.Owner)
			self.Owner.broomProp:SetSolid(SOLID_NONE)
			self.Owner.broomProp:Spawn()

			self.Owner.broomProp:Fire("setparentattachment", "cleaver_attachment", 0.01)
		end
	end

	function SWEP:OnRemove()
		if (IsValid(self.Owner.broomProp)) then
			self.Owner.broomProp:Remove()
			self.Owner:ForceSequence(false)
		end

		return true
	end
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end

	if (IsValid(self.Owner.broomProp)) then
		self.bSweeping = true

		self.Owner:ForceSequence("sweep", function()
			self.bSweeping = false
		end, nil, true)
	else
		self:CreateBroom()
	end
end

function SWEP:SecondaryAttack()
end

