AddCSLuaFile()

ENT.Base = "pt_marker_base"

ENT.PrintName = "Bunker Buster Smoke"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

if SERVER then
    function ENT:MarkTarget()
        Profiteers:SpawnBunkerBusterPlane(self:GetPos(), self:GetOwner())
    end
end