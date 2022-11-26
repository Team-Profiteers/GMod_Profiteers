hook.Add("PhysgunDrop", "Profiteers_PropTrack", function(ply, ent)
    ply.PhysgunProp = nil
end)

hook.Add("PhysgunPickup", "Profiteers_PropTrack", function(ply, ent)
    ply.PhysgunProp = ent
end)