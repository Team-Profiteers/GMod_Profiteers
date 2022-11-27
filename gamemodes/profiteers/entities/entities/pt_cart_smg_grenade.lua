AddCSLuaFile()

ENT.Base = "pt_base_cart"

ENT.PrintName = "Grenade Autolathe"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/reciever_cart.mdl"

ENT.PreferredAngle = Angle(0, 180, 0)

ENT.ChargeRate = 1 / 120
ENT.ThinkDelay = 0.1

ENT.ChargeColor = Color(255, 255, 25, 200)
ENT.ChargeName = "Rifle Grenades"

ENT.ChargeRatio = 20

if SERVER then

    function ENT:CanConsume(ply)
        return math.floor(self:GetCharge() * self.ChargeRatio) > 0
    end

    function ENT:OnConsume(ply)
        local amt = math.floor(self:GetCharge() * self.ChargeRatio)
        ply:GiveAmmo(amt, "smg1_grenade")
        self:SetCharge(self:GetCharge() - amt / self.ChargeRatio)
        self:EmitSound("weapons/357/357_reload1.wav", 80, 92)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)

        for i = 1, math.floor(self:GetCharge() * self.ChargeRatio * math.Rand(0.5, 1)) do
            local ent = ents.Create("item_ammo_smg1_grenade")
            ent:SetPos(self:GetPos() + VectorRand() * 8)
            ent:SetAngles(AngleRand())
            ent:Spawn()
            ent:GetPhysicsObject():ApplyForceCenter(VectorRand() * 256)
            SafeRemoveEntityDelayed(ent, 120)
        end
    end
end