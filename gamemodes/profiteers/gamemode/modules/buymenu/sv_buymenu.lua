util.AddNetworkString("pt_buy")
util.AddNetworkString("pt_sell")
util.AddNetworkString("pt_vehicle")

-- A little hacky function to help prevent spawning props partially inside walls
-- Maybe it should use physics object bounds, not OBB, and use physics object bounds to initial position too
local function fixupProp( ply, ent, hitpos, mins, maxs )
    local entPos = ent:GetPos()
    local endposD = ent:LocalToWorld( mins )
    local tr_down = util.TraceLine( {
        start = entPos,
        endpos = endposD,
        filter = { ent, ply }
    } )

    local endposU = ent:LocalToWorld( maxs )
    local tr_up = util.TraceLine( {
        start = entPos,
        endpos = endposU,
        filter = { ent, ply }
    } )

    -- Both traces hit meaning we are probably inside a wall on both sides, do nothing
    if ( tr_up.Hit and tr_down.Hit ) then return end

    if ( tr_down.Hit ) then ent:SetPos( entPos + ( tr_down.HitPos - endposD ) ) end
    if ( tr_up.Hit ) then ent:SetPos( entPos + ( tr_up.HitPos - endposU ) ) end
end

local function TryFixPropPosition( ply, ent, hitpos )
    fixupProp( ply, ent, hitpos, Vector( ent:OBBMins().x, 0, 0 ), Vector( ent:OBBMaxs().x, 0, 0 ) )
    fixupProp( ply, ent, hitpos, Vector( 0, ent:OBBMins().y, 0 ), Vector( 0, ent:OBBMaxs().y, 0 ) )
    fixupProp( ply, ent, hitpos, Vector( 0, 0, ent:OBBMins().z ), Vector( 0, 0, ent:OBBMaxs().z ) )
end

net.Receive("pt_buy", function(len, ply)
    local itemclass = net.ReadString()
    local itemtbl = Profiteers.Buyables[itemclass]
    if not itemtbl then return end

    if ply:GetMoney() < (itemtbl.Price or 0) then
        return
    end
    if itemtbl.EntityClass and ply:HasWeapon(itemtbl.EntityClass) and not itemtbl.AmmoOnRebuy then
        return
    end
    if itemtbl.CanBuy and not itemtbl:CanBuy(ply) then
        return
    end
    if itemtbl.EntityLimit and itemtbl.EntityLimit <= ply:CountBoughtEntities(itemclass) then
        return
    end
    if ply:IsOnShopCooldown(itemclass) then
        return
    end

    local ent = nil

    if itemtbl.EntityClass and not ply:HasWeapon(itemtbl.EntityClass) then
        if itemtbl.PlaceEntity then
            local vStart = ply:GetShootPos()
            local vForward = ply:GetAimVector()

            local trace = {}
            trace.start = vStart
            trace.endpos = vStart + ( vForward * 2048 )
            trace.filter = ply

            local tr = util.TraceLine( trace )

            -- Prevent spawning too close
            --[[if ( !tr.Hit || tr.Fraction < 0.05 ) then
                return
            end]]

            ent = ents.Create( itemtbl.EntityClass )
            if not IsValid( ent ) then return end

            local ang = ply:EyeAngles()
            ang.yaw = ang.yaw + 180 -- Rotate it 180 degrees in my favour
            ang.roll = 0
            ang.pitch = 0

            if ent.PreferredAngle then ang = ang - ent.PreferredAngle end

            ent:SetAngles( ang )
            ent:SetPos( tr.HitPos )
            ent:Spawn()

            ent:CPPISetOwner(ply)

            ent.Bounty = ent.Bounty or itemtbl.Price

            ent.DisableDuplicator = true
            ent.DoNotDuplicate = true

            ply.BoughtEntities = ply.BoughtEntities or {}
            ply.BoughtEntities[itemclass] = ply.BoughtEntities[itemclass] or {}
            table.insert(ply.BoughtEntities[itemclass], ent)

            -- Attempt to move the object so it sits flush
            -- We could do a TraceEntity instead of doing all
            -- of this - but it feels off after the old way
            local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	-- Find a point that is definitely out of the object in the direction of the floor
            vFlushPoint = ent:NearestPoint( vFlushPoint )			-- Find the nearest point inside the object to that point
            vFlushPoint = ent:GetPos() - vFlushPoint				-- Get the difference
            vFlushPoint = tr.HitPos + vFlushPoint					-- Add it to our target pos

            ent:SetPos( vFlushPoint )

            TryFixPropPosition( ply, ent, tr.HitPos )
        else
            ply:Give(itemtbl.EntityClass) -- this actually also works for entities (places it at user's position)
        end
    elseif itemtbl.AmmoOnRebuy then
        ply:GiveAmmo(itemtbl.AmmoOnRebuyAmount, itemtbl.AmmoOnRebuy)
    end

    if itemtbl.OnBuy then
        itemtbl:OnBuy(ply)
    end

    ply:AddMoney(-itemtbl.Price)
    ply:EmitSound("items/ammopickup.wav", 70)

    net.Start("pt_buy")
        net.WriteUInt(IsValid(ent) and ent:EntIndex() or 0, 16)
        net.WriteString(itemclass)
    net.Send(ply)

    ply:SetShopCooldown(itemclass)
end)

local Player = FindMetaTable("Player")
function Player:SellEntities(class)
    local itemtbl = Profiteers.Buyables[class]
    if not itemtbl then return end
    local money = 0
    self.BoughtEntities = self.BoughtEntities or {}
    for i, ent in pairs(self.BoughtEntities[class] or {}) do
        if IsValid(ent) then
            if ent:GetClass() == "pt_nuke" then
                money = money + itemtbl.Price * GetConVar("pt_money_nukemult"):GetFloat()
            else
                money = money + itemtbl.Price * GetConVar("pt_money_sellmult"):GetFloat()
            end
            if ent.OnPropDestroyed then
                ent:OnPropDestroyed(DamageInfo())
            end
            ent:Remove()
        end
    end
    if money > 0 then
        self:AddMoney(money)
    end
end

net.Receive("pt_sell", function(len, ply)
    local itemclass = net.ReadString()
    local itemtbl = Profiteers.Buyables[itemclass]
    if not itemtbl or not itemtbl.PlaceEntity then return end
    if itemtbl.CannotSell then return end

    ply:SellEntities(itemclass)
end)