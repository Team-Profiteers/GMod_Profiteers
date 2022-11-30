AddCSLuaFile()
ENT.PrintName = "MH-53 'Pave Low'"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_pavelow.mdl"
ENT.Dropped = false

ENT.IsAirAsset = true

ENT.LeavingArea = false

ENT.Rockets = 64

ENT.LaunchedMissileAt = {}
ENT.NextMissileTime = 0

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        self.SpawnTime = CurTime()
        self:GetPhysicsObject():SetMass(150)

        self:SetMaxHealth(5000)
        self:SetHealth(self:GetMaxHealth())

        self:ResetSequence(self:LookupSequence("idle"))

        self.EnterPos = self:GetPos()
    end

    function ENT:Think()
        local targetpos

        if !IsValid(self:GetOwner()) or self.Rockets <= 0 or self.SpawnTime + 120 < CurTime() then
            targetpos = self.EnterPos
            self.LeavingArea = true
        else
            targetpos = self.LoiterPos
        end

        // local tr = util.TraceHull({
        //     start = self:GetPos(),
        //     endpos = targetpos,
        //     filter = self,
        //     mins = Vector(-1400, -1400, -200),
        //     maxs = Vector(1400, 1400, 200),
        //     mask = MASK_SOLID
        // })

        // if tr.Hit then
        //     targetpos = tr.HitPos
        // end

        local dist = (targetpos - self:GetPos()):Length()

        local targetang = (targetpos - self:GetPos()):Angle()
        targetang.p = 0
        targetang.r = 0

        local ang = self:GetAngles()

        local angdiff = math.AngleDifference(ang.y, targetang.y)

        ang.y = math.ApproachAngle(ang.y, targetang.y, FrameTime() * 100 * math.Clamp(angdiff, -100, 100))
        ang.r = 0

        self:SetAngles(ang)

        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)

        if dist > 500 then
            phys:SetVelocity((targetpos - self:GetPos()):GetNormalized() * 1000)
        elseif self.LeavingArea then
            self:Remove()
        end

        if self.Rockets > 0 then
            local ents = ents.FindInSphere(self:GetPos(), 15000)

            local found_tgt = nil

            if self.NextMissileTime < CurTime() then
                for k, v in pairs(ents) do
                    if !IsValid(self.LaunchedMissileAt[v]) and v != self and v != self:GetOwner() and ((v:IsPlayer() and v:Alive() and v:IsOnGround()) or (v:IsNPC() and v:Health() > 0)) and v:Visible(self) then
                        found_tgt = v

                        if v:IsPlayer() then
                            break
                        end
                    end
                end
            end

            if found_tgt then
                self:LaunchMissile(found_tgt)
            end
        end

        self:FrameAdvance(FrameTime())
    end

    function ENT:LaunchMissile(target)
        local targetang = self:GetAngles()

        local rocket = ents.Create("arc9_bo1_rocket_stinger")
        rocket:SetPos(self:GetPos() + self:GetForward() * 250)
        rocket:SetAngles(targetang)
        rocket.ShootEntData.Target = target
        rocket.ImpactDamage = 100
        rocket.SteerSpeed = 1500
        rocket.SeekerAngle = math.cos(math.rad(90))
        rocket.LifeTime = 15
        rocket.Boost = 2500
        rocket:Spawn()
        rocket.Owner = self:GetOwner()
        rocket:SetOwner(self:GetOwner())
        rocket:SetVelocity(targetang:Forward() * 1000000)

        constraint.NoCollide(self, rocket)

        self:EmitSound("weapons/stinger_fire1.wav", 140, 120)

        self.LaunchedMissileAt[target] = rocket
        self.NextMissileTime = CurTime() + 0.5
        self.Rockets = self.Rockets - 1
    end

    function ENT:PhysicsCollide(colData, collider)
        -- if it hits world make it remove itself
        // if colData.HitEntity:IsWorld() then
        //     self:Remove()
        // end
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

        for i = 1, 3 do
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
                particle:SetVelocity(-self:GetForward() * 1500 + VectorRand() * 100)
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

        if self.LeavingArea and self.Ticks % 5 == 0 then
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

        local rotorbone = "main_rotor_jnt"
        local rotorbone2 = "tail_rotor_jnt"

        local rotorboneid = self:LookupBone(rotorbone)
        local rotorboneid2 = self:LookupBone(rotorbone2)

        if rotorboneid and rotorboneid2 then
            self:ManipulateBoneAngles(rotorboneid, Angle(0, math.fmod(CurTime() * 200, 360, 0)))
            self:ManipulateBoneAngles(rotorboneid2, Angle(math.fmod(CurTime() * 200, 360), 0, 0))
        end

        self.Ticks = self.Ticks + 1

        self:FrameAdvance(FrameTime())
    end
end