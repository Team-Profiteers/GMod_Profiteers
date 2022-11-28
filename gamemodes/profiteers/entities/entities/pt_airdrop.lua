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
    self:NetworkVar("Int", 0, "Amount")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(CONTINUOUS_USE)
        self.SpawnTime = CurTime()
        self:SetAmount(GetConVar("pt_airdrop_amount"):GetInt())
        self.constraint = constraint.Keepupright( ent, Angle(0, 0, 0), 0, 9000 )
        self.NextUse = 0
        self:SetMaxHealth(GetConVar("pt_airdrop_moneyhealth"):GetInt())
        self:SetHealth(self:GetMaxHealth())
        self:GetPhysicsObject():SetDragCoefficient(100)
        self:GetPhysicsObject():SetAngleDragCoefficient(100)
    end

    function ENT:Think()
        if !self:GetArmed() then
            -- local a = self:GetAngles()
            -- a.p = 0
            -- a.r = 0

            -- self:SetAngles(a)

            local phys = self:GetPhysicsObject()
            -- fall slowly
            phys:AddVelocity(-physenv.GetGravity() + Vector(0, 0, 500))
        end
    end

    function ENT:PhysicsCollide(colData, collider)
        if !self:GetArmed() and colData.HitEntity:IsWorld() then
            self:CloseChute()
        end
    end

    function ENT:CloseChute()
        if !self:GetArmed() then
            self:SetArmed(true)
            self:EmitSound("profiteers/para_close.wav", 125)
        end
    end

    function ENT:Use(activator)
        if self:GetArmed() and self.NextUse < CurTime() then
            self.NextUse = CurTime() + 0.75

            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            effectdata:SetMagnitude(20)
            effectdata:SetScale(10)
            effectdata:SetRadius(5)
            util.Effect("Sparks", effectdata)

            local total = GetConVar("pt_airdrop_amount"):GetInt()
            local amount = math.random(math.ceil(total / 20), math.ceil(total / 40))

            activator:AddMoney(amount)
            self:SetAmount(self:GetAmount() - amount)

            for i = 1, math.random(4, 9) do
                local eff = EffectData()
                eff:SetOrigin(self:GetPos() + VectorRand() * 32 + Vector(0, 0, 64))
                eff:SetNormal(VectorRand())
                eff:SetMagnitude(math.Rand(512, 2048))
                util.Effect("pt_moneyeff", eff, true)
            end

            if self:GetAmount() <= 0 then
                self:Remove()
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
        if self:GetArmed() then return end
        self:SetHealth(self:Health() - dmginfo:GetDamage())
        if self:Health() <= 0 then
            self:CloseChute()
        end
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