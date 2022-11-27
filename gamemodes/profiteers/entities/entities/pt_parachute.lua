// Entirely cosmetic parachute entity. Attaches to parachuting players.

AddCSLuaFile()
ENT.PrintName = "Parachute"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_survival/parachute/chute.mdl"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

function ENT:Think()
    if SERVER and (!IsValid(self:GetOwner()) or !self:GetOwner():GetNWBool("pt_parachute")) then
        self:Remove()
        return
    end

    self:SetPos(self:GetOwner():GetPos())

    local sa = self:GetOwner():GetAngles()
    sa.y = sa.y - 90
    sa.p = 0
    sa.r = 0
    self:SetAngles(sa)
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:DrawTranslucent()
    self:Draw()
end