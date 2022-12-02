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

ENT.ThinkInterval = 0.1
ENT.Mass = 50

ENT.Range = 2048
ENT.Damage = 15
ENT.MagSize = 100
ENT.TurnRate = 360

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

function ENT:HasLineOfSight(ent)
    local pos = (ent:IsNPC() or ent:IsPlayer()) and ent:EyePos() or ent:WorldSpaceCenter()
    local tr = util.TraceLine({
        start = self:GetLOSOrigin(),
        endpos = pos,
        filter = {self, ent},
        mask = MASK_BLOCKLOS,
    })
    return tr.Fraction >= 1
end

if SERVER then
    ENT.Target = nil

    function ENT:GetSentryOrigin()
        return self:GetPos()
    end

    function ENT:GetLOSOrigin()
        return self:WorldSpaceCenter()
    end


    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:GetPhysicsObject():SetMass(self.Mass)
        self:GetPhysicsObject():Wake()

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)
        self:SetAmmo(self.MagSize)
    end

    function ENT:RotateTowards(targetang)
        self:SetAimAngle(Angle(
            math.ApproachAngle(self:GetAimAngle().p, targetang.p, self.ThinkInterval * self.TurnRate),
            math.ApproachAngle(self:GetAimAngle().y, targetang.y, self.ThinkInterval * self.TurnRate), 0))
    end

    function ENT:TargetLogic()
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
            local tgtpos = self.Target:WorldSpaceCenter()
            targetang = self:WorldToLocalAngles((tgtpos - (self:GetPos() + Vector(0, 0, 32))):Angle())
        else
            targetang = Angle(0, self:WorldToLocalAngles(self:GetAngles()).y + math.sin(CurTime() / math.pi / 3) * 180, 0)
        end

        self:RotateTowards(targetang)

        local dot = targetang:Forward():Dot(self:GetAimAngle():Forward())
        if IsValid(self.Target) and dot >= 0.99 then
            if self:GetLockonTime() == 0 then
                self:SetLockonTime(CurTime() + 0.5)
                self:EmitSound("npc/turret_floor/ping.wav", 120, 100)
            elseif self:GetLockonTime() < CurTime() then
                self:ShootTarget()
            end
        end
    end

    function ENT:WrangleLogic()
        local tr = self:CPPIGetOwner():GetEyeTrace()
        local targetang = self:WorldToLocalAngles((tr.HitPos - self:GetPos()):Angle())
        self:RotateTowards(targetang)

        if self:CPPIGetOwner():KeyDown(IN_ATTACK) then
            self:ShootTarget(true)
        end

        self.Target = nil
    end

    function ENT:Think()
        if !self:CanFunction() then return end

        local owner = self:CPPIGetOwner()
        local wep = IsValid(owner) and owner:GetActiveWeapon()

        if IsValid(wep) and wep:GetClass() == "pt_wrangler" then
            self:WrangleLogic()
        else
            self:TargetLogic()
        end

        self:NextThink(CurTime() + self.ThinkInterval)
        return true
    end

    function ENT:ShootTarget(force)
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