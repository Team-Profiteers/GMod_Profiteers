AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Cluster Mine"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_phx/trains/wheel_medium.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 100

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = false
ENT.AnchorOffset = Vector(0, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

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

        if CurTime() > self:GetArmTime() + 5 then
            self:SetArmed(false)
            self:Explode()
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

                local phys = mine:GetPhysicsObject()

                if IsValid(phys) then
                    phys:ApplyForceCenter(vec * 350 * k)
                end
            end
        end

        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end