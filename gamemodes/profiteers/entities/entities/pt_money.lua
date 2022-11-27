AddCSLuaFile()


ENT.PrintName = "Cash"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props/cs_assault/Money.mdl"
ENT.SpawnTime = 0

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Amount")
end

if SERVER then

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetTrigger(true)
        self:UseTriggerBounds(true, 24)

        self.SpawnTime = CurTime()

        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() - Vector(0, 0, 300000),
            mask = MASK_NPCWORLDSTATIC,
        })

        local v = tr.HitNormal

        local a = v:Angle()

        a:RotateAroundAxis(a:Up(), 90)
        a:RotateAroundAxis(a:Forward(), 90)

        self:SetPos(tr.HitPos)
        self:SetAngles(a)
    end

    function ENT:Think()
        if (self.SpawnTime + 300) < CurTime() then
            self:Remove()
        end
    end

    function ENT:StartTouch(ply)
        if !self.USED and ply:IsPlayer() then
            self.USED = true
            -- self:EmitSound("profiteers/money_pickup.wav", 75, math.Rand(95, 105))
            ply:AddMoney(self:GetAmount())
            self:Remove()
        end
    end

else

    local glowmat = Material("sprites/glow04_noz")

    function ENT:DrawTranslucent()
        //  Make the money draw a glowing effect
        self:DrawModel()

        local dist = EyePos():Distance(self:GetPos())

        if dist > 512 then return end

        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        cam.IgnoreZ(true)

        cam.Start3D2D(self:GetPos() + Vector(0, 0, 10), ang, 0.1)
            draw.SimpleTextOutlined("$" .. self:GetAmount(), "CGHUD_72_Unscaled_Glow", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            draw.SimpleTextOutlined("$" .. self:GetAmount(), "CGHUD_72_Unscaled", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        cam.End3D2D()

        // draw glow sprite

        render.SetMaterial(glowmat)
        render.DrawSprite(self:GetPos(), 4, 4, Color(150, 255, 200, 255))

        cam.IgnoreZ(false)

    end

end