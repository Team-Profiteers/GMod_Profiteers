AddCSLuaFile()

ENT.PrintName = "Base Beacon"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_light002a.mdl"

ENT.Category = "Profiteers"
ENT.Spawnable = true


function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
end

if SERVER then

    function ENT:GetPreferredCarryAngles(ply)
        return Angle(90, 0, 0)
    end

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:SetMaxHealth(1000)
        self:SetHealth(1000)
        self:GetPhysicsObject():SetMass(10)
    end

    function ENT:Use(ply)
        if !self:GetAnchored() then
            if ply:KeyDown(IN_WALK) then
                local tr = util.TraceLine({
                    start = self:WorldSpaceCenter(),
                    endpos = self:WorldSpaceCenter() - Vector(0, 0, 32),
                    mask = MASK_SOLID_BRUSHONLY,
                })
                local pos = tr.HitPos + Vector(0, 0, 4)
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
                    self:SetModel("models/props_combine/combine_light001a.mdl")
                    self:SetPos(pos)
                    self:SetAngles(Angle(0, self:GetAngles().y, 0))
                    self:SetMoveType(MOVETYPE_NONE)
                    self:SetSolid(SOLID_VPHYSICS)
                    self:EmitSound("npc/roller/mine/rmine_blades_out" .. math.random(1, 3) .. ".wav", 100, 95)
                    timer.Simple(0.1, function() if IsValid(self) then self:EmitSound("npc/roller/blade_cut.wav", 100, 90) end end)
                    self:SetAnchored(true)
                    self:SetOwner(ply)
                else
                    self:EmitSound("npc/roller/code2.wav", 100, 90)
                end
            elseif !self:IsPlayerHolding() then
                ply:PickupObject(self)
            end
        else
            -- idk
        end
    end

else
    function ENT:Draw()
        self:DrawModel()
        if LocalPlayer():GetPos():DistToSqr(self:GetPos()) <= 100 * 100 and !self:GetAnchored() then
            local tr = util.TraceLine({
                start = self:WorldSpaceCenter(),
                endpos = self:WorldSpaceCenter() - Vector(0, 0, 32),
                mask = MASK_SOLID_BRUSHONLY,
            })
            render.DrawLine(tr.StartPos, tr.HitPos, tr.Hit and Color(0, 255, 0) or Color(255, 0, 0))
        end
    end
end