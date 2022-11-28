AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Nanite Booster"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_wasteland/gaspump001a.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 1500

ENT.PreferredAngle = Angle(0, 180, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 0)

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
        pos = pos + self:GetUp() * 48 + self:GetForward() * 11 + self:GetRight() * 0

        ang:RotateAroundAxis(self:GetRight(), -90)
        ang:RotateAroundAxis(self:GetForward(), 90)

        cam.Start3D2D(pos, ang, 0.04)
            GAMEMODE:ShadowText("Nanite Booster", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(self:WithinBeacon() and "Active" or "Not Active - Place Near Beacon", "CGHUD_4", 0, 72, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end