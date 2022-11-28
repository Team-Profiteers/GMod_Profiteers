AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Nanite Booster"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_wasteland/laundry_washer003.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 1500

ENT.PreferredAngle = Angle(0, 90, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 24)

ENT.Category = "Profiteers"
ENT.Spawnable = false

if SERVER then
    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/manhack/gib.wav", 120, 110, 0.8)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 0 + self:GetForward() * 0 + self:GetRight() * -24

        ang:RotateAroundAxis(self:GetUp(), 180)
        ang:RotateAroundAxis(self:GetForward(), -90)

        cam.Start3D2D(pos, ang, 0.1)
            GAMEMODE:ShadowText("Nanite Booster", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(self:WithinBeacon() and "Active" or "Not Active - Place Near Beacon", "CGHUD_5", 0, 60, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end