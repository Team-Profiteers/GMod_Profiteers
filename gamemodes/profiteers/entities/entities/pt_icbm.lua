AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "pt_missile"
ENT.PrintName 			= "ICBM"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/props_phx/rocket1.mdl"

ENT.BoxSize = Vector(1, 1, 1)

ENT.Drag = false
ENT.Gravity = true
ENT.Damping = false
ENT.Boost = 2500
ENT.BoostTarget = 2500
ENT.Lift = 0
ENT.DragCoefficient = 0
ENT.AngleDragCoefficient = 0
ENT.Inertia = Vector(0, 0, 0)

ENT.Damage = 100
ENT.Radius = 256
ENT.ImpactDamage = 0

ENT.LifeTime = 5
ENT.BoostTime = 5

ENT.TopAttack = true
ENT.TopAttackHeight = 10000
ENT.TopAttackDistance = 1000

ENT.SuperSteerBoostTime = 2.5

ENT.FireAndForget = true
ENT.AirAssetWeight = 10000

ENT.Flare = true
ENT.SmokeTrail = true
ENT.SmokeTrailSize = 64
ENT.SmokeTrailTime = 10
ENT.BoostEffectSize = 5

ENT.SuperSeeker = true

ENT.IsProjectile = false

DEFINE_BASECLASS(ENT.Base)

if SERVER then
    function ENT:Initialize()
        local pb_vert = self.BoxSize[1]
        local pb_hor = self.BoxSize[2]
        self:SetModel(self.Model)
        self:PhysicsInitBox( Vector(-pb_vert,-pb_hor,-pb_hor), Vector(pb_vert,pb_hor,pb_hor) )

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableDrag(self.Drag)
            phys:SetDragCoefficient(self.DragCoefficient)
            if !self.Damping then phys:SetDamping(0, 0) end
            if self.Inertia then phys:SetInertia(self.Inertia) end
            if self.AngleDragCoefficient then
                phys:SetAngleDragCoefficient(self.AngleDragCoefficient)
            end
            phys:EnableGravity(self.Gravity)
            phys:SetMass(5)
            phys:SetBuoyancyRatio(0.4)
        end

        self.SpawnTime = CurTime()

        if self.SmokeTrail then
            util.SpriteTrail(self, 0, Color(150, 150, 150, 150), false, self.SmokeTrailSize, 0, self.SmokeTrailTime, 1 / self.SmokeTrailSize * 0.5, "trails/smoke")
        end

        Profiteers.ActiveNuke = self
        Profiteers:SyncNuke(true)

        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Right(), -90)
        self:SetAngles(ang)
    end

    function ENT:OnTakeDamage(damage)
        if self.Defused then return end
        self:Remove()
        return 1
    end

    function ENT:Think()
        if self.Defused then return end

        self:GetPhysicsObject():AddVelocity(self:GetUp() * (self.Boost or 0))
    end

    function ENT:PhysicsCollide(colData, physobj)
        if !self:IsValid() then return end

        self:Detonate()
    end

    function ENT:Detonate()
        if self.Defused then return end
        self.Defused = true

        local nuke = ents.Create("pt_nukeexplosion")
        nuke:SetPos(self:GetPos())
        nuke:SetOwner(self:GetOwner())
        nuke:Spawn()
        nuke:Activate()

        Profiteers:SetGameOver()

        timer.Simple(15, function()
            if MapVote then
                MapVote.Start(60, true, 20, "")
            else
                game.CleanUpMap()
                for _, ply in pairs(player.GetAll()) do
                    ply:Spawn()
                end
            end
        end)

        self:Remove()
    end
end

function ENT:Defuse()
    self.Defused = true
    SafeRemoveEntityDelayed(self, 5)
end

local flaremat = Material("effects/arc9_lensflare")
function ENT:Draw()
    self.SpawnTime = self.SpawnTime or CurTime()

    self:DrawModel()

    if self.Flare and !self.Defused then
        render.SetMaterial(flaremat)
        render.DrawSprite(self:GetPos(), math.Rand(90, 110), math.Rand(90, 110), Color(255, 250, 240))
    end

    if (self.Boost or 0) > 0 and self.BoostTime + self.SpawnTime > CurTime() and (self.Tick or 0) % 3 == 0 then
        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetAngles(self:GetAngles())
        eff:SetEntity(self)
        eff:SetScale(self.BoostEffectSize)
        util.Effect("MuzzleEffect", eff)
    end
end