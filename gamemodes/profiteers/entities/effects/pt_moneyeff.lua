EFFECT.Model = "models/props/cs_assault/Money.mdl"
EFFECT.Type = 1
EFFECT.LifeTime = 5
EFFECT.SpawnTime = 0

function EFFECT:Init(data)

    self:SetModel(self.Model)
    self:DrawShadow(true)
    self:SetPos(data:GetOrigin())
    self:SetAngles(AngleRand())

    self:PhysicsInitBox(Vector(-1, -1, -0.05), Vector(1, 1, 0.05))
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = self:GetPhysicsObject()
    phys:Wake()
    phys:SetDamping(0, 0)
    phys:SetMass(1)
    phys:SetMaterial("gmod_silent")

    phys:SetVelocity(data:GetNormal() * data:GetMagnitude())
    phys:AddAngleVelocity(VectorRand() * data:GetScale())

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide()
    self:StopSound("Default.ImpactHard")
end

function EFFECT:Think()
    if self:GetVelocity():Length() > 20 then self.SpawnTime = CurTime() end
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
