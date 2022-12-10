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

ENT.TailLightPos = Vector(0, 0, -32)

if SERVER then
    function ENT:Think()
        local phys = self:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
        phys:ApplyForceCenter(self:GetAngles():Forward() * FrameTime() * 30000000)
        self:SetAngles(self.MyAngle)
        self:FrameAdvance(FrameTime())

        // when we get close to the drop pos, fire rockets

        local selfpos2d = self:GetPos()
        local droppos2d = self.DiagonalDrop or self.DropPos

        selfpos2d.z = 0
        droppos2d.z = 0

        if selfpos2d:Distance(droppos2d) < 1000 and not self.BombDropped then
            self.BombDropped = true

            debugoverlay.Sphere(self:GetPos(), 512, 15, Color(255, 0, 255, 0), true)

            local forward = self.DiagonalDrop and self:GetForward() * 3500000 or Vector(0, 0, 0)

            local bomb = ents.Create("pt_attack_bomb")
            bomb:SetPos((self.DiagonalDrop or self.DropPos) - Vector(0, 0, 32) + self:GetRight() * 32)
            bomb:SetAngles(self:GetAngles() + Angle(self.DiagonalDrop and 60 or 90, 0, 0))
            bomb:SetOwner(self:GetOwner())
            bomb:Spawn()

            bomb:GetPhysicsObject():SetVelocityInstantaneous(self:GetRight() * 100000 + self:GetUp() * -5000000 + forward)

            local bomb2 = ents.Create("pt_attack_bomb")
            bomb2:SetPos((self.DiagonalDrop or self.DropPos) - Vector(0, 0, 32) + self:GetRight() * -32)
            bomb2:SetAngles(self:GetAngles() + Angle(self.DiagonalDrop and 60 or 90, 0, 0))
            bomb2:SetOwner(self:GetOwner())
            bomb2:Spawn()

            bomb2:GetPhysicsObject():SetVelocityInstantaneous(self:GetRight() * -100000 + self:GetUp() * -5000000 + forward)

            if self.DiagonalDrop then
                bomb2.TargetPos = self.DropPos
                bomb.TargetPos = self.DropPos
            end

            if self.Bounty then
                bomb.Bounty = self.Bounty * 0.25
                bomb2.Bounty = self.Bounty * 0.25
                self.Bounty = self.Bounty - bomb.Bounty - bomb2.Bounty
                bomb.MarkerID = self.MarkerID
                bomb2.MarkerID = self.MarkerID
            end

            constraint.NoCollide(bomb, bomb2, 0, 0)
            self.AirAssetWeight = -1
        end
    end

    function ENT:OnDestroyed()
        if self.MarkerID and !self.BombDropped then
            Profiteers:KillMarker(self.MarkerID, false)
        end
    end
end