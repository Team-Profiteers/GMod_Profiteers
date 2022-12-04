AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Supply Warp"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/monitor01a.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 400

ENT.PreferredAngle = Angle(0, 180, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 12)

ENT.Category = "Profiteers"
ENT.Spawnable = false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 5 + self:GetForward() * 12.5 + self:GetRight() * 0

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -85)

        cam.Start3D2D(pos, ang, 0.03)
            GAMEMODE:ShadowText(self.PrintName, "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(self:WithinBeacon() and "Active" or "Not Active - Place Near Beacon", "CGHUD_5", 0, 60, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end