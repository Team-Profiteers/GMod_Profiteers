AddCSLuaFile()

ENT.Base = "pt_base_cart"

ENT.PrintName = "Armor Station"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/reciever_cart.mdl"

ENT.PreferredAngle = Angle(0, 180, 0)

ENT.ChargeRate = 0.5
ENT.ThinkDelay = 0.1

ENT.ChargeColor = Color(125, 150, 255, 200)
ENT.ChargeName = "Armor"

ENT.ChargeRatio = 100

ENT.Bounty = 1500

if SERVER then

    function ENT:CanConsume(ply)
        return ply:Armor() < ply:GetMaxArmor() and math.floor(self:GetCharge() * self.ChargeRatio) > 0
    end

    function ENT:OnConsume(ply)
        local diff = math.min(ply:GetMaxArmor() - ply:Armor(), math.floor(self:GetCharge() * self.ChargeRatio))
        ply:SetArmor(math.min(ply:GetMaxArmor(), ply:Armor() + diff))
        self:SetCharge(self:GetCharge() - diff / self.ChargeRatio)
        self:EmitSound("items/battery_pickup.wav", 80, 90)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)

        for i = 1, math.floor(self:GetCharge() * self.ChargeRatio / 15) do
            local ent = ents.Create("item_battery")
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