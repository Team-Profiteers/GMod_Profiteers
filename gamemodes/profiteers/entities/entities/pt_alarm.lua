AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Motion Sensor"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/maxofs2d/lamp_projector.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 500

ENT.PreferredAngle = Angle(-90, 0, 0)
ENT.AnchorRequiresBeacon = true
ENT.AllowUnAnchor = true
ENT.AnchorOffset = Vector(0, 0, 10)
ENT.AnchorAngle = Angle(-90, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Bounty = 500

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Bool", 1, "Angry")

    self:NetworkVar("Float", 0, "AngryTime")
end

function ENT:OnInitialize()
    self:SetColor(Color(0, 10, 25))
end

if SERVER then
    function ENT:Think()
        if !self:GetAnchored() then return end

        if !self:GetAngry() then
            for k, v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
                if v:IsPlayer() and v:Alive() and v ~= self:CPPIGetOwner() then
                    self:SetAngry(true)
                    self:SetAngryTime(CurTime() + 5)
                    self:EmitSound("ambient/alarms/klaxon1.wav", 110, 100)
                    --
                    GAMEMODE:Hint(self:CPPIGetOwner(), NOTIFY_ERROR, "Your Motion Sensor has detected an intruder!")
                    break
                end
            end
        elseif CurTime() > self:GetAngryTime() then
            self:SetAngry(false)
        end

        if !self:GetAngry() then
            self:NextThink(CurTime() + 0.1)
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    local glowmat = Material("sprites/light_glow02_add")
    local glowmat_angry = Material("sprites/redglow1")

    function ENT:DrawTranslucent(flags)
        self:Draw()

        -- draw the glow

        if self:GetAnchored() then
            if self:GetAngry() then
                render.SetMaterial(glowmat_angry)
                render.DrawSprite(self:GetPos() + Vector(0, 0, 10), 32, 32, Color(255, 255, 255, 150))
            else
                if (math.sin(CurTime() * 3) > 0.5) then
                    render.SetMaterial(glowmat)
                    render.DrawSprite(self:GetPos() + Vector(0, 0, 10), 32, 32, Color(255, 255, 255))
                end
            end
        end
    end
end