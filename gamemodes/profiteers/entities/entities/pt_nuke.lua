AddCSLuaFile()
ENT.PrintName = "Nuclear Device"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/torpedo.mdl"
ENT.SpawnTime = 0
ENT.DetonationTime = 5

ENT.TakePropDamage = true

ENT.BombOwner = nil

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "ArmTime")

    self:NetworkVar("Bool", 0, "Armed")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self.SpawnTime = CurTime()

        self:GetPhysicsObject():SetMass(150)

        self:SetNWInt("PFPropHealth", 1000)
        self:SetNWInt("PFPropMaxHealth", 1000)
    end

    function ENT:Think()
        if self:GetArmed() then
            if self:GetArmTime() + self.DetonationTime <= CurTime() then
                self:Detonate()
            end
        end
    end

    function ENT:Use(activator)
        if !self:GetArmed() and !IsValid(Profiteers.ActiveNuke) then
            self.BombOwner = activator
            self:SetOwner(activator)
            self:SetArmed(true)
            self:SetArmTime(CurTime())
            Profiteers.ActiveNuke = self
            self:EmitSound("ambient/machines/thumper_startup1.wav", 125)
        end
    end

    function ENT:Detonate()
        local nuke = ents.Create("pt_nukeexplosion")
        nuke:SetPos(self:GetPos())
        nuke:SetOwner(self:GetOwner())
        nuke:Spawn()
        nuke:Activate()

        Profiteers.ActiveNuke = nil
        Profiteers.GameOver = true

        if MapVote then
            MapVote.Start(60, false, "*")
        end

        self:Remove()
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)

        local ent = ents.Create("pt_money")
        ent:SetPos(self:GetPos())
        ent:SetAmount(1000000)
        ent:Spawn()
    end
else
    function ENT:Think()
        if self:GetArmed() then
            Profiteers.ActiveNuke = self
        end
    end

    local nukemat = Material("profiteers/nuke.png", "smooth nomips")

    function ENT:DrawTranslucent()
        //  Make the money draw a glowing effect
        self:DrawModel()

        if self:GetArmed() then
            local toscreen = self:GetPos():ToScreen()

            local x, y = toscreen.x, toscreen.y
            local s = ScreenScale(32)

            cam.Start2D()
                surface.SetMaterial(nukemat)
                surface.SetDrawColor(255, 255, 255, 35 * (math.sin(CurTime() * 5) + 1))
                surface.DrawTexturedRect(x - (s / 2), y - (s / 2), s, s)
            cam.End2D()
        end
    end
end