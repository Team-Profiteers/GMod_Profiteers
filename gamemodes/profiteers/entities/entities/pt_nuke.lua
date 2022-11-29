AddCSLuaFile()
ENT.PrintName = "Nuclear Device"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/torpedo.mdl"
ENT.SpawnTime = 0

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
        if self:GetArmed() and self:GetArmTime() + GetConVar("pt_nuke_time"):GetFloat() <= CurTime() then
            self:Detonate()
        end
    end

    function ENT:Use(activator)
        if !self:GetArmed() and activator == self:CPPIGetOwner() then
            if IsValid(Profiteers.ActiveNuke) then
                GAMEMODE:Hint(activator, 1, "There is already an active nuke! Go stop it!")
                return
            end
            self.BombOwner = activator
            self:SetArmed(true)
            self:SetArmTime(CurTime())
            Profiteers.ActiveNuke = self
            self:EmitSound("ambient/machines/thumper_startup1.wav", 125)
            Profiteers:SyncNuke()
        end
    end

    function ENT:Detonate()
        local nuke = ents.Create("pt_nukeexplosion")
        nuke:SetPos(self:GetPos())
        nuke:SetOwner(self:CPPIGetOwner())
        nuke:Spawn()
        nuke:Activate()

        Profiteers:SetGameOver()

        timer.Simple(15, function()
            if MapVote then
                MapVote.Start(60, true, 4, "")
            else
                game.CleanUpMap()
                for _, ply in pairs(player.GetAll()) do
                    ply:Spawn()
                end
            end
        end)

        self:Remove()
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
    end

    function ENT:OnRemove()
        Profiteers.ActiveNuke = nil
        Profiteers:SyncNuke()
    end
else
    function ENT:DrawTranslucent()
        self:DrawModel()

        --[[]
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
        ]]
    end
end