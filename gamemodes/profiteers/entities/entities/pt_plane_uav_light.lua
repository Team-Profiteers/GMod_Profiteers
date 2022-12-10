AddCSLuaFile()

ENT.Base = "pt_base_plane"

ENT.PrintName = "Light UAV"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/bo1_u2.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

ENT.BaseHealth = 500
ENT.FlybySound = true
ENT.TailLightPos = Vector(-140, 0, -32)

if SERVER then
    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 2500000)
        self:SetAngles(self.MyAngle)
        self:FrameAdvance(FrameTime())
    end
else
    function ENT:Initialize()

        self:SetColor(Color(255, 255, 255, 0))
        self:SetRenderFX(kRenderFxSolidSlow)
    end
end