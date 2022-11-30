AddCSLuaFile()

ENT.Base = "pt_base_plane"

ENT.PrintName = "Airdrop Plane"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/c130.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        self.SpawnTime = CurTime()
        self:GetPhysicsObject():SetMass(150)

        self:SetMaxHealth(GetConVar("pt_airdrop_planehealth"):GetInt())
        self:SetHealth(self:GetMaxHealth())

        self.MyAngle = self:GetAngles()
        self:SetOwner(NULL)
        self:SetBodygroup(1, 1)
        self:SetBodygroup(2, 1)
        -- play idle anim
        self:ResetSequence(self:LookupSequence("idle"))
    end

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 5000000)
        self:SetAngles(self.MyAngle)
        self:FrameAdvance(FrameTime())
    end

    function ENT:OnDestroyed(dmginfo)
        local pos = self:GetPos()
        timer.Simple(0.1, function()
            local ent = ents.Create("pt_airdrop")
            ent:SetPos(pos)
            ent:Spawn()
        end)
    end
else
    function ENT:Initialize()
        surface.PlaySound("profiteers/flyby_02.ogg")
        self:SetColor(Color(255, 255, 255, 0))
        self:SetRenderFX(kRenderFxSolidSlow)
    end

    ENT.Ticks = 0

    function ENT:Think()
        -- advance animation sequence
        if self:Health() < (self:GetMaxHealth() * 0.5) and self.Ticks % 5 == 0 then
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