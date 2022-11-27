AddCSLuaFile()
ENT.PrintName = "Mine"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/hunter/misc/sphere025x025.mdl"

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
        // sit down on the ground
        if colData.HitEntity:IsWorld() then
            if colData.HitNormal.z < 0 then
                self:SetPos(colData.HitPos)
                self:SetMoveType(MOVETYPE_NONE)
            end
        elseif !colData.HitEntity:IsWorld() then
            self:Detonate()
        end
    end

    function ENT:Think()
        local ents = ents.FindInSphere(self:GetPos(), 32)

        for k, v in pairs(ents) do
            if v:IsPlayer() or v:IsNPC() then
                self:Detonate()
                break
            end
        end

        if (self.SpawnTime + 600) < CurTime() then
            self:Detonate()
        end
    end

    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("HelicopterMegaBomb", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 256, 100)

        self:Remove()
    end

    function ENT:OnTakeDamage(damage)
        if damage:GetInflictor():GetClass() == "pt_mine" then return end
        self:Detonate()
    end
end

if CLIENT then
ENT.RandoTime = 0

    function ENT:Initialize()
        self.RandoTime = math.Rand(0, 1)

        self:DrawShadow(false)
    end

    local glowmat = Material("sprites/redglow1")

    function ENT:Draw()
    end

    function ENT:DrawTranslucent(flags)
        if (math.sin(self.RandoTime + (CurTime() * 8)) > 0.75) then
            render.SetMaterial(glowmat)
            render.DrawSprite(self:GetPos(), 12, 12, Color(255, 255, 255))
        end
    end
end