AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Deployable Spawn"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_mine01.mdl"

ENT.TakePropDamage = true
ENT.VulnerableProp = true

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Entity", 0, "User")
end

if SERVER then

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
                    if !ent:GetAnchored() or ent:CPPIGetOwner() ~= LocalPlayer() then continue end
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