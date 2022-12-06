AddCSLuaFile()
ENT.PrintName = "Light Bomb"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/ww2bomb.mdl"

ENT.TargetPos = nil

ENT.IsAirAsset = true
ENT.AirAssetWeight = 1.5

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:DrawShadow(false)

        self.SpawnTime = CurTime()
        self.StartPos = self:GetPos()

        -- if IsValid(self:GetPhysicsObject()) then
        --     self:GetPhysicsObject():SetDragCoefficient(0)
        -- end
    end

    function ENT:PhysicsCollide(colData, collider)
        self:Detonate()
    end

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        local add = Vector(0, 0, -180000 * 0.2)
        if (self.TargetPos) then
            local d = self.TargetPos - self.StartPos
            d.z = 0
            add = add + d:GetNormalized() * 145000 * 0.2
            debugoverlay.Cross(self:GetPos(), 24, 10, Color(0, 255, 255), true)
        end
        phys:ApplyForceCenter(add)

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

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 2048, 400)
        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 512, 600)

        self:Remove()
    end

    function ENT:OnTakeDamage(dmginfo)
        if self.Detonated or dmginfo:GetInflictor():GetClass() == self:GetClass() then return end
        self.Dud = true
        self:Detonate()

        if !self.Paid and self.Bounty and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and (dmginfo:GetAttacker() != self:GetOwner() or GetConVar("pt_dev_airffa"):GetBool()) then
            dmginfo:GetAttacker():AddMoney(self.Bounty * GetConVar("pt_money_airmult"):GetFloat())
            self.Paid = true
        end

        if self.MarkerID then
            Profiteers:KillMarker(self.MarkerID, false)
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