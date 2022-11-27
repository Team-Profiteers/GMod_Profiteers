AddCSLuaFile()

ENT.Base = "pt_base_anchorable"

ENT.PrintName = "Deployable Spawn"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_combine/combine_mine01.mdl"

ENT.TakePropDamage = true
ENT.BaseHealth = 200

ENT.PreferredAngle = Angle(0, 0, 0)
ENT.AnchorRequiresBeacon = true

ENT.Category = "Profiteers"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Anchored")
    self:NetworkVar("Entity", 0, "User")
end