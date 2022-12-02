AddCSLuaFile()

SWEP.PrintName          = "Cruise Missile Marker"
SWEP.Slot               = 5

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
    if self:GetNextPrimaryFire() > CurTime() then return end

    if SERVER then
        local tr = util.TraceLine({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 50000,
            filter = self:GetOwner(),
            mask = MASK_SHOT
        })
        Profiteers:SpawnCruiseMissilePlane(tr.HitPos, self:GetOwner())

        self:GetOwner():StripWeapon(self:GetClass())
    end


    self:SetNextPrimaryFire(CurTime() + 10000)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end