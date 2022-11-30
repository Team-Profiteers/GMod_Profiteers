AddCSLuaFile()

ENT.PrintName = "Mobile Beacon"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_emitter01.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 2500
ENT.AllowPhysgun = true

ENT.PreferredAngle = Angle(0, 180, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

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
        self:GetPhysicsObject():SetMass(75)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)

        self:SetAngles(Angle(0, self:GetAngles().y, 0) + self.PreferredAngle)
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/turret_floor/die.wav", 120, 110, 0.8)
    end

    function ENT:Use(ply)
        if ply ~= self:CPPIGetOwner() then return end
        GAMEMODE:HintOneTime(ply, 0, "The mobile beacon will provide the same benefits of a base beacon anywhere, and does not need anchoring.")
    end

end