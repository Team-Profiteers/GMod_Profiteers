AddCSLuaFile()

ENT.Base = "pt_base_plane"

ENT.PrintName = "Harrier"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/profiteers/vehicles/mw3_harrier.mdl"
ENT.Dropped = false
ENT.MyAngle = Angle(0, 0, 0)

ENT.IsAirAsset = true

ENT.Rockets = 16
ENT.DropPos = Vector(0, 0, 0)

ENT.NextRocketTime = 0

if SERVER then
    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        self:SetAngles(self.MyAngle)
        self:FrameAdvance(FrameTime())

        local selfpos2d = self:GetPos()
        local droppos2d = Vector(self.DropPos)

        --selfpos2d = selfpos2d - self:GetAngles():Forward() * (self:GetPos().z - self.DropPos.z)

        selfpos2d.z = 0
        droppos2d.z = 0

        if selfpos2d:Distance(droppos2d) < 1750 and (self.NextShoot or 0) < CurTime() then
            -- does not work
            --[[]
            if !self.CausedCower then
                debugoverlay.Sphere(self.DropPos, 2048, 5, Color(255, 0, 0, 0), true)
                for _, e in pairs(ents.FindInSphere(self.DropPos, 2048)) do
                    if e:IsNPC() then
                        e:SetActivity(ACT_COWER)
                        timer.Simple(5, function()
                            if IsValid(e) then e:SetSchedule(SCHED_IDLE_STAND) end
                        end)
                    end
                end
                self.CausedCower = true
            end
            ]]
            self.NextShoot = CurTime() + 0.01
            local shootang = (self:GetAngles() + Angle(90, 0, 0)):Forward()
            local bullet = {
                Attacker = self:GetOwner(),
                Inflictor = self,
                Damage = 25,
                Force = 20,
                Num = 8,
                Dir = shootang,
                Src = self:GetPos(),
                Tracer = 0,
                HullSize = 48,
                Spread = Vector(0.045, 0.045, 0.01),
                filter = self,
                Callback = function(attacker, tr, dmginfo)
                    if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
                        dmginfo:ScaleDamage(2)
                    elseif IsValid(tr.Entity) and tr.Entity:IsNPC() then
                        dmginfo:ScaleDamage(4)
                    end

                    if math.random() <= 1 / 2 then
                    local fx = EffectData()
                        fx:SetOrigin(tr.HitPos)
                        fx:SetStart(self:GetPos())
                        fx:SetScale(100000)
                        util.Effect("GunshipTracer", fx)
                    end
                end
            }
            -- TODO: BRRRRRRRRRRRRRRRRRRRRT

            self:FireBullets(bullet)

            phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 25000000)

            self:NextThink(CurTime() + 0.01)
            return true
        else
            phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 30000000)
        end
    end
end