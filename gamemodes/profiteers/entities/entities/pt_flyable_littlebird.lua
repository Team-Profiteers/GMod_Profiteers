AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

ENT.PrintName = "Little Bird"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_littlebird.mdl"

ENT.BaseHealth = 1500

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PilotSeat")

    self:NetworkVar("Float", 0, "EnterVehicleTime")

    self:SetEnterVehicleTime(0)
end

ENT.Seat_Model = "models/nova/jeep_seat.mdl"
ENT.Seat_KeyValues = {
    vehiclescript = "scripts/vehicles/prisoner_pod.txt",
    limitview = "0"
}

function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        local PilotSeat = ents.Create("prop_vehicle_prisoner_pod")
        PilotSeat:SetModel("models/nova/airboat_seat.mdl")

        for k, v in pairs(self.Seat_KeyValues or {}) do
            local kLower = string.lower(k)

            if kLower == "vehiclescript" or kLower == "limitview" or kLower == "vehiclelocked" or kLower == "cargovisible" or kLower == "enablegun" then
                PilotSeat:SetKeyValue(k, v)
            end
        end

        PilotSeat:SetPos(self:GetPos() + self:GetForward() * 30 + self:GetUp() * -60 + self:GetRight() * -15)
        PilotSeat:SetAngles(self:GetAngles() + Angle(0, -90, 0))
        PilotSeat:Spawn()
        PilotSeat:SetParent(self)
        PilotSeat:SetMoveType(MOVETYPE_NONE)
        PilotSeat:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        PilotSeat:SetVehicleEntryAnim(false)

        PilotSeat:SetRenderMode(RENDERMODE_NONE)

        self:SetPilotSeat(PilotSeat)

        self:SetUseType(SIMPLE_USE)

        self:SetHealth(self.BaseHealth)
        self:SetMaxHealth(self.BaseHealth)
    elseif CLIENT then
        self:SetPredictable(true)
    end
end

if SERVER then
    function ENT:Use(activator, caller, useType, value)
        if activator:IsPlayer() then
            local pilotseat = self:GetPilotSeat()

            if !IsValid(pilotseat) then return end

            if !pilotseat:GetDriver():IsValid() then
                drive.PlayerStartDriving(activator, self, "pt_drive_littlebird")
                self:SetEnterVehicleTime(CurTime())
            end
        end
    end
end

if CLIENT then
    function ENT:Draw()
        local rotorbone = "main_rotor_jnt"
        local rotorbone2 = "tail_rotor_jnt"

        local rotorboneid = self:LookupBone(rotorbone)
        local rotorboneid2 = self:LookupBone(rotorbone2)

        if rotorboneid and rotorboneid2 then
            self:ManipulateBoneAngles(rotorboneid, Angle(0, math.fmod(CurTime() * 200, 360, 0)))
            self:ManipulateBoneAngles(rotorboneid2, Angle(math.fmod(CurTime() * 200, 360), 0, 0))
        end

        self:DrawModel()
    end

    function ENT:DrawTranslucent(flags)
        self:Draw(flags)
    end
end