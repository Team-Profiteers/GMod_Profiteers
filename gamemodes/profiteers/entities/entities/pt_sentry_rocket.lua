AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Rocket Sentry"
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

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.MinRange = 512
ENT.Range = 15000
ENT.TopAttackRange = 4096
ENT.Damage = 100
ENT.TopAttackDamage = 40
ENT.MagSize = 100

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

function ENT:GetRocketOrigin()
    return self:GetPos() + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 96 + Vector(0, 0, 128)
end

if SERVER then
    ENT.Target = nil


    local function getpitch(v, d, h)
        local g = -physenv.GetGravity().z
        v = v * 0.8 -- Our physics function doesn't perfectly align at long distances, so just compensate for it a little

        local term = (v ^ 4 - g * (g * d ^ 2 + 2 * h * v ^ 2)) ^ 0.5
        local theta_high = math.atan2(v ^ 2 + term, g * d) / math.pi * 180
        local theta_low = math.atan2(v ^ 2 - term, g * d) / math.pi * 180

        -- print(v, d, h, theta_low, theta_high)

        return theta_low, theta_high
    end

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

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:GetPhysicsObject():SetMass(50)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)
        self:SetAmmo(self.MagSize)
    end

    function ENT:Think()
        if !self:CanFunction() then return end

        local owner = self:CPPIGetOwner()
        local wep = owner:GetActiveWeapon()

        if IsValid(wep) and wep:GetClass() == "pt_wrangler" then
            local tr = owner:GetEyeTrace()

            local targetang = self:WorldToLocalAngles((tr.HitPos - self:GetRocketOrigin()):Angle())

            self.UseTopAttackLogic = false

            self:SetAimAngle(Angle(
                math.ApproachAngle(self:GetAimAngle().p, targetang.p, engine.TickInterval() * 720),
                math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 360), 0))

            if owner:KeyDown(IN_ATTACK2) then
                self:ShootTarget(true)
            end

            self.Target = nil

            self:NextThink(CurTime() + 0.1)
        else
            if (self.NextFire or 0) > CurTime() and self.UseTopAttackLogic then return end

            local oldtgt = self.Target
            self:FindTarget()
            if oldtgt ~= self.Target then
                self:SetLockonTime(0)
                self.SalvoLeft = self.UseTopAttackLogic and 3 or math.random(3, 5)
            end

            local pitch = -45
            local targetang

            if IsValid(self.Target) then
                local tgtpos = self.Target:GetPos() + Vector(0, 0, 16)

                if self.UseTopAttackLogic then
                    targetang = self:WorldToLocalAngles((tgtpos - self:GetRocketOrigin()):Angle())
                    targetang.p = pitch
                else
                    local origin = self:GetRocketOrigin()
                    local mypos2d = self:GetRocketOrigin()
                    local tgtpos2d = Vector(tgtpos)
                    mypos2d.z = 0
                    tgtpos2d.z = 0

                    local d = mypos2d:Distance(tgtpos2d)
                    local h = self.Target:GetPos().z - origin.z

                    --self.LaunchVelocity = Lerp(dist / self.Range, 2000, 6000)
                    local deg = getpitch(self.LaunchVelocity, d, h)

                    if deg == 0 / 0 or h >= 300 then self.UseTopAttackLogic = true return end

                    targetang = self:WorldToLocalAngles((tgtpos - origin):Angle())
                    targetang.p = -deg
                end
            elseif self.LastBurstTime + 5 < CurTime() then
                targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
            else
                targetang = self:GetAimAngle()
            end

            self:SetAimAngle(Angle(
                math.ApproachAngle(self:GetAimAngle().p, targetang.p, engine.TickInterval() * 720),
                math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 360), 0))

            local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
            if self.UseTopAttackLogic then
                local a = targetang:Forward()
                a.z = 0
                local b = self:GetAimAngle():Forward()
                b.z = 0
                dot = a:GetNormalized():Dot(b:GetNormalized())
            end
            if IsValid(self.Target) and dot >= 0.98 then
                if self:GetLockonTime() == 0 then
                    self:SetLockonTime(CurTime() + (self.UseTopAttackLogic and 0.75 or 2))
                    if self.UseTopAttackLogic then
                        self:EmitSound("ambient/alarms/klaxon1.wav", 130, 110)
                    else
                        self:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav", 130, 90)
                    end
                elseif self:GetLockonTime() < CurTime() and dot >= 0.999 then
                    self:ShootTarget()
                end
            end
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end

    function ENT:HasLineOfSight(ent)
        local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 128),
            endpos = pos,
            filter = self,
            mask = MASK_SOLID,
        })
        return tr.Entity == ent or (!IsValid(tr.Entity) and tr.Fraction == 1)
    end

    function ENT:CanIndirectFire(ent)
        local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 128),
            endpos = self:GetPos() + Vector(0, 0, 2500),
            filter = self,
            mask = MASK_SOLID,
        })
        if tr.Hit then return false end
        local tr2 = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, 2500),
            filter = ent,
            mask = MASK_SOLID,
        })
        if tr2.Hit then return false end
        local tr3 = util.TraceLine({
            start = tr.HitPos,
            endpos = tr2.HitPos,
            mask = MASK_SOLID,
        })
        return tr3.Fraction >= 1
    end

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target) then return end
        if (self.NextFire or 0) > CurTime() then return end
        if !force and IsValid(self.Target.RocketFiredAt) and self.UseTopAttackLogic then return end
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
            rocket:SetPos(self:GetRocketOrigin())
            rocket.ShootEntData.Target = self.Target
            rocket.FireAndForget = true
            rocket.TopAttack = true
            rocket.TopAttackHeight = 2000
            rocket.TopAttackDistance = 500
            rocket.ImpactDamage = 0
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
            self:EmitSound("npc/waste_scanner/grenade_fire.wav", 140, 120, 0.85)
        else
            rocket = ents.Create("pt_missile_barrage")
            rocket:SetPos(self:GetRocketOrigin())
            local ang = Angle(targetang)
            ang:RotateAroundAxis(targetang:Right(), math.Rand(-0.5, 0.5))
            ang:RotateAroundAxis(targetang:Up(), math.Rand(-2, 2))
            rocket:SetAngles(ang)
            rocket:Spawn()
            rocket.Damage = self.Damage
            rocket.ImpactDamage = self.Damage
            rocket:GetPhysicsObject():SetVelocityInstantaneous(ang:Forward() * self.LaunchVelocity * 1.1)

            if !force then
                debugoverlay.Sphere(self.Target:GetPos(), 64, 5, Color(255, 255, 255, 0), true)
            end
            debugoverlay.Line(self:GetRocketOrigin(), self:GetRocketOrigin() + targetang:Forward() * 1024, 5, Color(255, 0, 0), true)

            -- simulate_projectile(self:GetRocketOrigin(), ang:Forward() * self.LaunchVelocity)

            self:EmitSound("weapons/stinger_fire1.wav", 140, 85, 0.85)
        end

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
                    self.Target = nil
                else
                    self.SalvoLeft = math.random(4, 8) -- better be fucking dead this time
                end
            end
        end

        self:SetAmmo(self:GetAmmo() - 1)
    end

    function ENT:OnAnchor(ply)
        self:EmitSound("npc/roller/blade_cut.wav", 100, 90)
    end

    function ENT:OnUse(ply)
        if !self:CanFunction() then return end

        if self:GetAmmo() < self.MagSize then
            self:SetAmmo(self.MagSize)
            self:EmitSound("weapons/ar2/npc_ar2_reload.wav")
            ply:ChatPrint("Sentry gun reloaded.")
        end
    end

    function ENT:FindTarget()
        if (self.NextFindTarget or 0) > CurTime() then return end
        self.NextFindTarget = CurTime() + 0.25

        local target = self.Target

        if IsValid(target) then
            if IsValid(target.RocketFiredAt) and self.UseTopAttackLogic then
                self.Target = nil
                return
            end

            local dsq = self:GetPos():DistToSqr(target:GetPos())

            if dsq > self.Range * self.Range then
                self.Target = nil
                return
            end

            if dsq < self.MinRange * self.MinRange then
                self.Target = nil
                return
            end

            if !self.UseTopAttackLogic and !self:HasLineOfSight(target) then
                self.Target = nil
                return
            end

            return
        else
            local targets = ents.FindInSphere(self:GetPos(), self.Range)
            for k, v in pairs(targets) do
                local dsq = self:GetPos():DistToSqr(v:GetPos())
                local indirect = nil
                if dsq > self.Range * self.Range then continue end
                if dsq < self.MinRange * self.MinRange then continue end
                if IsValid(v.RocketFiredAt) then continue end
                if ((v:IsPlayer() and v:Alive() and v ~= self:CPPIGetOwner()) or (v:IsNPC() and v:Health() > 0)) then
                    if self:HasLineOfSight(v) then
                        self.UseTopAttackLogic = false
                        self.Target = v
                        return
                    elseif !indirect and self:CanIndirectFire(v) and dsq <= self.TopAttackRange * self.TopAttackRange then
                        indirect = v
                    end
                end
                if IsValid(indirect) then
                    self.UseTopAttackLogic = true
                    self.Target = indirect
                    return
                end
            end
        end
    end
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

            -- self.AimAngYaw = math.ApproachAngle(self.AimAngYaw or 0, self:GetAimAngle().y, FrameTime() * 1)
            -- self:SetPoseParameter("yaw", self.AimAngYaw)
            -- self.AimAngPitch = math.ApproachAngle(self.AimAngPitch or 0, self:GetAimAngle().p, FrameTime() * 1)
            -- self:SetPoseParameter("pitch", self.AimAngPitch)
            -- self:InvalidateBoneCache()

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