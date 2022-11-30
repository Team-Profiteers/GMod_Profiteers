AddCSLuaFile()
ENT.PrintName = "Light Bomb"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/ww2bomb.mdl"

ENT.TargetPos = Vector(0, 0, 0)

ENT.IsAirAsset = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:DrawShadow(false)

        self.SpawnTime = CurTime()
    end

    function ENT:PhysicsCollide(colData, collider)
        self:Detonate()
    end

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:ApplyForceCenter(Vector(0, 0, -2500) * FrameTime() + VectorRand() * FrameTime() * 1024)
    end

    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 1024, 200)

        self:Remove()
    end

    function ENT:OnTakeDamage(damage)
        self.Dud = true
        self:Detonate()
        return 0
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