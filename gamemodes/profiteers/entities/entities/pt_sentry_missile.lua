AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Missile Turret"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/bo/weapons/sam turret.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 400

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = true

ENT.AnchorOffset = Vector(0, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Range = 4096
ENT.Damage = 20
ENT.MagSize = 2

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Angle", 0, "AimAngle")
    self:NetworkVar("Float", 0, "LockonTime")

    self:SetAimAngle(Angle(0, 0, 0))
end


if SERVER then
    ENT.Target = nil

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInitBox(Vector(-24, -24, 0), Vector(24, 24, 56))
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:GetPhysicsObject():SetMass(50)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)
        self:SetAmmo(self.MagSize)

        -- self:SetOwner(self:CPPIGetOwner())

        self.NextFire = 0
    end

    function ENT:Think()
        if !self:GetAnchored() then return end
        if !self:WithinBeacon() then return end
        if IsValid(self.LastMissile) then return end
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
            targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 10) * 180, 0)
        end

        self:SetAimAngle(Angle(
            math.ApproachAngle(self:GetAimAngle().p, targetang.p, engine.TickInterval() * 720),
            math.ApproachAngle(self:GetAimAngle().y, targetang.y, engine.TickInterval() * 720), 0))

        debugoverlay.Line(self:GetPos(), self:GetPos() + self:LocalToWorldAngles(self:GetAimAngle()):Forward() * 32, 1, Color(255, 0, 0))

        local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
        if IsValid(self.Target) and dot >= 0.99 then
            if self:GetLockonTime() == 0 then
                if self.Target.IsAirAsset then
                    self:SetLockonTime(CurTime() + math.Rand(0, 0.5))
                else
                    self:SetLockonTime(CurTime() + 2)
                end
                self:EmitSound("buttons/button3.wav", 120, 110)
                self.NextBeep = CurTime() + 0.5
            elseif self:GetLockonTime() < CurTime() then
                self:ShootTarget()
                self.Target = nil
            elseif (self.NextBeep or 0) < CurTime() then
                self.NextBeep = CurTime() + 0.15
                self:EmitSound("buttons/blip1.wav", 120, 100)
            end
        elseif self:GetLockonTime() > 0 and dot <= 0.75 then
            self.Target = nil
            self:SetLockonTime(0)
            self:EmitSound("buttons/combine_button2.wav", 120, 110)
        end
    end

    function ENT:ShootTarget()
        if !IsValid(self.Target) then return end
        if !isbool(self.Target.MissileAlreadyFired) and IsValid(self.Target.MissileAlreadyFired) then self.Target = nil return end
        if (self.NextFire or 0) > CurTime() then return end
        if self:GetAmmo() <= 0 then
            self:EmitSound("weapons/ar2/ar2_empty.wav")
            return
        end
        self.NextFire = CurTime() + 1

        local targetang = self:LocalToWorldAngles(self:GetAimAngle())

        local rocket = ents.Create("arc9_bo1_rocket_stinger")
        rocket:SetPos(self:GetPos() + Vector(0, 0, 32))
        rocket:SetAngles(targetang)
        rocket.ShootEntData.Target = self.Target
        rocket.Airburst = true
        rocket:Spawn()
        rocket.Owner = self:CPPIGetOwner()
        rocket:SetOwner(self:CPPIGetOwner())
        self.LastMissile = rocket

        self.Target.MissileAlreadyFired = rocket

        local phys = rocket:GetPhysicsObject()
        if phys:IsValid() then
            phys:AddVelocity(targetang:Forward() * 1000)
        end

        self:EmitSound("weapons/stinger_fire1.wav", 100, 120)
        self:SetAmmo(self:GetAmmo() - 1)
        --[[]
        local attpos = self:GetAttachment(0)

        local ang = attpos.Ang

        ang:RotateAroundAxis(ang:Right(), 90)

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
        if !self:GetAnchored() then return end

        if self:GetAmmo() < self.MagSize then
            self:SetAmmo(self.MagSize)
            self:EmitSound("weapons/ar2/npc_ar2_reload.wav")
            ply:ChatPrint("Sentry gun reloaded.")
        end
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

    function ENT:FindTarget()

        if (self.NextFindTarget or 0) > CurTime() then return end
        self.NextFindTarget = CurTime() + 0.25

        local target = self.Target

        if IsValid(target) then

            if target.IsAirAsset then
                if !target:Visible(self) then self.Target = nil end
                return
            end

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
            --[[]
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

            if !IsValid(self.Target) then
                for _, v in pairs(ents.GetAll()) do
                    if self:Visible(v) then
                        self.Target = v
                        return
                    end
                end
            end
            ]]
            local r = self.Range * self.Range
            local plane = nil
            for _, v in pairs(ents.GetAll()) do
                if !v.IsAirAsset and !self:TestPVS(v) then continue end
                if !isbool(v.MissileAlreadyFired) and IsValid(v.MissileAlreadyFired) then continue end
                if !(((v:IsPlayer() and v:Alive() and v ~= self:CPPIGetOwner()) or (v:IsNPC() and v:Health() > 0)) and v:GetPos():DistToSqr(self:GetPos()) <= r)
                        and !v.IsAirAsset then continue end
                if self:HasLineOfSight(v) then
                    if !plane and v.IsAirAsset then
                        plane = v -- don't care about distance, just find the first one
                    else
                        self.Target = v
                        return
                    end
                end
            end
            self.Target = bestplane
            return
        end
    end
end

if CLIENT then

    local mat_missile = Material("tdm/missile.png", "mips")

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
                if self:WithinBeacon() and self:GetAnchored() then
                    GAMEMODE:ShadowText("ONLINE", "CGHUD_5", 0, 0, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    GAMEMODE:ShadowText("OFFLINE", "CGHUD_5", 0, 0, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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