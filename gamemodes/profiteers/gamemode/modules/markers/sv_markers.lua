util.AddNetworkString("pt_marker_add")
util.AddNetworkString("pt_marker_kill")

Profiteers.CurrentMarkerID = 0

function Profiteers:CreateMarker(name, owner, pos, ent, timeout)
    for i = 1, 512 do
        local id = (Profiteers.CurrentMarkerID + i) % 512
        if id == 0 or Profiteers.ActiveMarkers[id] then continue end

        Profiteers.ActiveMarkers[id] = {
            marker = name,
            owner = owner,
            pos = pos,
            ent = ent,
            timeout = timeout and (CurTime() + timeout),
        }

        Profiteers.CurrentMarkerID = id
        return id
    end
    error("Failed to create marker?")
end

function Profiteers:SendMarker(id, ply)
    local marker = Profiteers.ActiveMarkers[id]
    if !marker then return end

    net.Start("pt_marker_add")
    net.WriteUInt(id, 9)
    net.WriteString(marker.marker)
    net.WriteEntity(marker.owner or NULL)
    net.WriteVector(marker.pos or Vector(0, 0, 0))
    net.WriteEntity(marker.ent or NULL)
    net.WriteFloat(marker.timeout or -1)

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function Profiteers:KillMarker(id, instant)
    local marker = Profiteers.ActiveMarkers[id]
    if !marker then return end

    net.Start("pt_marker_kill")
    net.WriteUInt(id, 9)
    net.WriteBool(instant)
    net.Broadcast()

    Profiteers.ActiveMarkers[id] = nil
end

hook.Add("DoPlayerDeath", "Profiteers_MarkDeath", function(ply, attacker, dmginfo)

    if ply.LastDeathMarkerID then
        Profiteers:KillMarker(ply.LastDeathMarkerID, true)
    end

    local id = Profiteers:CreateMarker("death", ply, ply:GetPos())
    Profiteers:SendMarker(id, ply)
    ply.LastDeathMarkerID = id
end)