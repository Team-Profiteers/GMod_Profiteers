AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "pt_missile"
ENT.PrintName 			= "Cruise Missile"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/props_phx/amraam.mdl"

ENT.Drag = false
ENT.Gravity = true
ENT.Damping = false
ENT.Boost = 20000
ENT.BoostTarget = 40000
ENT.Lift = 0
ENT.DragCoefficient = 0
ENT.AngleDragCoefficient = 0
ENT.Inertia = Vector(0, 0, 0)

ENT.Damage = 100
ENT.Radius = 256
ENT.ImpactDamage = 0

ENT.LifeTime = 30
ENT.BoostTime = 30

ENT.TopAttack = true
ENT.TopAttackHeight = 5000
ENT.TopAttackDistance = 1000

ENT.SuperSteerBoostTime = 2.5

ENT.FireAndForget = true
ENT.AirAssetWeight = 20

ENT.IsProjectile = true

ENT.Flare = true
ENT.SmokeTrail = true
ENT.SmokeTrailSize = 64
ENT.SmokeTrailTime = 10
ENT.BoostEffectSize = 8

ENT.SuperSeeker = true

DEFINE_BASECLASS(ENT.Base)

if SERVER then


    function ENT:Initialize()
        BaseClass.Initialize(self)

        self:SetModelScale(2)
    end

    function ENT:Detonate()
        if self.Detonated then return end
        self.Detonated = true

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("ambient/explosions/explode_4.wav", 125)

        util.BlastDamage(self, self:GetOwner(), self:GetPos(), 1024, 400)

        self.Dead = true
        SafeRemoveEntityDelayed(self, self.SmokeTrailTime)
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end

    function ENT:OnTakeDamage(dmginfo)
        if self.Detonated or self.Dead then return end

        self.Dud = true
        self:Detonate()

        if !self.Paid and self.Bounty and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and (dmginfo:GetAttacker() != self:GetOwner() or GetConVar("pt_dev_airffa"):GetBool()) then
            dmginfo:GetAttacker():AddMoney(self.Bounty * GetConVar("pt_money_airmult"):GetFloat())
            self.Paid = true
        end

        if self.MarkerID then
            Profiteers:KillMarker(self.MarkerID, false)
        end

        return 0
    end
end