AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Sentry Gun"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/ace/minisentry.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 100

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true
ENT.AnchorOffset = Vector(0, 0, 1)
ENT.AllowUnAnchor = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Range = 2048
ENT.Damage = 20
ENT.MagSize = 100

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Ammo")
end


if SERVER then
    ENT.Target = nil

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

        self:SetOwner(self:CPPIGetOwner())
    end

    function ENT:Think()
        if !self:GetAnchored() then return end
        if !self:WithinBeacon() then return end

        self:FindTarget()

        if IsValid(self.Target) then
            self:ShootTarget()
        end

        self:NextThink(CurTime() + 0.1)
    end

    function ENT:ShootTarget()
        if !IsValid(self.Target) then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            return
        end

        local targetang = ((self.Target:EyePos() + Vector(0, 0, -8)) - (self:GetPos() + Vector(0, 0, 8))):Angle()

        local target_yaw = math.NormalizeAngle(targetang.y) - self:GetAngles().y

        self:SetPoseParameter("yaw", target_yaw)

        local target_pitch = math.NormalizeAngle(targetang.p) - self:GetAngles().p

        self:SetPoseParameter("pitch", target_pitch)

        local bullet = {
            Attacker = self:CPPIGetOwner(),
            Inflictor = self,
            Damage = self.Damage,
            Force = 1,
            Num = 1,
            Dir = targetang:Forward(),
            Src = self:GetPos() + Vector(0, 0, 8),
            Tracer = 1,
            HullSize = 0,
            Spread = Vector(0.01, 0.01, 0.01)
        }

        self:FireBullets(bullet)
        self:EmitSound("weapons/pistol/pistol_fire2.wav", 125, 100)
        self:SetAmmo(self:GetAmmo() - 1)

        local attpos = self:GetAttachment(1)

        local ang = attpos.Ang

        ang:RotateAroundAxis(ang:Right(), 90)

        local muzzle = EffectData()
        muzzle:SetOrigin(attpos.Pos)
        muzzle:SetAngles(ang)
        muzzle:SetEntity(self)
        muzzle:SetAttachment(1)
        muzzle:SetScale(2)
        util.Effect("MuzzleEffect", muzzle)
    end

    function ENT:OnAnchor(ply)
        self:EmitSound("npc/roller/blade_cut.wav", 100, 90)
        self:SetOwner(ply)
    end

    function ENT:OnUse(ply)
        if !self:GetAnchored() then return end

        if self:GetAmmo() < self.MagSize then
            self:SetAmmo(self.MagSize)
            self:EmitSound("weapons/ar2/npc_ar2_reload.wav")
            ply:ChatPrint("Sentry gun reloaded.")
        end
    end

    function ENT:FindTarget()
        local target = self.Target

        if IsValid(target) then
            if target:Health() <= 0 then
                self.Target = nil
                return
            end

            if self:GetPos():DistToSqr(target:GetPos()) > self.Range * self.Range then
                self.Target = nil
                return
            end

            if !target:Visible(self) then
                self.Target = nil
                return
            end

            if target:IsPlayer() and target:OwnsBoughtEntity(self) then
                self.Target = nil
                return
            end

            return
        else
            local targets = ents.FindInSphere(self:GetPos(), self.Range)
            for k, v in pairs(targets) do
                if (v:IsPlayer() and v:OwnsBoughtEntity(self)) then continue end
                if (v:IsPlayer() and v:Alive()) or (v:IsNPC() and v:Health() > 0) then
                    if v:Visible(self) then
                        self.Target = v
                        return
                    end
                end
            end
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local bonename = "yaw"

        local bone = self:LookupBone(bonename)

        if bone then
            local bonepos, boneang = self:GetBonePosition(bone)

            local pos = bonepos + boneang:Up() * 6.3 + boneang:Forward() * -2.2 + boneang:Right() * -2.7

            boneang:RotateAroundAxis(boneang:Forward(), -90)
            boneang:RotateAroundAxis(boneang:Up(), 180)

            cam.Start3D2D(pos, boneang, 0.05)
                if self:WithinBeacon() and self:GetAnchored() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_5", 0, 0, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_5", 0, 0, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                GAMEMODE:ShadowText(tostring(self:GetAmmo()) .. "/" .. self.MagSize, "CGHUD_7", 0, 40, self:GetAmmo() > 0 and Color(150, 255, 150) or Color(255, 150, 150), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end