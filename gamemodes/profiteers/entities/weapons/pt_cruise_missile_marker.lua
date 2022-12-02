AddCSLuaFile()

SWEP.PrintName          = "Cruise Missile Marker"
SWEP.Slot               = 5

SWEP.Base = "pt_marker_base"

function SWEP:MarkTarget(pos)
    Profiteers:SpawnCruiseMissilePlane(pos, self:GetOwner())
end