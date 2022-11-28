AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Launchpad"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/xqm/Rails/funnel.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 350

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorOffset = Vector(0, 0, 0)
ENT.AnchorRequiresBeacon = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

if SERVER then
    function ENT:Think()
        if !self:GetAnchored() then return end

        local ents = ents.FindInSphere(self:GetPos(), 32)

        for i, k in ipairs(ents) do
            if k:IsPlayer() then
                k:SetVelocity(Vector(0, 0, 5000))
            end
        end
    end
end