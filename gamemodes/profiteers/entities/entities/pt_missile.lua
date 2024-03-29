AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Base Projectile"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/weapons/w_missile.mdl"
ENT.Ticks = 0
ENT.FuseTime = 0
ENT.Defused = false
ENT.BoxSize = Vector(8, 4, 1)
ENT.SmokeTrail = true
ENT.SmokeTrailSize = 32
ENT.SmokeTrailTime = 5
ENT.BoostEffectSize = 2
ENT.Flare = false
ENT.LifeTime = 30
ENT.BoostTime = 30
ENT.Drunkenness = 0

ENT.Drag = true
ENT.Gravity = true
ENT.Boost = 5000
ENT.BoostTarget = 15000
ENT.Lift = 100
ENT.DragCoefficient = 0
ENT.Damping = true
ENT.Inertia = nil

-- Not adding those to the gamemode for now
ENT.GunshipWorkaround = false
ENT.HelicopterWorkaround = false

ENT.Damage = 100
ENT.Radius = 256
ENT.ImpactDamage = 1000
ENT.Airburst = false

ENT.Dead = false
ENT.DieTime = 0

ENT.SteerSpeed = 15000 -- The maximum amount of degrees per second the missile can steer.
ENT.SeekerAngle = math.cos(math.rad(30)) -- The missile will lose tracking outside of this angle.
ENT.SuperSeeker = false
ENT.SACLOS = false -- This missile is manually guided by its shooter.
ENT.FireAndForget = true -- This missile automatically tracks its target.
ENT.SuperSteerBoostTime = 5 -- Time given for this projectile to adjust its trajectory from top attack to direct
ENT.NoReacquire = false -- F&F target is permanently lost if it cannot reacquire
ENT.TopAttack = false -- This missile flies up above its target before going down in a top-attack trajectory.
ENT.TopAttackHeight = 5000
ENT.TopAttackDistance = 2000

ENT.FuseTime = 0

ENT.ShootEntData = {}

ENT.IsProjectile = true
ENT.IsAirAsset = true
ENT.AirAssetWeight = 0.5

if SERVER then
    local gunship = {["npc_combinegunship"] = true, ["npc_combinedropship"] = true}

    function ENT:Initialize()
        local pb_vert = self.BoxSize[1]
        local pb_hor = self.BoxSize[2]
        self:SetModel(self.Model)
        self:PhysicsInitBox( Vector(-pb_vert,-pb_hor,-pb_hor), Vector(pb_vert,pb_hor,pb_hor) )

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableDrag(self.Drag)
            phys:SetDragCoefficient(self.DragCoefficient)
            if !self.Damping then phys:SetDamping(0, 0) end
            if self.Inertia then phys:SetInertia(self.Inertia) end
            if self.AngleDragCoefficient then
                phys:SetAngleDragCoefficient(self.AngleDragCoefficient)
            end
            phys:EnableGravity(self.Gravity)
            phys:SetMass(5)
            phys:SetBuoyancyRatio(0.4)
        end

        self.SpawnTime = CurTime()

        if self.SmokeTrail then
            util.SpriteTrail(self, 0, Color(150, 150, 150, 150), false, self.SmokeTrailSize, 0, self.SmokeTrailTime, 1 / self.SmokeTrailSize * 0.5, "trails/smoke")
        end
    end

    function ENT:OnTakeDamage(damage)
        if self.Defused then return end
        self:Remove()
        return 1
    end

    function ENT:Think()
        if self.Defused then return end

        if self.SpawnTime + self.LifeTime < CurTime() then
            self:Detonate()
            return
        end

        if self:WaterLevel() > 0 then
            self:Detonate()
            return
        end

        local drunk = false

        if self.FireAndForget then
            if self.ShootEntData.Target and (IsValid(self.ShootEntData.Target) or isvector(self.ShootEntData.Target)) then
                local target = self.ShootEntData.Target

                if isentity(target) and target.UnTrackable then self.ShootEntData.Target = nil end

                local tpos = isvector(target) and target or target:EyePos()

                if self.Airburst and (self:GetPos() - target:GetPos()):Length() < 256 then
                    self:Detonate()
                    return
                end

                if self.TopAttack and !self.TopAttackReached then
                    tpos = tpos + Vector(0, 0, self.TopAttackHeight)

                    local dist = (tpos - self:GetPos()):Length()

                    if dist <= self.TopAttackDistance then
                        self.TopAttackReached = true
                        self.SuperSteerTime = CurTime() + self.SuperSteerBoostTime
                    end
                end

                local dir = (tpos - self:GetPos()):GetNormalized()
                local dot = dir:Dot(self:GetAngles():Forward())
                local ang = dir:Angle()

                if self.SuperSeeker or dot >= self.SeekerAngle or !self.TopAttackReached or (self.SuperSteerTime and self.SuperSteerTime >= CurTime()) then
                    local p = self:GetAngles().p
                    local y = self:GetAngles().y

                    p = math.ApproachAngle(p, ang.p, FrameTime() * self.SteerSpeed)
                    y = math.ApproachAngle(y, ang.y, FrameTime() * self.SteerSpeed)

                    self:SetAngles(Angle(p, y, 0))
                elseif self.NoReacquire then
                    self.ShootEntData.Target = nil
                    drunk = true
                end
                -- end
            else
                drunk = true
            end
        elseif self.SACLOS then
            if self:GetOwner():IsValid() then
                local tpos = self:GetOwner():GetEyeTrace().HitPos
                local dir = (tpos - self:GetPos()):GetNormalized()
                local dot = dir:Dot(self:GetAngles():Forward())
                local ang = dir:Angle()

                if dot >= self.SeekerAngle then
                    local p = self:GetAngles().p
                    local y = self:GetAngles().y

                    p = math.ApproachAngle(p, ang.p, FrameTime() * self.SteerSpeed)
                    y = math.ApproachAngle(y, ang.y, FrameTime() * self.SteerSpeed)

                    self:SetAngles(Angle(p, y, 0))
                else
                    drunk = true
                end
            else
                drunk = true
            end
        end

        if drunk then
            self:GetPhysicsObject():AddAngleVelocity(VectorRand() * FrameTime() * 1500)
            --self:SetAngles(self:GetAngles() + (AngleRand() * FrameTime() * 1000 / 360))
        end

        if self.Drunkenness > 0 then
            self:GetPhysicsObject():AddAngleVelocity(VectorRand() * FrameTime() * self.Drunkenness)
            --self:SetAngles(self:GetAngles() + (AngleRand() * FrameTime() * self.Drunkenness / 360))
        end

        if self.BoostTime + self.SpawnTime > CurTime() then
            local vel = self:GetVelocity():Length()
            if !self.BoostTarget or vel < self.BoostTarget then
                self:GetPhysicsObject():AddVelocity(self:GetForward() * (self.Boost or 0))
            end
            self:GetPhysicsObject():AddVelocity(Vector(0, 0, self.Lift))
        end

        -- Gunships have no physics collection, periodically trace to try and blow up in their face
        if self.GunshipWorkaround and (self.GunshipCheck or 0 < CurTime()) then
            self.GunshipCheck = CurTime() + 1
            local tr = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() + (self:GetVelocity() * 6 * engine.TickInterval()),
                filter = self,
                mask = MASK_SHOT
            })
            if IsValid(tr.Entity) and gunship[tr.Entity:GetClass()] then
                self:SetPos(tr.HitPos)
                self:Detonate()
            end
        end
    end

    function ENT:Detonate()
        if !self:IsValid() then return end
        if self.Defused then return end
        self.Defused = true
        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )

        if self:WaterLevel() > 0 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
            --self:EmitSound("weapons/underwater_explode3.wav", 125, 100, 1, CHAN_AUTO)
        else
            util.Effect( "Explosion", effectdata)
            --self:EmitSound("phx/kaboom.wav", 125, 100, 1, CHAN_AUTO)
        end

        util.BlastDamage(IsValid(self.Inflictor) and self.Inflictor or self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), self.Radius, self.DamageOverride or self.Damage)

        if SERVER then
            self:FireBullets({
                Attacker = self,
                Damage = 0,
                Tracer = 0,
                Distance = 256,
                Dir = self.HitVelocity or self:GetVelocity(),
                Src = self:GetPos(),
                Callback = function(att, tr, dmg)
                    util.Decal("Scorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self)
                end
            })
        end
        -- self:Remove()

        self.Dead = true
        SafeRemoveEntityDelayed(self, self.SmokeTrailTime)
        timer.Simple(0, function()
            self:SetRenderMode(RENDERMODE_NONE)
            self:SetMoveType(MOVETYPE_NONE)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end)
    end

    function ENT:PhysicsCollide(colData, physobj)
        if !self:IsValid() then return end

        if CurTime() - self.SpawnTime < self.FuseTime then
            if IsValid(colData.HitEntity) then
                local v = colData.OurOldVelocity:Length() ^ 0.5
                local dmg = DamageInfo()
                dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
                dmg:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
                dmg:SetDamageType(DMG_CRUSH)
                dmg:SetDamage(v)
                dmg:SetDamagePosition(colData.HitPos)
                dmg:SetDamageForce(colData.OurOldVelocity)
                colData.HitEntity:TakeDamageInfo(dmg)
                self:EmitSound("weapons/rpg/shotdown.wav", 80, math.random(90, 110))
            end
            self:Defuse()
            return
        end

        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )

        -- simulate AP damage on vehicles, mainly simfphys
        local tgt = colData.HitEntity
        while IsValid(tgt) do
            if tgt.GetParent and IsValid(tgt:GetParent()) then
                tgt = tgt:GetParent()
            elseif tgt.GetBaseEnt and IsValid(tgt:GetBaseEnt()) then
                tgt = tgt:GetBaseEnt()
            else
                break
            end
        end

        if self.ImpactDamage and IsValid(tgt) then
            local dmg = DamageInfo()
            dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
            dmg:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetDamage(self.ImpactDamage)
            dmg:SetDamagePosition(colData.HitPos)
            dmg:SetDamageForce(self:GetForward() * self.ImpactDamage)

            if IsValid(tgt:GetOwner()) and tgt:GetOwner():GetClass() == "npc_helicopter" then
                tgt = tgt:GetOwner()
                dmg:ScaleDamage(0.1)
                dmg:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
                dmg:SetDamageForce(self:GetForward() * 100)
            end

            tgt:TakeDamageInfo(dmg)
        end

        self.HitPos = colData.HitPos
        self.HitVelocity = colData.OurOldVelocity
        self:Detonate()
    end

    -- Combine Helicopters are hard-coded to only take DMG_AIRBOAT damage
    hook.Add("EntityTakeDamage", "ARC9_HelicopterWorkaround", function(ent, dmginfo)
        if IsValid(ent:GetOwner()) and ent:GetOwner():GetClass() == "npc_helicopter" then ent = ent:GetOwner() end
        if ent:GetClass() == "npc_helicopter" and dmginfo:GetInflictor().HelicopterWorkaround then
            dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_AIRBOAT))
        end
    end)
end

function ENT:Defuse()
    self.Defused = true
    SafeRemoveEntityDelayed(self, 5)
end

local flaremat = Material("effects/arc9_lensflare")
function ENT:Draw()
    self.SpawnTime = self.SpawnTime or CurTime()
    self:DrawModel()

    if self.Flare and !self.Defused then
        render.SetMaterial(flaremat)
        render.DrawSprite(self:GetPos(), math.Rand(90, 110), math.Rand(90, 110), Color(255, 250, 240))
    end

    if (self.Boost or 0) > 0 and self.BoostTime + self.SpawnTime > CurTime() and (self.Tick or 0) % 3 == 0 then
        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetAngles(self:GetAngles())
        eff:SetEntity(self)
        eff:SetScale(self.BoostEffectSize)
        util.Effect("MuzzleEffect", eff)
    end
end