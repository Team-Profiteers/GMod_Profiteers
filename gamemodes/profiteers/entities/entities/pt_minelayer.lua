AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Cluster Mine"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/trains/wheel_medium.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 500

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = false
ENT.AnchorOffset = Vector(0, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.MyMines = {}

ENT.MinesLaid = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Bool", 1, "Armed")

    self:NetworkVar("Float", 0, "ArmTime")
end

if SERVER then
    function ENT:OnAnchor(ply)
        GAMEMODE:Hint(ply, 1, "Deploying mines in 5 seconds. Stand clear.")
        self:SetArmTime(CurTime())
        self:SetArmed(true)
        self:EmitSound("buttons/combine_button5.wav", 110, 100)

        self.ArmedPlayer = ply
    end

    function ENT:Think()
        if !self:GetArmed() then return end

        if CurTime() > self:GetArmTime() + 5 and !self.MinesLaid then
            self:SetArmed(false)
            self:Explode()
        end

        if self.MinesLaid then
            local activemines = 0

            for _, i in ipairs(self.MyMines) do
                if i:IsValid() then
                    activemines = activemines + 1
                end
            end

            if activemines == 0 then
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos())
                util.Effect("HelicopterMegaBomb", effectdata)

                self:EmitSound("ambient/explosions/explode_3.wav", 125)

                self:Remove()
            end
        end
    end

    function ENT:OnRemove()
        for _, i in ipairs(self.MyMines) do
            if i:IsValid() then
                i:Remove()
            end
        end
    end

    function ENT:Explode()
        self:EmitSound("buttons/combine_button1.wav", 110)

        for k = 1, 3 do
            for i = 1, 8 do
                local mine = ents.Create("pt_mine")
                local deg = ((i - 1) * 45) + (k * 15)
                local vec = Vector(math.cos(math.rad(deg)), math.sin(math.rad(deg)), 2)

                mine:SetPos(self:GetPos() + (vec * 8))

                mine:SetAngles(Angle(0, math.random(0, 360), 0))
                mine:Spawn()
                mine:Activate()

                mine:SetOwner(self.ArmedPlayer or NULL)

                table.insert(self.MyMines, mine)

                local phys = mine:GetPhysicsObject()

                if IsValid(phys) then
                    phys:ApplyForceCenter(vec * 350 * k)
                end
            end
        end

        self.MinesLaid = true
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end