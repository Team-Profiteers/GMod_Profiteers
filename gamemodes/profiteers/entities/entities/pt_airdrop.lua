AddCSLuaFile()
ENT.PrintName = "Airdrop"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props/cs_assault/MoneyPallet.mdl"

ENT.ParachuteOpenTime = 1
ENT.ParachuteOpen = false
ENT.ParachuteOpenAmount = 0

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Armed")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self.SpawnTime = CurTime()
    end

    function ENT:Think()
        if !self:GetArmed() then
            local a = self:GetAngles()
            a.p = 0
            a.r = 0

            self:SetAngles(a)

            local phys = self:GetPhysicsObject()
            -- fall slowly
            phys:SetVelocity(Vector(0, 0, -100))
        end
    end

    function ENT:PhysicsCollide(colData, collider)
        if !self:GetArmed() and colData.HitEntity:IsWorld() then
            self:SetArmed(true)
            self:EmitSound("profiteers/para_close.wav", 125)
        end
    end

    function ENT:Use(activator)
        if self:GetArmed() then
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            effectdata:SetMagnitude(20)
            effectdata:SetScale(10)
            effectdata:SetRadius(5)
            util.Effect("Sparks", effectdata)

            self:EmitSound("profiteers/para_open.wav", 125)

            self:SetArmed(false)

            local ent = ents.Create("pt_money")
            ent:SetPos(self:GetPos())
            ent:SetAmount(250000)
            ent:Spawn()

            self:Remove()
        end
    end

    function ENT:Detonate()
        local nuke = ents.Create("pt_nukeexplosion")
        nuke:SetPos(self:GetPos())
        nuke:SetOwner(self:GetOwner())
        nuke:Spawn()
        nuke:Activate()

        Profiteers.ActiveNuke = nil
        Profiteers.GameOver = true

        if MapVote then
            MapVote.Start(60, false)
        end

        self:Remove()
    end
else
    function ENT:Initialize()
        self.ParachuteModel = ClientsideModel("models/props_survival/parachute/chute.mdl")

        if !self.ParachuteModel then return end
        if !IsValid(self.ParachuteModel) then return end

        self.ParachuteModel:SetNoDraw(true)
    end

    function ENT:Think()
        self.ParachuteOpenAmount = math.Approach(self.ParachuteOpenAmount or 0, 1, FrameTime() * 0.2)

        if self:GetArmed() and self.ParachuteModel then
            SafeRemoveEntity(self.ParachuteModel)
        end
    end

    function ENT:OnRemove()
        if self.ParachuteModel then
            SafeRemoveEntity(self.ParachuteModel)
        end
    end

    function ENT:DrawTranslucent()
        self:DrawModel()

        if self.ParachuteModel and IsValid(self.ParachuteModel) then
            local scale = Vector( self.ParachuteOpenAmount, self.ParachuteOpenAmount, 1 )

            local mat = Matrix()
            mat:Scale( scale )

            local sangle = self:GetAngles()
            self.ParachuteModel:SetPos(self:WorldSpaceCenter() - Vector(0, 0, 64))
            self.ParachuteModel:SetAngles(Angle(0, sangle[2], 0))
            self.ParachuteModel:EnableMatrix("RenderMultiply", mat)
            self.ParachuteModel:DrawModel()
         end
    end
end