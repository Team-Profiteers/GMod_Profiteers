AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Telepad"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/teleplatform.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 2000

ENT.PreferredAngle = Angle(0, 180, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = false
ENT.AnchorOffset = Vector(0, 0, 8)

ENT.Category = "Profiteers"
ENT.Spawnable = false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 16 + self:GetForward() * 50 + self:GetRight() * 0

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -90)

        cam.Start3D2D(pos, ang, 0.05)
            GAMEMODE:ShadowText("Telepad", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if self:GetAnchored() then
                GAMEMODE:ShadowText(self:WithinBeacon() and "Ready" or "No Beacon Detected", "CGHUD_5", 0, 75, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                GAMEMODE:ShadowText("Not Anchored", "CGHUD_5", 0, 75, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()
    end
end