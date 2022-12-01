AddCSLuaFile()

ENT.Base = "pt_base_plane"

ENT.PrintName = "Heavy Bomber"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/bo1_rolling_thunder.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

ENT.BaseHealth = 5000
ENT.FlybySound = true

if SERVER then
    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 20000000)
        self:SetAngles(self.MyAngle)

        // when we get close to the drop pos, drop a bomb

        local selfpos2d = self:GetPos()
        local droppos2d = Vector(self.DropPos)

        selfpos2d.z = 0
        droppos2d.z = 0

        if selfpos2d:Distance(droppos2d) < 500 and not self.BombDropped then
            self.BombDropped = true

            local spot = droppos2d
            spot.z = self:GetPos().z - 256
            local bomb = ents.Create("pt_bomber_bomb")
            bomb:SetPos(spot)
            bomb:SetAngles(self:GetAngles() + Angle(90, 0, 0))
            bomb:SetOwner(self:GetOwner())
            bomb.TargetPos = self.DropPos
            bomb:Spawn()

            if self.Bounty then
                bomb.Bounty = self.Bounty * 0.5
                self.Bounty = self.Bounty - bomb.Bounty
            end

            bomb:SetVelocity(self:GetVelocity())

            self.AirAssetWeight = -1
        end

        self:FrameAdvance(FrameTime())
    end

else
    function ENT:Think()
        if self:Health() < (self:GetMaxHealth() * 0.5) and self.Ticks % 5 == 0  then
            local emitter = ParticleEmitter(self:GetPos())

            local particle = emitter:Add("particles/smokey", self:GetPos() + self:GetForward() * 150 + self:GetRight() * 215 + self:GetUp() * 150)
            particle:SetVelocity(-self:GetForward() * 500 + VectorRand() * 100)
            particle:SetDieTime(math.Rand(2, 2.5))
            particle:SetStartAlpha(100)
            particle:SetEndAlpha(0)
            particle:SetStartSize(32)
            particle:SetEndSize(math.random(100, 200))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetColor(100, 100, 100)
            particle:SetAirResistance(100)
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