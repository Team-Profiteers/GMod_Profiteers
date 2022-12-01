AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Rocket Sentry"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/drgordon/black_ops_2/equipment/weapons/rim-116_rolling_airframe_missile_launcher.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 1200

ENT.PreferredAngle = Angle(0, -90, 0)
ENT.AnchorRequiresBeacon = false
ENT.AnchorOffset = Vector(0, 0, -4)
ENT.AllowUnAnchor = true

ENT.AnchorSpikeSize = 200

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.MinRange = 2000
ENT.Range = 12000
ENT.Damage = 75
ENT.MagSize = 21

ENT.LastBurstTime = 0

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

    local function estimateRangeFromPitch(p, h)
        local V = 500
        local Vx = V * math.cos(math.rad(p))
        local Vy = V * math.sin(math.rad(p))
        local g = 600

        return Vx * (Vy + math.sqrt(Vy^2 + 2 * g * h)) / g
    end

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

        local oldtgt = self.Target
        self:FindTarget()
        if oldtgt ~= self.Target then
            if self.LastBurstTime + 2.5 < CurTime() then
                self:SetLockonTime(0)

                if !IsValid(oldtgt) then
                    self:EmitSound("npc/turret_floor/active.wav", 120, 110)
                else
                    self:EmitSound("buttons/combine_button1.wav", 120, 110)
                end
            end
        end

        local pitch = -45
        local targetang

        if IsValid(self.Target) then
            local tgtpos = self.Target:GetPos()
            // local h = self.Target:GetPos().z - self:GetPos().z
            // local mypos2d = self:GetPos()
            // local tgtpos2d = self.Target:GetPos()
            // mypos2d.z = 0
            // tgtpos2d.z = 0
            // local dist = mypos2d:Distance(tgtpos2d)
            targetang = self:WorldToLocalAngles((tgtpos - (self:GetPos() + Vector(0, 0, 64))):Angle())

            // local bestrange = estimateRangeFromPitch(45, h)
            // local bestpitch = 45
            // local lastrange = 0
            // local lastpitch = 0

            // // binary search for an optimal pitch
            // for i = 1, 5 do
            //     local newrange
            //     local newpitch
            //     newpitch = (lastpitch + bestpitch) / 2

            //     newrange = estimateRangeFromPitch(newpitch, h)

            //     if math.abs(newrange - dist) < math.abs(bestrange - dist) then
            //         bestpitch = newpitch
            //         bestrange = newrange
            //     end

            //     lastpitch = newpitch
            //     lastrange = newrange
            // end

            // pitch = bestpitch
        elseif self.LastBurstTime + 2.5 < CurTime() then
            targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
        else
            targetang = self:GetAimAngle()
        end

        self:SetAimAngle(Angle(
            math.ApproachAngle(self:GetAimAngle().p, pitch, engine.TickInterval() * 1080),
            math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 1080), 0))

        if IsValid(self.Target) then
            if self:GetLockonTime() == 0 then
                self:SetLockonTime(CurTime() + 1.5)
                self:EmitSound("npc/turret_floor/ping.wav", 120, 100)
            elseif self:GetLockonTime() < CurTime() then
                self:ShootTarget()
            end
        end

        self:NextThink(CurTime() + 0.1)
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
        return tr.Entity == ent or (!IsValid(tr.Entity) and tr.Fraction == 1)
    end

    function ENT:ShootTarget()
        if !IsValid(self.Target) then return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            self.NextFire = CurTime() + 0.5
            return
        end
        self.NextFire = CurTime() + 0.75

        self.LastBurstTime = CurTime()

        local targetang = self:LocalToWorldAngles(self:GetAimAngle())

        local rocket = ents.Create("pt_missile")
        rocket:SetPos(self:GetPos() + Vector(0, 0, 256))
        rocket:SetAngles(targetang)
        rocket.ShootEntData.Target = self.Target
        rocket.TopAttack = true
        rocket.TopAttackHeight = 2000
        rocket.TopAttackDistance = 500
        rocket.ImpactDamage = 0
        rocket.Damage = self.Damage
        rocket.Radius = 256
        rocket.SteerSpeed = 5000
        rocket.Boost = 1500
        rocket.SuperSeeker = false
        rocket.SuperSteerBoostTime = 5
        rocket.NoReacquire = true
        rocket.DragCoefficient = 0
        rocket:Spawn()
        rocket.Owner = self:CPPIGetOwner()
        rocket:SetOwner(self:CPPIGetOwner())

        self.Target.RocketFiredAt = rocket

        self:EmitSound("weapons/stinger_fire1.wav", 140, 85, 0.85)
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
            if IsValid(target.RocketFiredAt) then
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

            if !self:HasLineOfSight(target) then
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
                local dsq = self:GetPos():DistToSqr(v:GetPos())
                if dsq > self.Range * self.Range then continue end
                if dsq < self.MinRange * self.MinRange then continue end
                if IsValid(v.RocketFiredAt) then continue end
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