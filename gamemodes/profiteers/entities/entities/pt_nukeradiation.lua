ENT.Type = "point"
ENT.PrintName = "Nuclear Radiation"
ENT.Author = "Teta_Bonita"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

if SERVER then
    AddCSLuaFile('shared.lua')

    function ENT:Initialize()
        --variables
        self.Yield = 1
        self.YieldSlow = self.Yield ^ 0.75
        self.YieldSlowest = self.Yield ^ 0.5
        self.Pos = self.Entity:GetPos() + Vector(0, 0, 4)
        self.Damage = 3e7 * self.YieldSlow
        self.Duration = 400 * self.YieldSlowest
        self.Radius = 12000 * self.YieldSlow
        self.Owner = self.Entity.Owner
        self.Weapon = self.Entity
        self.lastThink = CurTime() + 3
        self.RadTime = CurTime() + self.Duration
        --We need to init physics properties even though this entity isn't physically simulated
        self.Entity:SetMoveType(MOVETYPE_NONE)
        self.Entity:DrawShadow(false)
        self.Entity:SetCollisionBounds(Vector(-20, -20, -10), Vector(20, 20, 10))
        self.Entity:PhysicsInitBox(Vector(-20, -20, -10), Vector(20, 20, 10))
        local phys = self.Entity:GetPhysicsObject()

        if phys:IsValid() then
            phys:EnableCollisions(false)
        end

        self.Entity:SetNotSolid(true)
        self.CanTool = false
    end

    -- Total destruction
    function ENT:LOS(ent, entpos)
        return true
    end

    function ENT:Think()
        if not IsValid(self) then return end
        if not IsValid(self.Entity) then return end

        if not IsValid(self.Owner) then
            self.Entity:Remove()

            return
        end

        local CurrentTime = CurTime()
        local FTime = CurrentTime - self.lastThink
        if FTime < 0.3 then return end
        self.lastThink = CurrentTime
        local RadIntensity = (self.RadTime - CurrentTime) / self.Duration

        for key, found in pairs(ents.FindInSphere(self.Pos, self.Radius)) do
            local entpos
            local entdist

            if found:IsValid() then
                if found:IsNPC() then
                    entpos = found:LocalToWorld(found:OBBCenter())

                    if self:LOS(found, entpos) then
                        entdist = (entpos - self.Pos):Length() ^ -2
                        util.BlastDamage(self.Weapon, self.Owner, entpos, 8, self.Damage * RadIntensity * entdist)
                    end
                elseif found:IsPlayer() then
                    entpos = found:LocalToWorld(found:OBBCenter())

                    if self:LOS(found, entpos) then
                        entdist = (entpos - self.Pos):Length() ^ -2
                        found:TakeDamage(self.Damage * RadIntensity * entdist, self.Owner)
                    end
                end
            end
        end
    end
end