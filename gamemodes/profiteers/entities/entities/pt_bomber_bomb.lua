AddCSLuaFile()
ENT.PrintName = "Bunker Buster"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/mk-82.mdl"

ENT.TargetPos = Vector(0, 0, 0)

ENT.IsAirAsset = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:DrawShadow(false)

        local phys = self:GetPhysicsObject()
        phys:SetMass(250)

        self.SpawnTime = CurTime()
    end

    function ENT:PhysicsCollide(colData, collider)
        self:Detonate()
    end

    function ENT:Think()
        // guide bomb towards target

        local phys = self:GetPhysicsObject()
        phys:EnableGravity(true)
        phys:SetDragCoefficient(0)

        local targetpos = self.TargetPos
        local selfpos = self:GetPos()

        local dir = (targetpos - selfpos):GetNormalized()
        dir.z = 0
        phys:ApplyForceCenter(dir * FrameTime() * 1500)
    end

    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 512, 200)

        self:Remove()
    end

    function ENT:OnTakeDamage(damage)
        self:Detonate()

        return damage:GetDamage()
    end
end

if CLIENT then
    function ENT:Initialize()
    end

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:DrawTranslucent(flags)
        self:Draw()
    end
end