AddCSLuaFile()

SWEP.PrintName          = "Rocket Strike Marker"
SWEP.Slot               = 5

function SWEP:MarkTarget(pos)
    Profiteers:SpawnAttackerPlane(self:GetOwner(), pos)
end