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
        self:SetMoveType(MOVETYPE_NONE)
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

end