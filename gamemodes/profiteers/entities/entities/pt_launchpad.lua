AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Launchpad"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/trains/medium_wheel_2.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 350

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorOffset = Vector(0, 0, -0.2)
ENT.AnchorRequiresBeacon = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.ForceModes = {
    400,
    750,
    1000,
    2500,
    5000
}

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "ForceMode")
end

if SERVER then

    function ENT:OnInitialize()
        self:SetTrigger(true)
    end

    function ENT:OnUse(ply)
        if !(self:GetAnchored() and self:WithinBeacon()) then return end
        self:SetForceMode((self:GetForceMode() + 1) % #self.ForceModes)
        self:EmitSound("buttons/lightswitch2.wav", 70, 95 + 10 * (self:GetForceMode() / #self.ForceModes))
    end

    function ENT:EndTouch(ent)
        if ent:IsPlayer() and !ent:IsOnGround() and self:GetAnchored() and self:WithinBeacon() and (self.NextBoost or 0) < CurTime() then
            ent:SetVelocity(Vector(0, 0, self.ForceModes[self:GetForceMode() + 1]))
            self.NextBoost = CurTime() + 0.1
        end
    end
else
    function ENT:DrawTranslucent()
        self:DrawModel()

        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(LocalPlayer():EyeAngles():Up(), -90)
        ang:RotateAroundAxis(LocalPlayer():EyeAngles():Right(), 90)

        cam.Start3D2D(self:WorldSpaceCenter() + Vector(0, 0, 16), ang, 0.05)
            GAMEMODE:ShadowText("Launchpad", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if self:GetAnchored() then
                GAMEMODE:ShadowText(self:WithinBeacon() and ("Force: " .. (self.ForceModes[self:GetForceMode() + 1] or 0)) or "No Beacon Detected", "CGHUD_5", 0, 75, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                GAMEMODE:ShadowText("Not Anchored", "CGHUD_5", 0, 75, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()
    end
end