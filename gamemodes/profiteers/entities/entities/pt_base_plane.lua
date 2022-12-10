AddCSLuaFile()
ENT.PrintName = "Base Aircraft"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_harrier.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

ENT.IsAirAsset = true
ENT.FlybySound = false
ENT.BaseHealth = 1000

ENT.TailLightPos = Vector(0, 0, 0)

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        self.SpawnTime = CurTime()
        self:GetPhysicsObject():SetMass(150)

        self:SetMaxHealth(self.BaseHealth)
        self:SetHealth(self:GetMaxHealth())

        self.MyAngle = self:GetAngles()
        self:ResetSequence(self:LookupSequence("idle"))
    end

    function ENT:PhysicsCollide(colData, collider)
        -- if it hits world make it remove itself
        if colData.HitEntity:IsWorld() then
            self:Remove()
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        if dmginfo:GetDamageType() != DMG_BLAST and dmginfo:GetDamageType() != DMG_AIRBOAT then
            dmginfo:ScaleDamage(0.25)
        end

        self:SetHealth(self:Health() - dmginfo:GetDamage())

        if self:Health() <= 0 and not self.Dropped then
            self.Dropped = true

            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            util.Effect("pt_bigboom", effectdata)

            for i = 1, 3 do
                local effectdata2 = EffectData()
                effectdata2:SetOrigin(self:GetPos())
                util.Effect("pt_planewreckage", effectdata2)
            end

            if self.Bounty and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and (dmginfo:GetAttacker() != self:GetOwner() or GetConVar("pt_dev_airffa"):GetBool()) then
                dmginfo:GetAttacker():AddMoney(self.Bounty * GetConVar("pt_money_airmult"):GetFloat())
            end

            self:OnDestroyed(dmginfo)
            self:Remove()
        end

        return dmginfo:GetDamage()
    end

    function ENT:OnDestroyed(dmginfo)
    end
else
    function ENT:Initialize()
        self:SetColor(Color(255, 255, 255, 0))
        self:SetRenderFX(kRenderFxSolidSlow)
        if self.FlybySound then
            surface.PlaySound("profiteers/flyby_01.ogg")
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end

    local glowmat = Material("sprites/physg_glow1")

    function ENT:DrawTranslucent()
        self:Draw()

        if (math.sin((CurTime() * 4)) > 0.75) then
            render.SetMaterial(glowmat)

            local pos = self:GetPos() + self:GetForward() * self.TailLightPos.x + self:GetRight() * self.TailLightPos.y + self:GetUp() * self.TailLightPos.z

            if self:IsFriendly(LocalPlayer()) then
                render.DrawSprite(pos, 256, 256, Color(25, 255, 25))
            else
                render.DrawSprite(pos, 256, 256, Color(255, 25, 25))
            end
        end
    end

    ENT.Ticks = 0

    function ENT:Think()
        -- advance animation sequence
        if self:Health() < (self:GetMaxHealth() * 0.5) and self.Ticks % 5 == 0 then
            -- generate smoke particles
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