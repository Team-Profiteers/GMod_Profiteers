AddCSLuaFile()

SWEP.PrintName          = "Bunker Buster Marker"
SWEP.Slot               = 5

SWEP.ViewModel             = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_smokegrenade.mdl"

SWEP.UseHands = true

SWEP.Primary.ClipSize      = -1
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.Delay         = 10

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 5

SWEP.MarkerEntity = "pt_marker_base"

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Armed")
end

function SWEP:Initialize()
    self:SetHoldType("grenade")
end

function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("deploy"))
    vm:SetPlaybackRate(1)

    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())

    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end

    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("throw"))
    vm:SetPlaybackRate(1)

    self:SetArmed(true)
    self:SetNextSecondaryFire(CurTime() + 0.5)

    self:SetNextPrimaryFire(CurTime() + 10000)
end

function SWEP:Throw()
    local owner = self:GetOwner()

    if SERVER then
        local ent = ents.Create(self.MarkerEntity)
        if !IsValid(ent) then return end
        ent:SetPos(self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * 16)
        ent:SetAngles(Angle(0, self:GetOwner():EyeAngles().y, 0))
        ent:SetOwner(owner)
        ent:Spawn()

        local phys = ent:GetPhysicsObject()

        if phys:IsValid() then
            phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 5000)
            phys:AddAngleVelocity(VectorRand() * 500)
        end

        owner:StripWeapon(self:GetClass())
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    if self:GetArmed() and self:GetNextSecondaryFire() < CurTime() then
        self:Throw()
    end
end