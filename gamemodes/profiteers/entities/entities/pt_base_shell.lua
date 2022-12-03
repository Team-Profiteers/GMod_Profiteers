AddCSLuaFile()
ENT.PrintName = "Base Bomb"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/mk-82.mdl"

ENT.TargetPos = Vector(0, 0, 0)

ENT.IsAirAsset = true
ENT.AirAssetWeight = 2

ENT.BaseHealth = 100

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:DrawShadow(false)

        self:SetMaxHealth(self.BaseHealth)
        self:SetHealth(self.BaseHealth)

        self.SpawnTime = CurTime()
    end

    function ENT:PhysicsCollide(colData, collider)
        if self.Detonated then return end

        self:Detonate()
    end

    function ENT:Think()
        // guide bomb towards target

        if self.TargetPos then
            local targetpos = self.TargetPos
            local selfpos = self:GetPos()

            targetpos.z = 0
            selfpos.z = 0

            local phys = self:GetPhysicsObject()
            phys:ApplyForceCenter(Vector(0, 0, -40000 * 0.2))
        end

        if self.SpawnTime + 20 < CurTime() then
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

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 2048, 3000)

        self:Remove()
    end

    function ENT:OnTakeDamage(dmginfo)
        self.Dud = true
        self:Detonate()

        if !self.Paid and self.Bounty and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and (dmginfo:GetAttacker() != self:GetOwner() or GetConVar("pt_dev_airffa"):GetBool()) then
            dmginfo:GetAttacker():AddMoney(self.Bounty * GetConVar("pt_money_airmult"):GetFloat())
            self.Paid = true
        end

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