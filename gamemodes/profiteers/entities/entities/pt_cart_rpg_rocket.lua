AddCSLuaFile()

ENT.Base = "pt_base_cart"

ENT.PrintName = "Rocket Autolathe"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_wasteland/laundry_washer003.mdl"

ENT.PreferredAngle = Angle(0, 90, 0)

ENT.ChargeRate = 1 / 5
ENT.ThinkDelay = 0.1

ENT.ChargeColor = Color(255, 180, 100, 200)
ENT.ChargeName = "Rockets"

ENT.ChargeRatio = 10

if SERVER then

    function ENT:CanConsume(ply)
        return math.floor(self:GetCharge() * self.ChargeRatio) > 0
    end

    function ENT:OnConsume(ply)
        local amt = math.floor(self:GetCharge() * self.ChargeRatio)
        ply:GiveAmmo(amt, "rpg_round")
        self:SetCharge(self:GetCharge() - amt / self.ChargeRatio)
        self:EmitSound("weapons/357/357_reload1.wav", 80, 92)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)

        for i = 1, math.floor(self:GetCharge() * self.ChargeRatio * math.Rand(0.5, 1)) do
            local ent = ents.Create("item_rpg_round")
            ent:SetPos(self:GetPos() + VectorRand() * 8)
            ent:SetAngles(AngleRand())
            ent:Spawn()
            ent:GetPhysicsObject():ApplyForceCenter(VectorRand() * 256)
            SafeRemoveEntityDelayed(ent, 120)
        end
    end
else
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 10.5 + self:GetForward() * 13.25 + self:GetRight() * -20

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -90)
        ang:RotateAroundAxis(self:GetUp(), 90)

        cam.Start3D2D(pos, ang, 0.02)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(-512, 0, 1024, 256)

            GAMEMODE:ShadowText(self.ChargeName, "CGHUD_2", 0, 60, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(self.ChargeColor:Unpack())
            surface.DrawRect(-500, 128, 1000 * self:GetCharge(), 96, 8)
            if self:WithinBeacon() then
                surface.SetDrawColor(255, 255, 255, 200)
            else
                surface.SetDrawColor(255, 255, (math.sin(SysTime() * 10) * 0.5 + 0.5) * 255, 200)
            end
            surface.DrawOutlinedRect(-500, 128, 1000, 96, 8)
        cam.End3D2D()
    end
end