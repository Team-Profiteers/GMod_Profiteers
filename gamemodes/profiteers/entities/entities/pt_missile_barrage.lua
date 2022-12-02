AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "pt_missile"
ENT.PrintName 			= "Base Projectile"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/weapons/w_missile.mdl"

ENT.Drag = false
ENT.Gravity = true
ENT.Damping = false
ENT.Boost = 0
ENT.BoostTarget = 5000
ENT.Lift = 0
ENT.DragCoefficient = 0
ENT.AngleDragCoefficient = 0
ENT.Inertia = Vector(0, 0, 0)

ENT.Damage = 100
ENT.Radius = 256
ENT.ImpactDamage = 0
ENT.BoostTime = 0

ENT.FireAndForget = false
ENT.AirAssetWeight = -1

DEFINE_BASECLASS(ENT.Base)

if SERVER then
    function ENT:Think()
        BaseClass.Think(self)
        --self:GetPhysicsObject():AddVelocity(Vector(0, 0, 68)) -- ???
    end
end