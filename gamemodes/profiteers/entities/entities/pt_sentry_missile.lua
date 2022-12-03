AddCSLuaFile()

ENT.Base = "pt_base_sentry"

ENT.PrintName = "Missile Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/bo/weapons/sam turret.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 400

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 0)

ENT.Mass = 100
ENT.LockAirAssets = true
ENT.NoRepeatLock = true

ENT.Range = 4096
ENT.Damage = 100
ENT.MagSize = 2

ENT.TurnRate = 180
ENT.TurnRatePitch = 720

ENT.PitchMin = -30
ENT.PitchMax = 90

function ENT:GetSentryOrigin()
    return self:GetPos()  + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 32 + Vector(0, 0, 32)
end

function ENT:GetLOSOrigin()
    return self:WorldSpaceCenter()
end


if SERVER then
    function ENT:TargetLogic()
        if (self.NextFire or 0) > CurTime() then return end
        local oldtgt = self.Target
        self:FindTarget()
        if oldtgt ~= self.Target then
            self:SetLockonTime(0)
            if !IsValid(oldtgt) then
                self:EmitSound("npc/turret_floor/active.wav", 120, 110)
            else
                self:EmitSound("buttons/combine_button1.wav", 120, 110)
            end
        end

        local targetang
        if IsValid(self.Target) then
            local tgtpos = self.Target:EyePos()
            targetang = self:WorldToLocalAngles((tgtpos - (self:GetPos() + Vector(0, 0, 32))):Angle())
        else
            targetang = Angle(-self.PitchMin, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 10) * 180, 0)
        end

        self:RotateTowards(targetang)

        debugoverlay.Line(self:GetPos(), self:GetPos() + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 32, 1, Color(255, 0, 0))

        local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
        if IsValid(self.Target) and dot >= 0.99 then
            if self:GetLockonTime() == 0 then
                if self.Target:IsValidAirAsset(true) then
                    self:SetLockonTime(CurTime() + 0.5)
                else
                    self:SetLockonTime(CurTime() + (self.Target:IsPlayer() and 2 or 1))
                end
                self:EmitSound("buttons/button3.wav", 120, 110)
                self.NextBeep = CurTime() + 0.55
            elseif self:GetLockonTime() < CurTime() then
                self:ShootTarget()
            end
        elseif self:GetLockonTime() > 0 and dot <= 0.5 then
            self.Target = nil
            self:SetLockonTime(0)
            self:EmitSound("buttons/combine_button2.wav", 120, 110)
        end
    end

    function ENT:WrangleLogic()
        local tr = self:CPPIGetOwner():GetEyeTrace()
        local targetang = self:WorldToLocalAngles((tr.HitPos - self:GetLOSOrigin()):Angle())

        self:RotateTowards(targetang)

        if self:CPPIGetOwner():KeyDown(IN_ATTACK2) then
            if tr.Entity and !tr.HitWorld then
                self.Target = tr.Entity
            else
                self.Target = nil
            end
            self:ShootTarget(true)
        end

        self.Target = nil
    end

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target) then return end
        if !force and !isbool(self.Target.MissileAlreadyFired) and IsValid(self.Target.MissileAlreadyFired) then self.Target = nil return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 3
            self.Target = nil
            return
        end
        self.NextFire = CurTime() + 1

        local targetang = self:LocalToWorldAngles(self:GetAimAngle())

        local rocket = ents.Create("pt_missile")
        rocket:SetPos(self:GetPos() + Vector(0, 0, 32))
        rocket:SetAngles(targetang)

        if self.Target then
            rocket.ShootEntData.Target = self.Target
            rocket.Airburst = self.Target:IsValidAirAsset(true)
        else
            rocket.FireAndForget = false
        end

        rocket:Spawn()
        rocket.Owner = self:CPPIGetOwner()
        rocket.Damage = self.Damage
        rocket:SetOwner(self:CPPIGetOwner())

        local phys = rocket:GetPhysicsObject()
        if phys:IsValid() then
            phys:AddVelocity(targetang:Forward() * 1000)
        end

        self:EmitSound("weapons/rpg/rocketfire1.wav", 100, 120)
        self:SetAmmo(self:GetAmmo() - 1)

        if IsValid(self.Target) then
            self.Target.MissileAlreadyFired = rocket
            self.Target = nil
        end
    end
end

if CLIENT then

    local mat_missile = Material("tdm/missile.png", "mips")

    function ENT:Think()
        if self:GetLockonTime() > CurTime() and (self.NextBeep or 0) <= CurTime() then
            self.NextBeep = CurTime() + 0.15
            self:EmitSound("buttons/blip1.wav", 120, 100)
        end
    end

    function ENT:Draw()
        self:DrawModel()

        local bonename = "tag_pivot"

        local bone = self:LookupBone(bonename)

        if bone then
            local bonepos, boneang = self:GetBonePosition(bone)
            self.AimAng = LerpAngle(FrameTime() * 3, self.AimAng or Angle(0, 0, 0), self:GetAimAngle())

            self:ManipulateBoneAngles(bone, self.AimAng, false)

            local pos = bonepos + boneang:Up() * 4 + boneang:Forward() * 6 + boneang:Right() * -13

            boneang:RotateAroundAxis(boneang:Forward(), -90)
            boneang:RotateAroundAxis(boneang:Up(), 180)

            cam.Start3D2D(pos, boneang, 0.05)
                if self:CanFunction() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_5", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_5", 0, 0, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                surface.SetMaterial(mat_missile)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawTexturedRectRotated(-48, 50, 64, 64, 90)
                surface.DrawTexturedRectRotated(48, 50, 64, 64, 90)

                surface.SetDrawColor((self:GetAmmo() > 0 and color_white or Color(255, 150, 150)):Unpack())
                surface.DrawTexturedRectRotated(-48, 50, 64, 64, 90)

                surface.SetDrawColor((self:GetAmmo() > 1 and color_white or Color(255, 150, 150)):Unpack())
                surface.DrawTexturedRectRotated(48, 50, 64, 64, 90)
            cam.End3D2D()
        end
    end
end