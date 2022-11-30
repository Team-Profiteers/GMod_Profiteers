AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "C4"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/weapons/w_c4_planted.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 20

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = false
ENT.AllowUnAnchor = false
ENT.AnchorOffset = Vector(0, 0, 0)

ENT.Category = "Profiteers"
ENT.Spawnable = false

ENT.Range = 1024
ENT.FuseTime = 5

ENT.Bounty = 0

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Bool", 1, "Armed")

    self:NetworkVar("Float", 0, "ArmTime")
    self:NetworkVar("Float", 1, "NextBeepTime")
end


if SERVER then
    function ENT:OnAnchor(ply)
        GAMEMODE:Hint(ply, 1, "C4 armed. Stand clear.")
        self:SetArmTime(CurTime())
        self:SetArmed(true)
        self:EmitSound("weapons/slam/mine_mode.wav", 110, 100)

        self.ArmedPlayer = ply
    end

    function ENT:Think()
        if !self:GetArmed() then return end

        if CurTime() > self:GetNextBeepTime() then
            self:SetNextBeepTime(CurTime() + 1)
            self:EmitSound("buttons/blip1.wav", 125, 100)
        end

        if CurTime() > self:GetArmTime() + self.FuseTime then
            self:Explode()
        end
    end

    function ENT:OnTakeDamage(damage)
        return 0
    end

    function ENT:OnUse(ply)
        if !self:GetAnchored() then return end

        self:EmitSound("buttons/button5.wav", 110)
        self:Remove()
    end

    function ENT:Explode()
        if !self:GetArmed() then return end
        self:SetArmed(false)

        self:EmitSound("buttons/combine_button1.wav", 110)

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("pt_c4boom", effectdata)

        self:EmitSound("weapons/c4/c4_explode1.wav", 140)

        util.BlastDamage(self, self.ArmedPlayer, self:GetPos(), self.Range, 7500)

        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    local glowmat = Material("sprites/redglow1")

    function ENT:DrawTranslucent(flags)
        self:Draw()

        local pos, ang = self:GetPos(), self:GetAngles()
        pos = pos + self:GetUp() * 9 + self:GetForward() * 3 + self:GetRight() * 4.6

        ang:RotateAroundAxis(self:GetUp(), -90)

        local seconds = self.FuseTime

        if self:GetArmed() then
            seconds = math.max(0, self.FuseTime - (CurTime() - self:GetArmTime()))
        end

        local minutes = math.floor(seconds / 60)
        seconds = seconds - (minutes * 60)

        // left pad minutes and seconds

        seconds = string.format("%02d", seconds)
        minutes = string.format("%02d", minutes)

        cam.Start3D2D(pos, ang, 0.05)
            GAMEMODE:ShadowText(tostring(minutes) .. ":" .. tostring(seconds), "CGHUD_3", 0, 0, Color(255, 0, 0), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()

        if self:GetArmed() then
            if self:GetNextBeepTime() - 0.75 < CurTime() then
                render.SetMaterial(glowmat)
                render.DrawSprite(self:GetPos() + self:GetUp() * 10 + self:GetForward() * 2 + self:GetRight() * -1, 12, 12, Color(255, 255, 255))
            end
        end
    end
end