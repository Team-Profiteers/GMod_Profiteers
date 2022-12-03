AddCSLuaFile()
DEFINE_BASECLASS("drive_base")

drive.Register("pt_drive_littlebird", {
    -- -- Calculates the view when driving the entity --
    CalcView = function(self, view)
        --
        -- Use the utility method on drive_base.lua to give us a 3rd person view
        --
        self:CalcView_ThirdPerson(view, 100, 2, {self.Entity})

        view.angles.roll = 0
    end,
    -- -- Called before each move. You should use your entity and cmd to  -- fill mv with information you need for your move.  --
    StartMove = function(self, mv, cmd)
        -- Set observer mode to chase, so the entity will be drawn.
        self.Player:SetObserverMode(OBS_MODE_CHASE)
        --
        -- Update move position and velocity from our entity
        --
        mv:SetOrigin(self.Entity:GetNetworkOrigin())
        mv:SetVelocity(self.Entity:GetAbsVelocity())

        if cmd:KeyDown(IN_JUMP) then
            mv:SetUpSpeed(10000)
        elseif cmd:KeyDown(IN_DUCK) then
            mv:SetUpSpeed(-10000)
        end

        if cmd:KeyDown(IN_FORWARD) then
            mv:SetForwardSpeed(10000)
        elseif cmd:KeyDown(IN_BACK) then
            mv:SetForwardSpeed(-10000)
        end

        if cmd:KeyDown(IN_MOVELEFT) then
            mv:SetSideSpeed(-10000)
        elseif cmd:KeyDown(IN_MOVERIGHT) then
            mv:SetSideSpeed(10000)
        end
    end,
    -- -- Runs the actual move. On the client when there's  -- prediction errors this can be run multiple times. -- You should try to only change mv. --
    Move = function(self, mv)
        local speed = 10 * FrameTime()

        --
        -- Get information from the movedata
        --
        local ang = mv:GetMoveAngles()
        local pos = mv:GetOrigin()
        local vel = mv:GetVelocity()

        ang.p = 0

        vel = vel + ang:Forward() * math.Clamp(mv:GetForwardSpeed(), -1, 1) * speed
        vel = vel + ang:Right() * math.Clamp(mv:GetSideSpeed(), -1, 1) * speed
        vel = vel + ang:Up() * math.Clamp(mv:GetUpSpeed(), -1, 1) * speed

        --
        -- We don't want our velocity to get out of hand so we apply
        -- a little bit of air resistance. If no keys are down we apply
        -- more resistance so we slow down more.
        --
        if math.abs(mv:GetForwardSpeed()) + math.abs(mv:GetSideSpeed()) + math.abs(mv:GetUpSpeed()) < 0.1 then
            vel = vel * 0.90
        else
            vel = vel * 0.99
        end

        --
        -- Add the velocity to the position (this is the movement)
        --
        local newpos = pos + vel

        local tr = util.TraceHull({
            start = pos,
            endpos = newpos,
            mins = Vector(-100, -100, -64),
            maxs = Vector(100, 100, 64),
            filter = {self.Entity, self.Player}
        })

        if tr.Hit then
            newpos = tr.HitPos

            // bounce off

            local normal = tr.HitNormal

            // land on the ground, or bounce off walls

            if normal.z > 0.7 then
                vel.z = 0
            else
                vel = vel - 2 * vel:Dot(normal) * normal
            end
        end

        mv:SetVelocity(vel)
        mv:SetOrigin(newpos)
    end,
    -- -- The move is finished. Use mv to set the new positions -- on your entities/players. --
    FinishMove = function(self, mv)
        --
        -- Update our entity!
        --
        self.Entity:SetNetworkOrigin(mv:GetOrigin())
        self.Entity:SetAbsVelocity(mv:GetVelocity())
        self.Entity:SetAngles(mv:GetMoveAngles())

        --
        -- If we have a physics object update that too. But only on the server.
        --
        if SERVER and IsValid(self.Entity:GetPhysicsObject()) then
            self.Entity:GetPhysicsObject():EnableMotion(true)
            self.Entity:GetPhysicsObject():SetPos(mv:GetOrigin())
            self.Entity:GetPhysicsObject():Wake()
            self.Entity:GetPhysicsObject():EnableMotion(false)
        end
    end,
}, "drive_base")