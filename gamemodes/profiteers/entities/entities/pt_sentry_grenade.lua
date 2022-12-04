AddCSLuaFile()

ENT.Base = "pt_base_sentry"

ENT.PrintName = "Grenade Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/defense/mw3_mk19.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 600

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AnchorOffset = Vector(0, 0, 1)
ENT.AllowUnAnchor = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Mass = 100

ENT.Range = 4096
ENT.Damage = 90
ENT.MagSize = 40

ENT.PitchMin = -10
ENT.PitchMax = 60

ENT.LaunchVelocity = 2500

function ENT:GetSentryOrigin()
    return self:GetPos() + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 48 + Vector(0, 0, 32)
end

function ENT:GetLOSOrigin()
    return self:GetPos() + Vector(0, 0, 32)
end

if SERVER then


    function ENT:TargetLogic()
        if (self.NextFire or 0) > CurTime() and self.UseTopAttackLogic then return end

        local targetang
        local origin = self:GetSentryOrigin()

        local oldtgt = self.Target
        self:FindTarget()
        if oldtgt ~= self.Target then
            self:SetLockonTime(0)
            self.SalvoLeft = 3
        end

        if IsValid(self.Target) then
            local tgtpos = self.Target:GetPos() + Vector(0, 0, 16)
            origin = self:GetSentryOrigin()
            local mypos2d = self:GetSentryOrigin()
            local tgtpos2d = Vector(tgtpos)
            mypos2d.z = 0
            tgtpos2d.z = 0

            local d = mypos2d:Distance(tgtpos2d)
            local h = self.Target:GetPos().z - origin.z

            --self.LaunchVelocity = Lerp(dist / self.Range, 2000, 6000)
            local deg = GAMEMODE:CalculateProjectilePitch(self.LaunchVelocity, d, h)

            if deg == 0 / 0 or h >= 300 then self.UseTopAttackLogic = true return end

            targetang = self:WorldToLocalAngles((tgtpos - origin):Angle())
            targetang.p = -deg
        elseif self.LastBurstTime + 5 < CurTime() then
            targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
        else
            targetang = self:GetAimAngle()
        end

        self:RotateTowards(targetang)

        local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
        if IsValid(self.Target) and dot >= 0.95 then
            if self:GetLockonTime() == 0 then
                self:SetLockonTime(CurTime() + 2)
                self:EmitSound("npc/turret_floor/ping.wav", 120, 92)
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

        local deg = GAMEMODE:CalculateProjectilePitch(self.LaunchVelocity, d, h)

        -- Got a crash here when firing rocket with an invalid angle. Dunno if this fixes it for sure or not.
        targetang = self:WorldToLocalAngles((tr.HitPos - self:GetLOSOrigin()):Angle())
        if deg ~= 0 / 0 and self:GetAimAngle().p ~= 0 / 0 and self:GetAimAngle().y ~= 0 / 0 then
            targetang.p = -deg
        end

        self:RotateTowards(targetang)

        if owner:KeyDown(IN_ATTACK2) then
            self:ShootTarget(true)
        end

        self.Target = nil
    end

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target)  then return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 0.5
            return
        end
        self.NextFire = CurTime() + 0.2
        self.LastBurstTime = CurTime()

        local targetang = self:LocalToWorldAngles(self:GetAimAngle())
        rocket = ents.Create("arc9_bo1_40mm_he") -- TODO replace
        rocket:SetPos(self:GetSentryOrigin())
        local ang = Angle(targetang)
        ang:RotateAroundAxis(targetang:Right(), math.Rand(-3, 1))
        ang:RotateAroundAxis(targetang:Up(), math.Rand(-3, 3))
        rocket:SetAngles(ang)
        rocket:Spawn()
        rocket.Damage = self.Damage
        rocket.ImpactDamage = self.Damage
        rocket:GetPhysicsObject():SetVelocityInstantaneous(ang:Forward() * self.LaunchVelocity * 1.1)

        if !force then
            debugoverlay.Sphere(self.Target:GetPos(), 64, 5, Color(255, 255, 255, 0), true)
        end
        debugoverlay.Line(self:GetSentryOrigin(), self:GetSentryOrigin() + targetang:Forward() * 1024, 5, Color(255, 0, 0), true)


        self:EmitSound("^weapons/pistol/pistol_fire3.wav", 125, 150, 0.85)
        self:SetAmmo(self:GetAmmo() - 1)

        if force then
            self.SalvoLeft = 3
        else
            self.SalvoLeft = (self.SalvoLeft or 1) - 1
            if self.SalvoLeft <= 0 then
                self.NextFire = CurTime() + 3
                self.SalvoLeft = 3
            end
        end

        ang:RotateAroundAxis(ang:Right(), 90)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local bone = self:LookupBone("yaw")
        local bone2 = self:LookupBone("pitch")

        if bone and bone2 then
            local bonepos, boneang = self:GetBonePosition(bone)
            self.AimAngYaw = LerpAngle(FrameTime() * 3, self.AimAngYaw or Angle(0, 0, 0), Angle(self:GetAimAngle().y, 0, 0))
            self:ManipulateBoneAngles(bone, self.AimAngYaw, false)
            self.AimAngPitch = LerpAngle(FrameTime() * 3, self.AimAngPitch or Angle(0, 0, 0), Angle(0, 0, self:GetAimAngle().p))
            self:ManipulateBoneAngles(bone2, self.AimAngPitch, false)

            local pos = bonepos + boneang:Up() * 24 + boneang:Forward() * 0 + boneang:Right() * 0

            boneang:RotateAroundAxis(boneang:Forward(), 0)
            boneang:RotateAroundAxis(boneang:Up(), 0)

            cam.Start3D2D(pos, boneang, 0.05)
                if self:CanFunction() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_5", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_5", 0, 0, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                GAMEMODE:ShadowText(tostring(self:GetAmmo()) .. "/" .. self.MagSize, "CGHUD_7", 0, 40, self:GetAmmo() > 0 and Color(150, 255, 150) or Color(255, 150, 150), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end