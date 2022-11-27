AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Base Cart"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = "models/props_lab/reciever_cart.mdl"
ENT.AnchorOffset = Vector(0, 0, 35)
ENT.AllowUnAnchor = true

ENT.BaseHealth = 250
ENT.TakePropDamage = true

ENT.PreferredAngle = Angle(0, 0, 0)

ENT.ChargeRate = 0.08
ENT.ThinkDelay = 0.1

ENT.ChargeColor = Color(255, 180, 120, 200)
ENT.ChargeName = "Charge"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Float", 0, "Charge")
end

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
        self:GetPhysicsObject():SetMass(200)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)
        self:SetCharge(0)
    end

    function ENT:OnUse(ply)
        if self:CanConsume(ply) then
            self:OnConsume(ply)
        else
            self:EmitSound("buttons/button18.wav", 80, 105)
        end
    end

    function ENT:Think()
        if self:WithinBeacon() and self:GetCharge() < 1 then
            self:NextThink(CurTime() + self.ThinkDelay)
            self:SetCharge(math.min(1, self:GetCharge() + self.ChargeRate * self.ThinkDelay))
        end
    end

    function ENT:CanConsume(ply)
        return true
    end

    function ENT:OnConsume(ply)

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

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 10.5 + self:GetForward() * 13.25 + self:GetRight() * -4.25

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -90)

        cam.Start3D2D(pos, ang, 0.02)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(-512, 0, 1024, 256)

            GAMEMODE:ShadowText(self.ChargeName, "CGHUD_2", 0, 60, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(self.ChargeColor:Unpack())
            surface.DrawRect(-500, 128, 1000 * self:GetCharge(), 96, 8)
            if self:WithinBeacon() then
                surface.SetDrawColor(255, 255, 255, 200)
            else
                surface.SetDrawColor(255, 255, (math.sin(SysTime() * 10) * 0.5 + 0.5) * 255, 200)
            end
            surface.DrawOutlinedRect(-500, 128, 1000, 96, 8)
        cam.End3D2D()
    end
end