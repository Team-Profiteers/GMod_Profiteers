AddCSLuaFile()

ENT.PrintName = "Base Beacon"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_light002a.mdl"

ENT.BaseHealth = 500
ENT.TakePropDamage = true

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = false
ENT.AnchorOffset = Vector(0, 0, 0)
ENT.AnchorAngle = Angle(0, 0, 0)
ENT.AnchorSpikeSize = 64

ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
end

if SERVER then

    function ENT:GetPreferredCarryAngles(ply)
        return self.PreferredAngle
    end

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:GetPhysicsObject():SetMass(100)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)

        self:SetAngles(Angle(0, self:GetAngles().y, 0) + self.PreferredAngle)

        self:OnInitialize()
    end

    function ENT:OnInitialize()
    end

    function ENT:OnTakeDamage(damage)
        return 1
    end

    function ENT:TryAnchor(ply)

        if self:GetAnchored() then
            if self.AllowUnAnchor then
                GAMEMODE:FreezeProp(self, false)
                self:SetAnchored(false)
                self:EmitSound("npc/roller/blade_in.wav", 100, 90)
            end
            return
        end

        if self.AnchorRequiresBeacon and !self:WithinBeacon() then
            self:EmitSound("npc/roller/code2.wav", 100, 90)
            GAMEMODE:HintOneTime(ply, 3, "This can only be deployed within a Beacon.")
            return
        end

        local tr = util.TraceLine({
            start = self:WorldSpaceCenter(),
            endpos = self:WorldSpaceCenter() - Vector(0, 0, 1) * self.AnchorSpikeSize,
            mask = MASK_SOLID_BRUSHONLY,
        })
        if !tr.Hit then
            self:EmitSound("npc/roller/code2.wav", 100, 90)
            GAMEMODE:Hint(ply, 1, "Cannot find solid ground to anchor on.")
            return
        end
        local pos = tr.HitPos + self.AnchorOffset
        local mins, maxs = self:GetCollisionBounds()
        local tr2 = util.TraceHull({
            start = pos,
            endpos = pos,
            mins = mins,
            maxs = maxs,
            filter = self,
            ignoreworld = true
        })
        if !tr2.Hit then
            self:SetPos(pos)
            self:SetAngles(Angle(0, self:GetAngles().y, 0) + self.AnchorAngle)
            GAMEMODE:FreezeProp(self, true)
            self:SetAnchored(true)
            self:OnAnchor(ply)
        else
            self:EmitSound("npc/roller/code2.wav", 100, 90)
            GAMEMODE:Hint(ply, 1, "Cannot anchor because something is in the way.")
        end
    end

    function ENT:Use(ply)
        if ply ~= self:CPPIGetOwner() then return end
        if ply:KeyDown(IN_WALK) then
            self:TryAnchor(ply)
        else
            self:OnUse(ply)
        end
    end

    function ENT:OnUse(ply)
        if self.AllowUnAnchor then
            GAMEMODE:Hint(ply, 0, "Hold WALK key (Default Alt) and Use to toggle anchoring.")
        elseif !self:GetAnchored() then
            GAMEMODE:Hint(ply, 0, "Hold WALK key (Default Alt) and Use to deploy this.")
        end
    end

    function ENT:OnAnchor(ply)
        self:EmitSound("npc/roller/blade_cut.wav", 100, 90)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)
    end
else
    function ENT:Draw()
        self:DrawModel()
        if LocalPlayer():GetPos():DistToSqr(self:GetPos()) <= 100 * 100 and !self:GetAnchored() then
            local tr = util.TraceLine({
                start = self:WorldSpaceCenter(),
                endpos = self:WorldSpaceCenter() - self:GetUp() * 64,
                mask = MASK_SOLID_BRUSHONLY,
            })
            render.DrawLine(tr.StartPos, tr.HitPos, tr.Hit and Color(0, 255, 0) or Color(255, 0, 0))
        end
    end
end