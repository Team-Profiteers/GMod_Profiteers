AddCSLuaFile()
ENT.PrintName = "Base Smoke"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        local phys = self:GetPhysicsObject()

        phys:SetMass(5)

        self.SpawnTime = CurTime()
    end

    function ENT:Think()
        if self:GetVelocity():Length() > 20 then
            self.SpawnTime = CurTime()
        end

        if self.SpawnTime + 5 < CurTime() or ((self.WeldTime or math.huge) + 2 < CurTime()) then
            self:MarkTarget()
            self:EmitSound("buttons/button19.wav", 120, 110)
            self:Remove()
        end
    end

    function ENT:PhysicsCollide(colData, collider)
        if not self.Welded and (IsValid(colData.HitEntity) or colData.HitNormal:Dot(Vector(0, 0, -1)) >= 0.5) then
            self.Welded = true
            self.WeldTime = CurTime()
            timer.Simple(0, function()
                constraint.Weld(self, colData.HitEntity, 0, 0, 0, true, false)
            end)
        end
    end

    function ENT:OnRemove()
    end

    function ENT:Use(activator)
    end

    function ENT:MarkTarget()
    end

    function ENT:OnTakeDamage(dmginfo)
        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        util.Effect("StunstickImpact", eff)
        self:EmitSound("physics/plastic/plastic_barrel_break2.wav", 100, 105)
        self:Remove()
    end
else
    function ENT:Initialize()
    end

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
        particle:SetColor(100, 100, 255)
        particle:SetGravity(Vector(100, 0, 800) + VectorRand() * 64)
        particle:SetAirResistance(100)

        emitter:Finish()
    end

    function ENT:DrawTranslucent()
        self:DrawModel()
    end
end