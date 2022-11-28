AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Safe"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_lab/filecabinet02.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 10000

ENT.PreferredAngle = Angle(0, 180, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 16)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Bounty = 0

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Int", 0, "Cash")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType(SIMPLE_USE)
        self:GetPhysicsObject():SetMass(200)

        self:SetNWInt("PFPropHealth", self.BaseHealth)
        self:SetNWInt("PFPropMaxHealth", self.BaseHealth)
        self:SetCash(0)
    end

    function ENT:OnUse(ply)
        -- if empty, deposit player cash
        -- if not empty, withdraw
        -- if shift held, withdraw 10k

        if self:GetCash() == 0 then
            if ply:GetMoney() > 0 then
                self:SetCash(ply:GetMoney())
                ply:AddMoney(-self:GetCash())
                self:EmitSound("buttons/button18.wav", 80, 105)
            end
        else
            local amount = self:GetCash()
            if ply:KeyDown(IN_SPEED) then
                amount = math.min(amount, 10000)
            end
            self:SetCash(self:GetCash() - amount)
            ply:AddMoney(amount)
            self:EmitSound("buttons/button18.wav", 80, 105)
        end
    end

    function ENT:OnPropDestroyed(dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("explosion", effectdata)
        self:EmitSound("npc/manhack/gib.wav", 120, 110, 0.8)

        local ent = ents.Create("pt_money")
        ent:SetPos(self:GetPos() + Vector(0, 0, 20))
        ent:SetAmount(self:GetCash())
        ent:Spawn()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 12 + self:GetForward() * 16.5 + self:GetRight() * 0

        ang:RotateAroundAxis(self:GetUp(), 90)
        ang:RotateAroundAxis(self:GetRight(), -90)

        cam.Start3D2D(pos, ang, 0.05)
            GAMEMODE:ShadowText("SAFE", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(self:WithinBeacon() and "Active" or "Not Active - Place Near Beacon", "CGHUD_5", 0, 60, self:WithinBeacon() and color_white or Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText("$" .. tostring(self:GetCash()), "CGHUD_2", 0, 120, Color(150, 255, 150), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end