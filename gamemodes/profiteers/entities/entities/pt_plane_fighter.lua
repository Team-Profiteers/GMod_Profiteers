AddCSLuaFile()

ENT.Base = "pt_base_plane"

ENT.PrintName = "Fighter"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_mig29.mdl"
ENT.Dropped = false

ENT.BaseHealth = 2000
ENT.FlybySound = true

ENT.NextMissileTime = 0
ENT.LaunchedMissileAt = {}

if SERVER then

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 20000000)
        self:SetAngles(self.MyAngle)
        --local ents = ents.FindInSphere(self:GetPos(), 15000)

        if self.NextMissileTime < CurTime() then
            for k, v in pairs(ents.GetAll()) do
                if v.IsAirAsset and not IsValid(self.LaunchedMissileAt[v]) and v ~= self and (v:GetOwner() ~= self:GetOwner() or GetConVar("pt_dev_airffa"):GetBool()) then
                    self:LaunchMissile(v)
                    break
                end
            end
        end

        self:FrameAdvance(FrameTime())

        self:NextThink(CurTime() + 0.1)
        return true
    end

    function ENT:LaunchMissile(target)
        local targetang = self:GetAngles()
        local rocket = ents.Create("pt_missile")
        rocket:SetPos(self:GetPos() + Vector(0, 0, 32))
        rocket:SetAngles(targetang)
        rocket.ShootEntData.Target = target
        rocket.SteerSpeed = 1500
        rocket.ImpactDamage = 10000
        rocket.Airburst = true
        rocket:Spawn()
        rocket.Owner = self:GetOwner()
        rocket:SetOwner(self:GetOwner())
        self.LaunchedMissileAt[target] = rocket
        self.LaunchedMissileAt[rocket] = rocket -- in FFA test mode fighters will try to shoot rockets at rockets. Funny, but wrong.
        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:AddVelocity(targetang:Forward() * 10000)
        end

        self:EmitSound("weapons/stinger_fire1.wav", 140, 120)
        self.NextMissileTime = CurTime() + 0.6
    end
end