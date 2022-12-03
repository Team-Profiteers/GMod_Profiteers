AddCSLuaFile()

ENT.Base = "pt_base_sentry"

ENT.PrintName = "Briefcase Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/ace/minisentry.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 150

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AnchorOffset = Vector(0, 0, 1)
ENT.AllowUnAnchor = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Range = 2048
ENT.Damage = 18
ENT.MagSize = 100

ENT.PitchMin = -15
ENT.PitchMax = 30

if SERVER then

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target)  then return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 0.3
            return
        end
        self.NextFire = CurTime() + 0.1

        local bullet = {
            Attacker = self:CPPIGetOwner(),
            Inflictor = self,
            Damage = self.Damage,
            Force = 1,
            Num = 1,
            Dir = self:LocalToWorldAngles(self:GetAimAngle()):Forward(),
            Src = self:GetPos() + Vector(0, 0, 32),
            Tracer = 1,
            HullSize = 0,
            Spread = Vector(0.04, 0.04, 0.01)
        }

        self:FireBullets(bullet)
        self:EmitSound("^weapons/pistol/pistol_fire3.wav", 125, 150, 0.85)
        self:SetAmmo(self:GetAmmo() - 1)

        local attpos = self:GetAttachment(1)

        local ang = attpos.Ang

        ang:RotateAroundAxis(ang:Right(), 90)

        --[[]
        local muzzle = EffectData()
        muzzle:SetOrigin(attpos.Pos)
        muzzle:SetAngles(ang)
        muzzle:SetEntity(self)
        muzzle:SetAttachment(1)
        muzzle:SetScale(2)
        util.Effect("MuzzleEffect", muzzle)
        ]]
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

            local pos = bonepos + boneang:Up() * 6.3 + boneang:Forward() * -2.2 + boneang:Right() * -2.7

            boneang:RotateAroundAxis(boneang:Forward(), -90)
            boneang:RotateAroundAxis(boneang:Up(), 180)

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