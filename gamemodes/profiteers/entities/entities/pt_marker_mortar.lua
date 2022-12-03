AddCSLuaFile()

ENT.Base = "pt_marker_base"

ENT.PrintName = "Mortar Smoke"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

if SERVER then
    function ENT:MarkTarget()
        Profiteers:SpawnMortar(self:GetPos(), self:GetOwner())
    end
else
    function ENT:Think()
        // create blue smoke

        local emitter = ParticleEmitter(self:GetPos())

        local particle = emitter:Add("particles/smokey", self:GetPos())
        particle:SetVelocity(VectorRand() * 16 + self:GetUp() * 100)
        particle:SetDieTime(math.Rand(0.5, 1.5))
        particle:SetStartAlpha(100)
        particle:SetEndAlpha(0)
        particle:SetStartSize(0)
        particle:SetEndSize(50)
        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(math.Rand(-1, 1))
        particle:SetColor(255, 150, 75)
        particle:SetGravity(Vector(100, 0, 800) + VectorRand() * 64)
        particle:SetAirResistance(100)

        emitter:Finish()
    end

end