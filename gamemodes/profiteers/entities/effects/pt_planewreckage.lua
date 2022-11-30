EFFECT.Models = {
    "models/gibs/helicopter_brokenpiece_01.mdl",
    "models/gibs/helicopter_brokenpiece_02.mdl",
    "models/gibs/helicopter_brokenpiece_03.mdl",
    "models/xqm/jettailpiece1large.mdl",
    "models/xqm/jettailpiece1large.mdl",
    "models/xqm/jetwing2sizable.mdl",
    "models/xqm/jetenginepropellerlarge.mdl",
    "models/xqm/cylinderx1large.mdl",
    "models/xqm/jetbody2tailpiecelarge.mdl",
    "models/xqm/jetbody2wingrootblarge.mdl",
    "models/xqm/jetbody2fuselagelarge.mdl"
}
EFFECT.Material = "models/props_pipes/destroyedpipes01a"
EFFECT.LifeTime = 5
EFFECT.SpawnTime = 0
EFFECT.Ticks = 0

function EFFECT:Init(data)

    self:SetModel(self.Models[math.random(1, #self.Models)])
    self:DrawShadow(true)
    self:SetPos(data:GetOrigin())
    self:SetAngles(AngleRand())

    self:PhysicsInitBox(Vector(-50, -50, -50), Vector(50, 50, 50))
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    self:SetMaterial(self.Material)

    local phys = self:GetPhysicsObject()
    phys:Wake()
    phys:SetDamping(0, 0)
    phys:SetMass(1000)
    phys:SetMaterial("gmod_silent")
    phys:SetBuoyancyRatio(1)

    phys:AddAngleVelocity(VectorRand() * 1000)
    phys:SetVelocity(VectorRand() * 10000)

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide()
    self:StopSound("Default.ImpactHard")
end

function EFFECT:Think()
    // Create a trail of smoke and fire

    if self.Ticks % 5 == 0 then
        local emitter = ParticleEmitter(self:GetPos())

        if emitter and IsValid(emitter) then
            local particle = emitter:Add("particles/smokey", self:GetPos())
            particle:SetVelocity(VectorRand() * 100 + self:GetVelocity())
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(20)
            particle:SetEndSize(math.Rand(100, 150))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetColor(50, 50, 50)
            particle:SetGravity(Vector(100, 0, 800) + VectorRand() * 64)
            particle:SetAirResistance(100)

            local fire = emitter:Add("effects/fire_embers" .. math.random(1, 3), self:GetPos())
            fire:SetVelocity(self:GetVelocity())
            fire:SetDieTime(math.Rand(0.1, 0.5))
            fire:SetStartAlpha(255)
            fire:SetEndAlpha(0)
            fire:SetStartSize(25)
            fire:SetEndSize(math.Rand(50, 200))
            fire:SetRoll(math.Rand(0, 360))
            fire:SetRollDelta(math.Rand(-10, 10))
            fire:SetColor(255, 255, 255)
            fire:SetGravity(Vector(0, 0, 0))
            fire:SetAirResistance(0)

            emitter:Finish()
        end
    end

    self.Ticks = self.Ticks + 1

    self:StopSound("Default.ScrapeRough")
    if (self.SpawnTime + self.LifeTime) <= CurTime() then
        if !IsValid(self) then return end
        self:SetRenderFX( kRenderFxFadeFast )
        if (self.SpawnTime + self.LifeTime + 0.25) <= CurTime() then
            if !IsValid(self:GetPhysicsObject()) then return end
            self:GetPhysicsObject():EnableMotion(false)
            if (self.SpawnTime + self.LifeTime + 0.5) <= CurTime() then
                self:Remove()
                return false
            end
        end
    end
    return true
end

function EFFECT:Render()
    if !IsValid(self) then return end
    self:DrawModel()
end

function EFFECT:DrawTranslucent()
    self:DrawModel()
end
