AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Briefcase Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/ace/minisentry.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 100

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AnchorOffset = Vector(0, 0, 1)
ENT.AllowUnAnchor = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Range = 2048
ENT.Damage = 15
ENT.MagSize = 100

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Angle", 0, "AimAngle")
    self:NetworkVar("Float", 0, "LockonTime")

    self:SetAimAngle(Angle(0, 0, 0))
end

function ENT:CanFunction()
    return self:WithinBeacon() and self:GetAngles():Up():Dot(Vector(0, 0, 1)) > 0.6 and self:WaterLevel() == 0
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
    end

    function ENT:Think()
        if !self:CanFunction() then return end

        local owner = self:CPPIGetOwner()
        local wep = owner:GetActiveWeapon()

        if IsValid(wep) and wep:GetClass() == "pt_wrangler" then

            local tr = owner:GetEyeTrace()

            local targetang = self:WorldToLocalAngles((tr.HitPos - self:GetPos()):Angle())

            self:SetAimAngle(Angle(
                math.ApproachAngle(self:GetAimAngle().p, targetang.p, engine.TickInterval() * 1080),
                math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 1080), 0))

            if owner:KeyDown(IN_ATTACK) then
                self:ShootTarget(true)
            end

            self.Target = nil

            self:NextThink(CurTime() + 0.1)
        else
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
                targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
            end

            self:SetAimAngle(Angle(
                math.ApproachAngle(self:GetAimAngle().p, targetang.p, engine.TickInterval() * 1080),
                math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 1080), 0))

            local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
            if IsValid(self.Target) and dot >= 0.99 then
                if self:GetLockonTime() == 0 then
                    self:SetLockonTime(CurTime() + 0.5)
                    self:EmitSound("npc/turret_floor/ping.wav", 120, 100)
                elseif self:GetLockonTime() < CurTime() then
                    self:ShootTarget()
                end
            end

            self:NextThink(CurTime() + 0.1)
        end
        return true
    end

    function ENT:HasLineOfSight(ent)
        local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = pos,
            filter = self,
            mask = MASK_BLOCKLOS_AND_NPCS,
        })
        return tr.Entity == ent or !IsValid(tr.Entity) and tr.Fraction == 1
    end

    function ENT:ShootTarget(force)
        if !force then
            if !IsValid(self.Target) then return end
        end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 0.3
            return
        end
        self.NextFire = CurTime() + 0.1

        -- local targetang = ((self.Target:EyePos() + Vector(0, 0, -8)) - (self:GetPos() + Vector(0, 0, 8))):Angle()
        -- local target_yaw = math.NormalizeAngle(targetang.y) - self:GetAngles().y
        -- self:SetPoseParameter("yaw", target_yaw)
        -- local target_pitch = math.NormalizeAngle(targetang.p) - self:GetAngles().p
        -- self:SetPoseParameter("pitch", target_pitch)


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
            Spread = Vector(0.03, 0.02, 0.01)
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
                if ((v:IsPlayer() and v:Alive() and v ~= self:CPPIGetOwner()) or (v:IsNPC() and v:Health() > 0)) and self:HasLineOfSight(v) then
                    self.Target = v
                    return
                end
            end
        end
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

            -- self.AimAngYaw = math.ApproachAngle(self.AimAngYaw or 0, self:GetAimAngle().y, FrameTime() * 1)
            -- self:SetPoseParameter("yaw", self.AimAngYaw)
            -- self.AimAngPitch = math.ApproachAngle(self.AimAngPitch or 0, self:GetAimAngle().p, FrameTime() * 1)
            -- self:SetPoseParameter("pitch", self.AimAngPitch)
            -- self:InvalidateBoneCache()

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