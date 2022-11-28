AddCSLuaFile()

ENT.Base = "pt_base_cart"

ENT.PrintName = "Health Station"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/reciever_cart.mdl"

ENT.PreferredAngle = Angle(0, 180, 0)

ENT.ChargeRate = 0.04
ENT.ThinkDelay = 0.1

ENT.ChargeColor = Color(175, 255, 120, 200)
ENT.ChargeName = "Health"

ENT.ChargeRatio = 150

ENT.Bounty = 1000

if SERVER then

    function ENT:CanConsume(ply)
        return ply:Health() < ply:GetMaxHealth() and math.floor(self:GetCharge() * self.ChargeRatio) > 0
    end

    function ENT:OnConsume(ply)
        local diff = math.min(ply:GetMaxHealth() - ply:Health(), math.floor(self:GetCharge() * self.ChargeRatio))
        ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + diff))
        self:SetCharge(self:GetCharge() - diff / self.ChargeRatio)
        self:EmitSound("items/smallmedkit1.wav", 80, 92)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)

        for i = 1, math.floor(self:GetCharge() * self.ChargeRatio / 10 * math.Rand(0.5, 1)) do
            local ent = ents.Create("item_healthvial")
            ent:SetPos(self:GetPos() + VectorRand() * 8)
            ent:SetAngles(AngleRand())
            ent:Spawn()
            ent:GetPhysicsObject():ApplyForceCenter(VectorRand() * 256)
            SafeRemoveEntityDelayed(ent, 120)
        end

        local ent = ents.Create("pt_money")
        ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
        ent:SetAmount(self.Bounty)
        ent:Spawn()
    end
end