AddCSLuaFile()

ENT.Base = "pt_base_sentry"

ENT.PrintName = "Rocket Battery"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/drgordon/black_ops_2/equipment/weapons/rim-116_rolling_airframe_missile_launcher.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 1500
ENT.NotVulnerableProp = true

ENT.PreferredAngle = Angle(0, -90, 0)
ENT.AnchorRequiresBeacon = true
ENT.AnchorOffset = Vector(0, 0, -4)
ENT.AllowUnAnchor = false

ENT.AnchorSpikeSize = 200
ENT.Mass = 200

ENT.MinRange = 512
ENT.Range = 15000
ENT.TopAttackRange = 5000
ENT.Damage = 100
ENT.TopAttackDamage = 50
ENT.TopAttackImpactDamage = 25
ENT.MagSize = 100

ENT.TurnRate = 180
ENT.TurnRatePitch = 90
ENT.PitchMin = -30
ENT.PitchMax = 75

ENT.LastBurstTime = 0

ENT.LaunchVelocity = 5000

ENT.UseTopAttackLogic = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Angle", 0, "AimAngle")
    self:NetworkVar("Float", 0, "LockonTime")

    self:SetAimAngle(Angle(0, 0, 0))
end

function ENT:CanFunction()
    return self:WithinBeacon() and self:GetAnchored() and self:WaterLevel() == 0
end

function ENT:GetSentryOrigin()
    return self:GetPos() + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 96 + Vector(0, 0, 128)
end

function ENT:GetLOSOrigin()
    return self:GetPos() + Vector(0, 0, 128)
end

function ENT:HasLineOfSight(ent)
    local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
    local filter = {self}
    table.Add(filter, ents.FindByClass("pt_missile_barrage"))
    local tr = util.TraceHull({
        start = self:GetLOSOrigin(),
        endpos = pos,
        filter = filter,
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 32),
        mask = MASK_SHOT,
    })
    return tr.Entity == ent
end

if SERVER then
    ENT.Target = nil
    ENT.TriedTopAttack = {}

    -- local function simulate_projectile(pos, vel)
    --     local p = Vector(pos)
    --     local v = Vector(vel) * 1
    --     local interval = 0.1
    --     for i = 1, 30 do
    --         debugoverlay.Cross(p, 4, 10, Color(255, 255, 0), true)
    --         debugoverlay.Line(p, p + v * interval, 10, Color(255, 255, 0), true)
    --         p = p + v * interval
    --         v = v + physenv.GetGravity() * interval
    --     end
    -- end

    function ENT:TargetLogic()
        if (self.NextFire or 0) > CurTime() and self.UseTopAttackLogic then return end

        local targetang
        local origin = self:GetSentryOrigin()

        local oldtgt = self.Target
        self:FindTarget()
        if oldtgt ~= self.Target then
            self:SetLockonTime(0)
            self.SalvoLeft = self.UseTopAttackLogic and 3 or math.random(3, 5)
        end

        local pitch = -60

        if IsValid(self.Target) then
            local tgtpos = self.Target:GetPos() + Vector(0, 0, 16)

            if self.UseTopAttackLogic then
                targetang = self:WorldToLocalAngles((tgtpos - self:GetSentryOrigin()):Angle())
                targetang.p = pitch
            else
                origin = self:GetSentryOrigin()
                local mypos2d = self:GetSentryOrigin()
                local tgtpos2d = Vector(tgtpos)
                mypos2d.z = 0
                tgtpos2d.z = 0

                local d = mypos2d:Distance(tgtpos2d)
                local h = self.Target:GetPos().z - origin.z

                --self.LaunchVelocity = Lerp(dist / self.Range, 2000, 6000)
                local deg = GAMEMODE:CalculateProjectilePitch(self.LaunchVelocity * 0.75, d, h)

                if deg == 0 / 0 or h >= 300 then self.UseTopAttackLogic = true return end

                targetang = self:WorldToLocalAngles((tgtpos - origin):Angle())
                targetang.p = -deg
            end
        elseif self.LastBurstTime + 5 < CurTime() then
            targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
        else
            targetang = self:GetAimAngle()
        end

        self:RotateTowards(targetang)

        local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
        if self.UseTopAttackLogic then
            local a = targetang:Forward()
            a.z = 0
            local b = self:GetAimAngle():Forward()
            b.z = 0
            dot = a:GetNormalized():Dot(b:GetNormalized())
        end
        if IsValid(self.Target) and dot >= 0.95 then
            if self:GetLockonTime() == 0 then
                self:SetLockonTime(CurTime() + (self.UseTopAttackLogic and 0.75 or 2))
                if self.UseTopAttackLogic then
                    self:EmitSound("ambient/alarms/klaxon1.wav", 130, 110)
                else
                    self:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav", 130, 90)
                end
            elseif self:GetLockonTime() < CurTime() and dot >= 0.995 then
                self:ShootTarget()
            end
        end
    end

    function ENT:WrangleLogic()
        local owner = self:CPPIGetOwner()
        local tr = owner:GetEyeTrace()
        local targetang = self:WorldToLocalAngles((tr.HitPos - self:GetLOSOrigin()):Angle())

        local mypos2d = self:GetLOSOrigin()
        local tgtpos2d = Vector(tr.HitPos)
        mypos2d.z = 0
        tgtpos2d.z = 0

        local d = mypos2d:Distance(tgtpos2d)
        local h = tr.HitPos.z - self:GetLOSOrigin().z

        local deg = GAMEMODE:CalculateProjectilePitch(self.LaunchVelocity * 0.75, d, h)

        -- Got a crash here when firing rocket with an invalid angle. Dunno if this fixes it for sure or not.
        targetang = self:WorldToLocalAngles((tr.HitPos - self:GetLOSOrigin()):Angle())
        if deg ~= 0 / 0 and self:GetAimAngle().p ~= 0 / 0 and self:GetAimAngle().y ~= 0 / 0 then
            targetang.p = -deg
        end

        self:RotateTowards(targetang)

        if owner:KeyDown(IN_ATTACK2) then
            self:ShootTarget(true)
        end

        self.UseTopAttackLogic = false
        self.Target = nil
    end

    function ENT:CanIndirectFire(ent)
        local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
        local tr = util.TraceLine({
            start = self:GetLOSOrigin(),
            endpos = self:GetLOSOrigin() + Vector(0, 0, 400),
            filter = self,
            mask = MASK_SOLID,
        })
        debugoverlay.Line(tr.StartPos, tr.HitPos, 0.5, tr.Hit and Color(255, 0, 0) or color_white)
        if tr.Hit then return false end
        local tr3 = util.TraceLine({
            start = tr.HitPos,
            endpos = pos + Vector(0, 0, 1800),
            mask = MASK_SOLID,
        })
        debugoverlay.Line(tr3.StartPos, tr3.HitPos, 0.5, tr3.Fraction < 1 and Color(255, 0, 0) or color_white)
        if tr3.Fraction < 1 then return false end
        local tr2 = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, 1800),
            filter = ent,
            mask = MASK_SOLID,
        })
        debugoverlay.Line(tr2.StartPos, tr2.HitPos, 0.5, tr2.Hit and Color(255, 0, 0) or color_white)
        if tr2.Hit then return false end

        return true
    end

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target) then return end
        if (self.NextFire or 0) > CurTime() then return end
        if !force and (IsValid(self.Target.RocketFiredAt) and !self.Target.RocketFiredAt.Dead) and self.UseTopAttackLogic then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 1
            return
        end

        self.NextFire = CurTime() + (self.UseTopAttackLogic and 0.15 or 0.2)

        self.LastBurstTime = CurTime()

        local targetang = self:LocalToWorldAngles(self:GetAimAngle())

        local rocket
        if self.UseTopAttackLogic then
            rocket = ents.Create("pt_missile")
            rocket:SetPos(self:GetSentryOrigin())
            rocket.ShootEntData.Target = self.Target
            rocket.FireAndForget = true
            rocket.TopAttack = true
            rocket.TopAttackHeight = 2000
            rocket.TopAttackDistance = 500
            rocket.ImpactDamage = self.TopAttackImpactDamage
            rocket.Damage = self.TopAttackDamage
            rocket.Radius = 128
            rocket.SteerSpeed = 4000
            rocket.Boost = 1000
            rocket.SuperSeeker = false
            rocket.SuperSteerBoostTime = 5
            rocket.NoReacquire = true
            rocket.DragCoefficient = 0
            local ang = Angle(targetang)
            ang:RotateAroundAxis(targetang:Right(), math.Rand(-5, 5))
            ang:RotateAroundAxis(targetang:Up(), math.Rand(-5, 5))
            rocket:SetAngles(ang)
            rocket:Spawn()

            rocket:GetPhysicsObject():SetVelocityInstantaneous(ang:Forward() * self.LaunchVelocity * 1)

            self:EmitSound("npc/waste_scanner/grenade_fire.wav", 140, 120, 0.85)
        else
            rocket = ents.Create("pt_missile_barrage")
            rocket:SetPos(self:GetSentryOrigin())
            local ang = Angle(targetang)
            ang:RotateAroundAxis(targetang:Right(), math.Rand(-0.5, 0.5))
            ang:RotateAroundAxis(targetang:Up(), math.Rand(-2, 2))
            rocket:SetAngles(ang)
            rocket:Spawn()
            rocket.Damage = self.Damage
            rocket.ImpactDamage = self.Damage
            rocket:GetPhysicsObject():SetVelocityInstantaneous(ang:Forward() * self.LaunchVelocity * 1)

            if !force then
                debugoverlay.Sphere(self.Target:GetPos(), 64, 5, Color(255, 255, 255, 0), true)
            end
            debugoverlay.Line(self:GetSentryOrigin(), self:GetSentryOrigin() + targetang:Forward() * 1024, 5, Color(255, 0, 0), true)

            -- simulate_projectile(self:GetSentryOrigin(), ang:Forward() * self.LaunchVelocity)

            self:EmitSound("weapons/stinger_fire1.wav", 140, 85, 0.85)
        end

        rocket.Inflictor = self
        rocket.Owner = self:CPPIGetOwner()
        rocket:SetOwner(self:CPPIGetOwner())

        if force then
            self.SalvoLeft = math.random(3, 5)
        else
            self.SalvoLeft = (self.SalvoLeft or 1) - 1
            if self.SalvoLeft <= 0 then
                self.NextFire = CurTime() + 3
                if self.UseTopAttackLogic then
                    self.Target.RocketFiredAt = rocket
                    self.TriedTopAttack[self.Target] = true
                    self.Target = nil
                else
                    self.SalvoLeft = math.random(4, 8) -- better be fucking dead this time
                end
            end
        end

        self:SetAmmo(self:GetAmmo() - 1)
    end


    function ENT:IsTargetLockable(v, current)
        if !IsValid(v) then return false end

        if self:IsFriendly(v) then return false end

        local rangedelta = v:IsPlayer() and 0.5 or 1

        if self:TestPVS(v)
            or v:GetPos():DistToSqr(self:GetLOSOrigin()) > self.Range * self.Range * rangedelta
            or v:GetPos():DistToSqr(self:GetLOSOrigin()) <= self.MinRange * self.MinRange
            or !v:IsValidCombatTarget() then return false end

        if self.UseTopAttackLogic and !isbool(v.MissileAlreadyFired) and IsValid(v.MissileAlreadyFired) then return false end

        if !self.UseTopAttackLogic and !self:HasLineOfSight(v) then
            return false, v:GetPos():DistToSqr(self:GetLOSOrigin()) < self.TopAttackRange * self.TopAttackRange * rangedelta and self:CanIndirectFire(v)
        end

        return true
    end

    function ENT:FindTarget()

        if (self.NextFindTarget or 0) > CurTime() then return end
        self.NextFindTarget = CurTime() + 0.25

        local target = self.Target

        local direct, indirect = self:IsTargetLockable(target, true)

        if !IsValid(target) or (!self.UseTopAttackLogic and !direct) or (self.UseTopAttackLogic and !indirect) then
            self.UseTopAttackLogic = false
            self.Target = nil
            local indirect_target = nil
            for _, v in pairs(ents.GetAll()) do
                local d, id = self:IsTargetLockable(v, false)

                if !indirect_target and id then
                    indirect_target = v
                elseif d then
                    self.Target = v
                    self.UseTopAttackLogic = false
                    return
                end
            end
            self.Target = indirect_target
            self.UseTopAttackLogic = true
            return
        end
    end

    hook.Add("PostEntityTakeDamage", "Profiteers_RocketBattery", function(ent, dmginfo)
        if IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "pt_sentry_rocket" then
            dmginfo:GetInflictor().TriedTopAttack[ent] = false -- If we hit them once, we can hit them again!
        end
    end)
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local bone = self:LookupBone("pivot")
        local bone2 = self:LookupBone("elevation")

        if bone and bone2 then
            local bonepos, boneang = self:GetBonePosition(bone2)
            self.AimAngYaw = LerpAngle(FrameTime() * 3, self.AimAngYaw or Angle(0, 0, 0), Angle(0, self:GetAimAngle().y - 90, 0))
            self:ManipulateBoneAngles(bone, self.AimAngYaw, false)
            self.AimAngPitch = LerpAngle(FrameTime() * 3, self.AimAngPitch or Angle(0, 0, 0), Angle(self:GetAimAngle().p, 0, 0))
            self:ManipulateBoneAngles(bone2, self.AimAngPitch, false)

            local pos = bonepos + boneang:Up() * 30 + boneang:Forward() * -72 + boneang:Right() * 0

            boneang:RotateAroundAxis(boneang:Forward(), 90)
            boneang:RotateAroundAxis(boneang:Right(), 90)

            cam.Start3D2D(pos, boneang, 0.05)
                if self:CanFunction() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_2", 0, 0, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                GAMEMODE:ShadowText(tostring(self:GetAmmo()) .. "/" .. self.MagSize, "CGHUD_2", 0, 60, self:GetAmmo() > 0 and Color(150, 255, 150) or Color(255, 150, 150), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end