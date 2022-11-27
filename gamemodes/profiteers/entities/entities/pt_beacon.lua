AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Base Beacon"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_light002a.mdl"

ENT.TakePropDamage = true

ENT.PreferredAngle = Angle(0, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

if SERVER then

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

    function ENT:OnAnchor(ply)
        self:SetModel("models/props_combine/combine_light001a.mdl")
        self:EmitSound("npc/roller/mine/rmine_blades_out" .. math.random(1, 3) .. ".wav", 100, 95)
        timer.Simple(0.1, function() if IsValid(self) then self:EmitSound("npc/roller/blade_cut.wav", 100, 90) end end)
        GAMEMODE:HintOneTime(ply, 0, "Props near the beacon unghost quickly and are invulnerable to small arms fire.")
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)
    end
else
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

            local radius = GetConVar("pt_prop_beacon_radius"):GetFloat()
            for _, ent in pairs(beaconcache) do
                local clr = IsValid(LocalPlayer().PhysgunProp) and ((LocalPlayer().PhysgunProp:GetPos():Distance(ent:GetPos()) <= 1024) and color_ok or color_bad) or color_white
                render.DrawWireframeSphere(ent:GetPos(), radius, 16, 16, clr, true)
            end
        else
            beaconcache = nil
        end
    end)
end