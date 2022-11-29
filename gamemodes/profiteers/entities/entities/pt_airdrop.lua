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

        if !IsValid(self:GetPhysicsObject()) then
            self:SetModel("models/props_wasteland/laundry_washer001a.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
        end

        self:SetUseType(CONTINUOUS_USE)
        self.SpawnTime = CurTime()
        self:SetAmount(GetConVar("pt_airdrop_amount"):GetInt())
        self.NextUse = 0
        self:SetMaxHealth(GetConVar("pt_airdrop_moneyhealth"):GetInt())
        self:SetHealth(self:GetMaxHealth())
        self:GetPhysicsObject():SetDragCoefficient(100)
        self:GetPhysicsObject():SetAngleDragCoefficient(100)
    end

    function ENT:Think()
        if not self:GetArmed() then
            -- local a = self:GetAngles()
            -- a.p = 0
            -- a.r = 0
            -- self:SetAngles(a)
            local phys = self:GetPhysicsObject()
            -- fall slowly
            phys:AddVelocity(-physenv.GetGravity() - Vector(0, 0, 500))
            --phys:AddAngleVelocity()
        end
    end

    function ENT:PhysicsCollide(colData, collider)
        if not self:GetArmed() and colData.HitEntity:IsWorld() then
            self:CloseChute()
        end
    end

    function ENT:CloseChute()
        if not self:GetArmed() then
            self:SetArmed(true)
            self:EmitSound("profiteers/para_close.wav", 125)
            self:GetPhysicsObject():SetDragCoefficient(1)
            self:GetPhysicsObject():SetAngleDragCoefficient(1)
        end
    end

    function ENT:OnRemove()
        for i = 1, math.random(35, 50) do
            local eff = EffectData()
            eff:SetOrigin(self:WorldSpaceCenter() + VectorRand() * 32)
            eff:SetNormal((eff:GetOrigin() - self:WorldSpaceCenter() + Vector(0, 0, 1)):GetNormalized())
            eff:SetMagnitude(math.Rand(64, 256))
            util.Effect("pt_moneyeff", eff, true)
        end
        self:EmitSound("physics/cardboard/cardboard_box_break1.wav", 100, 85)
    end

    function ENT:Use(activator)
        if self:GetArmed() and self.NextUse < CurTime() then
            self.NextUse = CurTime() + 0.5
            local total = GetConVar("pt_airdrop_amount"):GetInt()
            local amount = math.min(self:GetAmount(), math.Round(math.random(math.ceil(total / 30), math.ceil(total / 50))))
            activator:AddMoney(amount)
            self:SetAmount(self:GetAmount() - amount)

            timer.Simple(0, function()
                for i = 1, math.random(4, 12) do
                    local eff = EffectData()
                    eff:SetOrigin(self:WorldSpaceCenter() + VectorRand() * 32)
                    eff:SetNormal((activator:EyePos() - self:WorldSpaceCenter() + VectorRand()):GetNormalized())
                    eff:SetMagnitude(math.Rand(128, 512))
                    eff:SetScale(math.Rand(180, 360))
                    util.Effect("pt_moneyeff", eff, true)
                end
            end)

            if self:GetAmount() <= 0 then
                self.NextUse = CurTime() + 9999
                SafeRemoveEntityDelayed(self, 0.25)
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)

        if self:GetArmed() and self:GetAmount() > 0 then
            local effamt = math.Clamp(math.Round((dmginfo:GetDamage() * 0.25) ^ 0.5), 2, 20)
            for i = 1, effamt do
                local eff = EffectData()
                eff:SetOrigin(self:WorldSpaceCenter() + VectorRand() * 32)
                eff:SetNormal((VectorRand() - dmginfo:GetDamageForce():GetNormalized() + Vector(0, 0, 1)):GetNormalized())
                eff:SetMagnitude(math.Rand(64, 512))
                util.Effect("pt_moneyeff", eff, true)
            end
            local damage = math.min(self:GetAmount(), math.ceil(dmginfo:GetDamage() * 10))
            if dmginfo:GetInflictor():GetClass() == "entityflame" then
                damage = math.ceil(self:GetAmount() * 0.02)
            end
            self:SetAmount(self:GetAmount() - damage)
            if not dmginfo:IsDamageType(DMG_BURN) and dmginfo:GetAttacker():IsPlayer() then
                dmginfo:GetAttacker():AddMoney(math.ceil(damage * math.Rand(0.5, 0.85)))
            end
            if self:GetAmount() <= 0 then
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos())
                util.Effect("explosion", effectdata)
                self:Remove()
            end
            return dmginfo:GetDamage()
        end
        self:SetHealth(self:Health() - dmginfo:GetDamage())

        if self:Health() <= 0 then
            self:SetAmount(math.ceil(self:GetAmount() * math.Rand(0.75, 0.9)))
            self:CloseChute()
            timer.Create("money_" .. self:EntIndex(), 0.2, 25, function()
                if !IsValid(self) or self:IsOnGround() then return end
                for i = 1, 8 do
                    local eff = EffectData()
                    eff:SetOrigin(self:WorldSpaceCenter() + VectorRand() * 32)
                    eff:SetNormal(VectorRand())
                    eff:SetMagnitude(math.Rand(32, 256))
                    eff:SetEntity(self)
                    util.Effect("pt_moneyeff", eff, true)
                end
            end)
        end

        return dmginfo:GetDamage()
    end
else
    function ENT:Initialize()
        self.ParachuteModel = ClientsideModel("models/props_survival/parachute/chute.mdl")
        if not self.ParachuteModel then return end
        if not IsValid(self.ParachuteModel) then return end
        self.ParachuteModel:SetNoDraw(true)
    end

    function ENT:Think()
        self.ParachuteOpenAmount = math.Approach(self.ParachuteOpenAmount or 0, 1, FrameTime() * 0.2)

        if self:GetArmed() and self.ParachuteModel then
            SafeRemoveEntity(self.ParachuteModel)
        end

        // create red smoke

        local emitter = ParticleEmitter(self:GetPos())

        local particle = emitter:Add("particles/smokey", self:GetPos() + self:GetUp() * 64)
        particle:SetVelocity(VectorRand() * 16 + self:GetRight() * 400)
        particle:SetDieTime(math.Rand(0.5, 1.5))
        particle:SetStartAlpha(100)
        particle:SetEndAlpha(0)
        particle:SetStartSize(0)
        particle:SetEndSize(50)
        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(math.Rand(-1, 1))
        particle:SetColor(255, 100, 100)
        particle:SetGravity(Vector(100, 0, 800) + VectorRand() * 64)
        particle:SetAirResistance(100)

        emitter:Finish()
    end

    function ENT:OnRemove()
        if self.ParachuteModel then
            SafeRemoveEntity(self.ParachuteModel)
        end
    end

    function ENT:DrawTranslucent()
        self:DrawModel()

        if self.ParachuteModel and IsValid(self.ParachuteModel) then
            local scale = Vector(self.ParachuteOpenAmount, self.ParachuteOpenAmount, 1)
            local mat = Matrix()
            mat:Scale(scale)
            local sangle = self:GetAngles()
            self.ParachuteModel:SetPos(self:WorldSpaceCenter() - Vector(0, 0, 64))
            self.ParachuteModel:SetAngles(Angle(0, sangle[2], 0))
            self.ParachuteModel:EnableMatrix("RenderMultiply", mat)
            self.ParachuteModel:DrawModel()
        end

        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(LocalPlayer():EyeAngles():Up(), -90)
        ang:RotateAroundAxis(LocalPlayer():EyeAngles():Right(), 90)

        self.LerpAmount = math.Round(math.Approach(self.LerpAmount or self:GetAmount(), self:GetAmount(), 30000 * FrameTime()))
        cam.Start3D2D(self:WorldSpaceCenter() + Vector(0, 0, 48), ang, 0.1)
            --cam.IgnoreZ(true)
            GAMEMODE:ShadowText("AIRDROP", "CGHUD_2", 0, 0, color_white, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            GAMEMODE:ShadowText(GAMEMODE:FormatMoney(self.LerpAmount), "CGHUD_2", 0, 75, Color(150, 255, 80), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            --cam.IgnoreZ(false)
        cam.End3D2D()
    end
end