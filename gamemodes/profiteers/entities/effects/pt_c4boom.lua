// Big explosion effect

function EFFECT:Init(data)
    local emitter = ParticleEmitter(data:GetOrigin())
    if not IsValid(emitter) then return end
    for i = 1, 20 do
        local smoke = emitter:Add("particle/smokestack", data:GetOrigin())
        smoke:SetVelocity(VectorRand() * 5000)
        smoke:SetGravity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), 100))
        smoke:SetDieTime(math.Rand(3, 5))
        smoke:SetStartAlpha(80)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(math.Rand(100, 200))
        smoke:SetEndSize(1000)
        smoke:SetRoll(math.Rand(-180, 180))
        smoke:SetRollDelta(math.Rand(-0.5, 0.5))
        smoke:SetColor(100, 100, 100)
        smoke:SetAirResistance(500)
        smoke:SetPos(self:GetPos())
        smoke:SetLighting(false)
        smoke:SetBounce(0.5)
        smoke:SetCollide(false)
    end

    for i = 1, 10 do
        local smoke = emitter:Add("particle/smokestack", data:GetOrigin())
        smoke:SetVelocity(VectorRand() * 800)
        smoke:SetGravity(Vector(math.Rand(-25, 25), math.Rand(-25, 25), -500))
        smoke:SetDieTime(math.Rand(0.6, 1))
        smoke:SetStartAlpha(120)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(80)
        smoke:SetEndSize(250)
        smoke:SetRoll(math.Rand(-180, 180))
        smoke:SetRollDelta(math.Rand(-0.5, 0.5))
        smoke:SetColor(100, 100, 100)
        smoke:SetAirResistance(300)
        smoke:SetPos(self:GetPos())
        smoke:SetLighting(false)
        smoke:SetBounce(0.5)
        smoke:SetCollide(true)
    end

    for i = 1, 10 do
        local fire = emitter:Add("effects/fire_cloud" .. math.random(1, 2), data:GetOrigin())
        fire:SetVelocity(VectorRand() * 2500 - Vector(0, 0, 100))
        fire:SetGravity(Vector(0, 0, 0))
        fire:SetDieTime(math.Rand(0.5, 0.75))
        fire:SetStartAlpha(255)
        fire:SetEndAlpha(0)
        fire:SetStartSize(math.Rand(15, 30))
        fire:SetEndSize(math.Rand(300, 500))
        fire:SetRoll(math.Rand(-180, 180))
        fire:SetRollDelta(math.Rand(-0.5, 0.5))
        fire:SetColor(200, 200, 200)
        fire:SetAirResistance(300)
        fire:SetPos(self:GetPos())
        fire:SetLighting(false)
        fire:SetBounce(0.5)
        fire:SetCollide(false)
    end

    for i = 1, 20 do
        local fire = emitter:Add("effects/fire_embers" .. math.random(1, 3), data:GetOrigin())
        fire:SetVelocity(VectorRand() * 3000)
        fire:SetGravity(Vector(0, 0, -750))
        fire:SetDieTime(math.Rand(2.5, 3.5))
        fire:SetStartAlpha(200)
        fire:SetEndAlpha(0)
        local embersize = math.Rand(50, 75)
        fire:SetStartSize(embersize)
        fire:SetEndSize(embersize)
        fire:SetRoll(math.Rand(-180, 180))
        fire:SetRollDelta(math.Rand(-0.5, 0.5))
        fire:SetColor(200, 200, 200)
        fire:SetAirResistance(500)
        fire:SetPos(self:GetPos())
        fire:SetLighting(false)
        fire:SetBounce(0.5)
        fire:SetCollide(true)
    end

    for i = 1, math.random(6, 9) do
        local fire = emitter:Add("sprites/glow04_noz", data:GetOrigin())
        fire:SetVelocity(VectorRand() * 100 + Vector(0, 0, math.Rand(300, 800)))
        fire:SetGravity(Vector(0, 0, -400))
        fire:SetDieTime(math.Rand(2, 3))
        fire:SetStartAlpha(200)
        fire:SetEndAlpha(0)
        fire:SetStartSize(math.Rand(3, 5))
        fire:SetEndSize(math.Rand(10, 20))
        fire:SetRoll(math.Rand(-180, 180))
        fire:SetRollDelta(math.Rand(-0.5, 0.5))
        fire:SetColor(255, 180, 100)
        fire:SetAirResistance(2)
        fire:SetPos(self:GetPos())
        fire:SetLighting(false)
        fire:SetBounce(0.2)
        fire:SetCollide(true)
    end
    emitter:Finish()
    self:Remove()
end

function EFFECT:Think()
    return false
end