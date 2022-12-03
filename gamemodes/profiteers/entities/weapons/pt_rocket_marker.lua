AddCSLuaFile()

SWEP.PrintName          = "CAS Bomber Marker"
SWEP.Slot               = 5

SWEP.Base = "pt_marker_base"

function SWEP:MarkTarget(pos)
    Profiteers:SpawnAttackerPlane(self:GetOwner(), pos)
end