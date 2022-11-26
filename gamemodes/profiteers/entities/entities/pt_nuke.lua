AddCSLuaFile()
ENT.PrintName = "Nuclear Device"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/torpedo.mdl"
ENT.SpawnTime = 0
ENT.DetonationTime = 180

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
            self:SetOwner(activator)
            self:SetArmed(true)
            self:SetArmTime(CurTime())
            Profiteers.ActiveNuke = self
        end
    end

    function ENT:Detonate()
        local nuke = ents.Create("pt_nukeexplosion")
        nuke:SetPos(self:GetPos())
        nuke:SetOwner(self:GetOwner())
        nuke:Spawn()
        nuke:Activate()
        self:Remove()
        Profiteers.ActiveNuke = nil
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