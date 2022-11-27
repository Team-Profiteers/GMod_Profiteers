AddCSLuaFile()

ENT.PrintName = "Base Beacon"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_light002a.mdl"

ENT.TakePropDamage = true

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false


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
        self:GetPhysicsObject():SetMass(10)

        self:SetNWInt("PFPropHealth", 500)
        self:SetNWInt("PFPropMaxHealth", 500)
    end

    function ENT:Use(ply)
        if !self:GetAnchored() then
            if ply:KeyDown(IN_WALK) then

                if self.AnchorRequiresBeacon and !self:WithinBeacon() then
                    self:EmitSound("npc/roller/code2.wav", 100, 90)
                    GAMEMODE:HintOneTime(ply, 3, "This can only be deployed within a Beacon.")
                    return
                end

                local tr = util.TraceLine({
                    start = self:WorldSpaceCenter(),
                    endpos = self:WorldSpaceCenter() - self:GetUp() * 64,
                    mask = MASK_SOLID_BRUSHONLY,
                })
                local pos = tr.HitPos + Vector(0, 0, 0)
                local mins, maxs = self:GetCollisionBounds()
                local tr2 = util.TraceHull({
                    start = pos,
                    endpos = pos,
                    mins = mins - Vector(4, 4, 4),
                    maxs = maxs + Vector(4, 4, 4),
                    filter = self,
                    ignoreworld = true
                })
                if tr.Hit and !tr2.Hit then
                    self:SetPos(tr.HitPos)
                    self:SetAngles(Angle(0, self:GetAngles().y, 0))
                    GAMEMODE:FreezeProp(self, true)
                    self:SetAnchored(true)
                    self:OnAnchor(ply)
                else
                    self:EmitSound("npc/roller/code2.wav", 100, 90)
                    GAMEMODE:Hint(ply, 3, "This can only be deployed on solid ground.")
                end
            elseif !self:IsPlayerHolding() then
                ply:PickupObject(self)
                GAMEMODE:Hint(ply, 0, "Hold WALK key (Default Alt) and Use to deploy this.")
            end
        else
            -- idk
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