AddCSLuaFile()


ENT.PrintName = "Cash"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props/cs_assault/Money.mdl"

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Amount")
end

if SERVER then

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetTrigger(true)
        self:UseTriggerBounds(true, 24)
    end

    function ENT:StartTouch(ply)
        if !self.USED and ply:IsPlayer() then
            self.USED = true
            ply:AddMoney(self:GetAmount())
            self:Remove()
        end
    end

    // Money stops moving once it hits the ground and stops moving

    function ENT:PhysicsCollide(data, physobj)
        if data.HitEntity:IsWorld() then
            self:SetMoveType(MOVETYPE_NONE)

            // aligns to ground

            local ang = data.HitNormal:Angle()
            ang:RotateAroundAxis(ang:Right(), 90)
            ang:RotateAroundAxis(ang:Up(), 90)
            self:SetAngles(ang)
        end
    end

else

    function ENT:DrawTranslucent()
        //  Make the money draw a glowing effect
        self:DrawModel()
        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        cam.Start3D2D(self:GetPos() + Vector(0, 0, 10), ang, 0.1)
            draw.SimpleTextOutlined("$" .. self:GetAmount(), "CGHUD_72_Unscaled_Glow", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            draw.SimpleTextOutlined("$" .. self:GetAmount(), "CGHUD_72_Unscaled", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        cam.End3D2D()

    end

end