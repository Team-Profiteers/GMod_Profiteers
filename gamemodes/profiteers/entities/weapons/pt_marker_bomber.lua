AddCSLuaFile()

SWEP.PrintName          = "Bunker Buster Marker"
SWEP.Slot               = 5

SWEP.Base = "pt_marker_base"

function SWEP:MarkTarget(pos)
    Profiteers:SpawnBunkerBusterPlane(self:GetOwner(), pos)
end