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

        self.SpawnTime = CurTime()
    end

    function ENT:PhysicsCollide(colData, collider)
        if self.Detonated then return end

        self:Detonate()
    end

    function ENT:Think()
        // guide bomb towards target

        local targetpos = self.TargetPos
        local selfpos = self:GetPos()

        targetpos.z = 0
        selfpos.z = 0

        local dir = (targetpos - selfpos):GetNormalized()
        local dist = (targetpos - selfpos):Length()
        local phys = self:GetPhysicsObject()
        phys:ApplyForceCenter(Vector(0, 0, -600) + (dir * 20000 * dist / 1000))

        if self.SpawnTime + 10 < CurTime() then
            self:Remove()
        end
    end

    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 1024, 200)

        local groundtrace = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() - Vector(0, 0, 128),
            filter = self
        })

        if !groundtrace.Hit then
            self.Dud = true
        end

        if !self.Dud then
            local mypos = self:GetPos()
            local owner = self:GetOwner()

            for i = 1, 50 do
                local blastpos = mypos - Vector(0, 0, i * 256)

                if util.IsInWorld(blastpos) then
                    local effectdata2 = EffectData()
                    effectdata2:SetOrigin(blastpos)
                    util.Effect("Explosion", effectdata2)

                    util.BlastDamage(self, owner, blastpos, 1024, 200)
                end
            end
        end

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