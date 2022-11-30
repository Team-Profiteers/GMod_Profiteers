AddCSLuaFile()
ENT.PrintName = "UAV"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_mig29.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

ENT.IsAirAsset = true

ENT.NextMissileTime = 0

ENT.LaunchedMissileAt = {}

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        self.SpawnTime = CurTime()
        self:GetPhysicsObject():SetMass(2000)

        self:SetMaxHealth(2000)
        self:SetHealth(self:GetMaxHealth())

        self.MyAngle = self:GetAngles()
        self:ResetSequence(self:LookupSequence("idle"))
    end

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 250000000)
        self:SetAngles(self.MyAngle)

        local ents = ents.FindInSphere(self:GetPos(), 15000)

        if self.NextMissileTime < CurTime() then
            for k, v in pairs(ents) do
                if !IsValid(self.LaunchedMissileAt[v]) and v != self and v.IsAirAsset and v:GetOwner() != self:GetOwner() then
                    self:LaunchMissile(v)
                    break
                end
            end
        end

        self:FrameAdvance(FrameTime())
    end

    function ENT:LaunchMissile(target)
        local targetang = self:GetAngles()

        local rocket = ents.Create("pt_missile")
        rocket:SetPos(self:GetPos() + Vector(0, 0, 32))
        rocket:SetAngles(targetang)
        rocket.ShootEntData.Target = target
        rocket.ImpactDamage = 10000
        rocket:Spawn()
        rocket.Owner = self:GetOwner()
        rocket:SetOwner(self:GetOwner())

        self.LaunchedMissileAt[target] = rocket

        local phys = rocket:GetPhysicsObject()
        if phys:IsValid() then
            phys:AddVelocity(targetang:Forward() * 10000)
        end

        self:EmitSound("weapons/stinger_fire1.wav", 140, 120)

        self.NextMissileTime = CurTime() + 1
    end

    function ENT:PhysicsCollide(colData, collider)
        -- if it hits world make it remove itself
        if colData.HitEntity:IsWorld() then
            self:Remove()
        end
    end

    function ENT:OnTakeDamage(damage)
        if damage:GetDamageType() != DMG_BLAST and damage:GetDamageType() != DMG_AIRBOAT then
            damage:ScaleDamage(0.25)
        end

        self:SetHealth(self:Health() - damage:GetDamage())

        if self:Health() <= 0 and not self.Dropped then
            self.Dropped = true
            self:OnPropDestroyed(damage)
            self:Remove()
        end

        return damage:GetDamage()
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_bigboom", effectdata)

        for i = 1, 5 do
            local effectdata2 = EffectData()
            effectdata2:SetOrigin(self:GetPos())
            util.Effect("pt_planewreckage", effectdata2)
        end
    end
else
    function ENT:Initialize()
        self:SetColor(Color(255, 255, 255, 0))
        self:SetRenderFX(kRenderFxSolidSlow)
    end

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:DrawTranslucent()
        self:DrawModel()
    end

    ENT.Ticks = 0

    function ENT:Think()
        -- advance animation sequence
        if self:Health() < (self:GetMaxHealth() * 0.5) then
            // generate smoke particles

            if self.Ticks % 5 == 0 then
                local emitter = ParticleEmitter(self:GetPos())

                local particle = emitter:Add("particles/smokey", self:GetPos() + self:GetForward() * -100)
                particle:SetVelocity(-self:GetForward() * 500 + VectorRand() * 100)
                particle:SetDieTime(math.Rand(2, 2.5))
                particle:SetStartAlpha(100)
                particle:SetEndAlpha(0)
                particle:SetStartSize(32)
                particle:SetEndSize(math.random(100, 200))
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-1, 1))
                particle:SetColor(100, 100, 100)
                particle:SetAirResistance(10)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetCollide(true)
                particle:SetBounce(0.5)

                emitter:Finish()
            end
        end

        if self.Ticks % 5 == 0 then
            local tr = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() + self:GetForward() * 2000,
                filter = self,
                mask = MASK_NPCWORLDSTATIC
            })

            if tr.Hit and tr.HitWorld then
                self:SetRenderFX(kRenderFxFadeSlow)
            end
        end

        self.Ticks = self.Ticks + 1

        self:FrameAdvance(FrameTime())
    end
end