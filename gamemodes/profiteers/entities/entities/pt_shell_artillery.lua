AddCSLuaFile()

ENT.Base = "pt_base_shell"

ENT.PrintName = "Artillery Shell"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/mk-82.mdl"

ENT.TargetPos = Vector(0, 0, 0)

ENT.IsAirAsset = true
ENT.AirAssetWeight = 2

ENT.BaseHealth = 100

DEFINE_BASECLASS(ENT.Base)

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)
        util.SpriteTrail(self, 0, Color(100, 100, 100, 200), false, 32, 0, 1, 1 / 32 * 0.5, "trails/smoke")
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
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), 1500, 300)
        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), 500, 1200)

        self:Remove()
    end
end