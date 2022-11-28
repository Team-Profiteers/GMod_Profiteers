AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Arsenal"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/Items/ammocrate_smg1.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 500

ENT.PreferredAngle = Angle(0, 180, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 16)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Bounty = 2000

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 12 + self:GetForward() * 16.5 + self:GetRight() * 0

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -90)

        cam.Start3D2D(pos, ang, 0.05)
            GAMEMODE:ShadowText("ARSENAL", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(self:WithinBeacon() and "Active" or "Not Active - Place Near Beacon", "CGHUD_5", 0, 60, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end