AddCSLuaFile()

ENT.Base = "pt_base_shell"

ENT.PrintName = "Mortar Shell"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/Items/AR2_Grenade.mdl"

ENT.TargetPos = Vector(0, 0, 0)

ENT.IsAirAsset = true
ENT.AirAssetWeight = 0.75

ENT.BaseHealth = 100

DEFINE_BASECLASS(ENT.Base)

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)
        self:SetModelScale(3)
        util.SpriteTrail(self, 0, Color(100, 100, 100, 100), false, 4, 0, 1, 1 / 4 * 0.5, "trails/smoke")

    end
    function ENT:Think()
        local phys = self:GetPhysicsObject()
        local add = Vector(0, 0, -300000 * 0.2)
        phys:ApplyForceCenter(add)

        if self.SpawnTime + 10 < CurTime() then
            self:Remove()
        end

        self:NextThink(CurTime() + 0.2)
        return true
    end
    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)

        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), 512, 100)
        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), 128, 400)

        self:Remove()
    end
end