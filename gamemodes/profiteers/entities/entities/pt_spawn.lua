AddCSLuaFile()

ENT.PrintName = "Deployable Spawn"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_mine01.mdl"

ENT.TakePropDamage = true

ENT.Category = "Profiteers"
ENT.Spawnable = false


function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Entity", 0, "User")
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
        self:GetPhysicsObject():SetMass(10)

        self:SetNWInt("PFPropHealth", 100)
        self:SetNWInt("PFPropMaxHealth", 100)
    end

    function ENT:Use(ply)
        if !self:GetAnchored() then
            if ply:KeyDown(IN_WALK) then
                local tr = util.TraceLine({
                    start = self:WorldSpaceCenter(),
                    endpos = self:WorldSpaceCenter() - Vector(0, 0, 16),
                    mask = MASK_SOLID_BRUSHONLY,
                })
                local pos = tr.HitPos
                local mins, maxs = self:GetCollisionBounds()
                local tr2 = util.TraceHull({
                    start = pos,
                    endpos = pos,
                    mins = mins - Vector(4, 4, 4),
                    maxs = maxs + Vector(4, 4, 4),
                    filter = self,
                    ignoreworld = true
                })
                if !self:WithinBeacon() then
                    self:EmitSound("npc/roller/code2.wav", 100, 90)
                    GAMEMODE:Hint(ply, 3, "Spawns can only be deployed within a Beacon.")
                elseif tr.Hit and !tr2.Hit then
                    self:SetPos(pos)
                    self:SetAngles(Angle(0, self:GetAngles().y, 0))
                    -- self:SetMoveType(MOVETYPE_NONE)
                    GAMEMODE:FreezeProp(self, true)
                    self:EmitSound("npc/roller/mine/rmine_blades_out" .. math.random(1, 3) .. ".wav", 100, 95)
                    timer.Simple(0.1, function() if IsValid(self) then self:EmitSound("npc/roller/blade_cut.wav", 100, 90) end end)
                    self:SetAnchored(true)
                    self:SetUser(ply) -- SetOwner will disable collisions. lovely!
                else
                    self:EmitSound("npc/roller/code2.wav", 100, 90)
                end
            elseif !self:IsPlayerHolding() then
                ply:PickupObject(self)
                GAMEMODE:HintOneTime(ply, 0, "Hold WALK key (Default Alt) to deploy the Spawn.")
            end
        else
            -- idk
        end
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
                endpos = self:WorldSpaceCenter() - Vector(0, 0, 32),
                mask = MASK_SOLID_BRUSHONLY,
            })
            render.DrawLine(tr.StartPos, tr.HitPos, tr.Hit and Color(0, 255, 0) or Color(255, 0, 0))
        end
    end

    --[[]
    function ENT:DrawTranslucent()
        if LocalPlayer() == self:GetUser() and IsValid(LocalPlayer():GetActiveWeapon()) and
                LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun" and LocalPlayer():KeyDown(IN_ATTACK) then
            render.DrawWireframeSphere(self:GetPos(), 1024, 4, 4)
        end
    end
    ]]

    local beaconcache
    local color_ok = Color(0, 255, 0)
    local color_bad = Color(255, 0, 0)

    hook.Add("PostDrawTranslucentRenderables", "Profiteers_Beacon", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_physgun" and LocalPlayer():KeyDown(IN_ATTACK) then
            if !beaconcache then
                beaconcache = {}
                for _, ent in pairs(ents.FindByClass("pt_beacon")) do
                    if ent:GetUser() ~= LocalPlayer() then continue end
                    table.insert(beaconcache, ent)
                end
            end


            for _, ent in pairs(beaconcache) do
                local clr = IsValid(LocalPlayer().PhysgunProp) and ((LocalPlayer().PhysgunProp:GetPos():Distance(ent:GetPos()) <= 1024) and color_ok or color_bad) or color_white
                render.DrawWireframeSphere(ent:GetPos(), 1024, 16, 16, clr, true)
            end
        else
            beaconcache = nil
        end
    end)
end