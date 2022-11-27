AddCSLuaFile()
ENT.PrintName = "Airdrop Plane"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/c130.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

local sounds = {"profiteers/flyover1.wav", "profiteers/flyover2.wav",}

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self.SpawnTime = CurTime()
        self:GetPhysicsObject():SetMass(150)
        self:SetHealth(2000)
        self:SetMaxHealth(2000)
        self.MyAngle = self:GetAngles()
        self:SetOwner(NULL)
        self:SetBodygroup(1, 1)
        self:SetBodygroup(2, 1)
        -- play idle anim
        self:ResetSequence(self:LookupSequence("idle"))
    end

    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 5000000)
        self:SetAngles(self.MyAngle)
        self:FrameAdvance(FrameTime())
    end

    function ENT:PhysicsCollide(colData, collider)
        -- if it hits world make it remove itself
        if colData.HitEntity:IsWorld() then
            self:Remove()
        end
    end

    function ENT:OnTakeDamage(damage)
        self:TakePhysicsDamage(damage)
        self:SetHealth(self:Health() - damage:GetDamage())

        if self:Health() <= 0 and not self.Dropped then
            self.Dropped = true
            self:OnPropDestroyed(damage)
        end
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(1000)
        util.Effect("HelicopterMegaBomb", effectdata)
        local pos = self:GetPos()
        self:Remove()
        local ent = ents.Create("pt_airdrop")
        ent:SetPos(pos)
        ent:Spawn()
    end
else
    function ENT:Initialize()
        surface.PlaySound("profiteers/flyby_02.ogg")
    end

    function ENT:DrawTranslucent()
        self:DrawModel()
    end

    function ENT:Think()
        -- advance animation sequence
        self:FrameAdvance(FrameTime())
    end
end