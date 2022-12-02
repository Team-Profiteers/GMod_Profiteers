AddCSLuaFile()

SWEP.PrintName          = "Sentry Targeter"
SWEP.Slot               = 0

SWEP.ViewModel             = "models/weapons/c_pistol.mdl"
SWEP.WorldModel            = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

SWEP.Primary.ClipSize      = -1
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.Delay         = 10

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 5

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
    vm:SetPlaybackRate(1)

    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())

    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end