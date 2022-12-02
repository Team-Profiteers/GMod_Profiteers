AddCSLuaFile()

SWEP.PrintName          = "Gun Run Marker"
SWEP.Slot               = 5

SWEP.ViewModel             = "models/weapons/profiteers/c_mw3e_soflam.mdl"
SWEP.WorldModel            = "models/maxofs2d/camera.mdl"

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
    self:SetHoldType("camera")
end

function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("on"))
    vm:SetPlaybackRate(1)

    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())

    self:GetOwner():SetFOV(75, 1)

    return true
end

function SWEP:Holster()
    self:GetOwner():SetFOV(0, 0.5)
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

        self:MarkTarget(tr.HitPos)

        self:GetOwner():StripWeapon(self:GetClass())
    end


    self:SetNextPrimaryFire(CurTime() + 10000)
end

function SWEP:MarkTarget(pos)
    Profiteers:SpawnGunRunPlane(self:GetOwner(), pos)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    if self:GetNextPrimaryFire() < CurTime() then
        render.SetBlend(0)
    end
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    render.SetBlend(1)
end

local overlay = Material("profiteers/javelin.png", "noclamp smooth")

function SWEP:DrawHUD()
    if self:GetNextPrimaryFire() < CurTime() then
        local w = ScrW()
        local h = ScrW()

        surface.SetDrawColor(255, 255, 255, 255)

        surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
        surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())

        local x = 0
        local y = (ScrH() - h) / 2

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(overlay)
        surface.DrawTexturedRect(x, y, w, h)
    end
end