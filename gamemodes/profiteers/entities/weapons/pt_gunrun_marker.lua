AddCSLuaFile()

SWEP.PrintName          = "Gun Run Marker"
SWEP.Slot               = 5

SWEP.Base = "pt_marker_base"

function SWEP:MarkTarget(pos)
    Profiteers:SpawnGunRunPlane(self:GetOwner(), pos)
end