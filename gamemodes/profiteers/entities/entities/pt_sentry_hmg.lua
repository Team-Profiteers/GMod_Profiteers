AddCSLuaFile()

ENT.Base = "pt_base_sentry"

ENT.PrintName = "HMG Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/ace/sentry.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 750

ENT.PreferredAngle = Angle(0, -90, 0)
ENT.AnchorRequiresBeacon = true
ENT.AnchorOffset = Vector(0, 0, 1)
ENT.AllowUnAnchor = true

ENT.Mass = 125

ENT.Range = 4096
ENT.Damage = 30
ENT.MagSize = 200

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Angle", 0, "AimAngle")
    self:NetworkVar("Float", 0, "LockonTime")

    self:SetAimAngle(Angle(0, 0, 0))
end

if SERVER then
    ENT.Target = nil

    function ENT:ShootTarget(force)
        if !force and !IsValid(self.Target) then return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 0.3
            return
        end
        self.NextFire = CurTime() + 0.12

        local bullet = {
            Attacker = self:CPPIGetOwner(),
            Inflictor = self,
            Damage = self.Damage,
            Force = 1,
            Num = 1,
            Dir = self:LocalToWorldAngles(self:GetAimAngle()):Forward(),
            Src = self:GetPos() + Vector(0, 0, 48),
            Tracer = 1,
            HullSize = 0,
            Spread = Vector(0.02, 0.02, 0.01)
        }

        self:FireBullets(bullet)
        self:EmitSound("weapons/m249/m249-1.wav", 130, 95, 0.7, CHAN_WEAPON)
        self:SetAmmo(self:GetAmmo() - 1)

        local attpos = self:GetAttachment(1)

        local ang = attpos.Ang

        ang:RotateAroundAxis(ang:Right(), 90)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local bone = self:LookupBone("gun")

        if bone then
            local bonepos, boneang = self:GetBonePosition(bone)
            self.AimAngYaw = LerpAngle(FrameTime() * 3, self.AimAngYaw or Angle(0, 0, 0), Angle(self:GetAimAngle().p, self:GetAimAngle().y - 90, 0))
            self:ManipulateBoneAngles(bone, self.AimAngYaw, false)

            local pos = bonepos + boneang:Up() * 13 + boneang:Forward() * -12 + boneang:Right() * 2

            boneang:RotateAroundAxis(boneang:Forward(), 90)
            boneang:RotateAroundAxis(boneang:Up(), 0)

            cam.Start3D2D(pos, boneang, 0.05)
                if self:CanFunction() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_5", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_5", 0, 0, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                GAMEMODE:ShadowText(tostring(self:GetAmmo()) .. "/" .. self.MagSize, "CGHUD_7", 0, 30, self:GetAmmo() > 0 and Color(150, 255, 150) or Color(255, 150, 150), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end