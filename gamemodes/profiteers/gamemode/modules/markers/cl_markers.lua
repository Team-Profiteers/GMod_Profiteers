net.Receive("pt_marker_add", function()
    local id = net.ReadUInt(9)
    Profiteers.ActiveMarkers[id] = {}
    Profiteers.ActiveMarkers[id].marker = net.ReadString()
    Profiteers.ActiveMarkers[id].owner = net.ReadEntity()
    Profiteers.ActiveMarkers[id].pos = net.ReadVector()
    Profiteers.ActiveMarkers[id].ent = net.ReadEntity()
    Profiteers.ActiveMarkers[id].timeout = net.ReadFloat()

    if Profiteers.ActiveMarkers[id].pos == Vector(0, 0, 0) then Profiteers.ActiveMarkers[id].pos = nil end
    if Profiteers.ActiveMarkers[id].timeout < 0 then Profiteers.ActiveMarkers[id].pos = nil end
    if !IsValid(Profiteers.ActiveMarkers[id].ent) then Profiteers.ActiveMarkers[id].ent = nil end
    if !IsValid(Profiteers.ActiveMarkers[id].owner) then Profiteers.ActiveMarkers[id].owner = nil end

    if IsValid(Profiteers.ActiveMarkers[id].owner) and Profiteers.ActiveMarkers[id].owner:IsPlayer() then
        Profiteers.ActiveMarkers[id].color = team.GetColor(Profiteers.ActiveMarkers[id].owner:Team())
        Profiteers.ActiveMarkers[id].color.r = Profiteers.ActiveMarkers[id].color.r * 0.5 + 255 * 0.5
        Profiteers.ActiveMarkers[id].color.g = Profiteers.ActiveMarkers[id].color.g * 0.5 + 255 * 0.5
        Profiteers.ActiveMarkers[id].color.b = Profiteers.ActiveMarkers[id].color.b * 0.5 + 255 * 0.5
    else
        Profiteers.ActiveMarkers[id].color = Color(255, 255, 255)
    end
end)

local CLR_B2 = Color(0, 0, 0, 100)

hook.Add("HUDPaint", "Profiteers_Markers", function()
    local ply = LocalPlayer()
    if !IsValid(ply) or !ply:Alive() then return end

    local marker_pos = {}
    cam.Start3D()
        for id, v in pairs(Profiteers.ActiveMarkers) do
            if Profiteers.ActiveMarkers[id].timeout and CurTime() >= Profiteers.ActiveMarkers[id].timeout then
                Profiteers.ActiveMarkers[id].alpha = Lerp((CurTime() - Profiteers.ActiveMarkers[id].timeout) / 3, 1, 0)
                if Profiteers.ActiveMarkers[id].alpha == 0 then
                    Profiteers.ActiveMarkers[id] = nil
                    continue
                end
            end
            if IsValid(v.ent) then
                marker_pos[id] = {v.ent:WorldSpaceCenter(), v.ent:WorldSpaceCenter():ToScreen()}
            elseif v.pos then
                marker_pos[id] = {v.pos, v.pos:ToScreen()}
            end
        end
    cam.End3D()

    local a2 = surface.GetAlphaMultiplier()
    for id, v in pairs(marker_pos) do
        local markertbl = Profiteers.Markers[Profiteers.ActiveMarkers[id].marker]

        local a = Profiteers.ActiveMarkers[id].alpha or 1
        surface.SetAlphaMultiplier(a * a2)

        local ply_dist = EyePos():DistToSqr(v[1])
        local s = math.Clamp(1 - ply_dist / 4096 ^ 2, 0.5, 1) * 64
        local x, y = v[2].x, v[2].y
        local clr = Profiteers.ActiveMarkers[id].color

        local mouse_dist = math.sqrt(math.abs(ScrW() * 0.5 - x) ^ 2 + math.abs(ScrH() * 0.5 - y) ^ 2)
        local mouse_range = CGSS(math.Clamp(1 - ply_dist / 2048 ^ 2, 0.1, 1) * 300)
        if mouse_dist < mouse_range then
            local y2 = y - s / 2 - 2
            if Profiteers.ActiveMarkers[id].owner then
                GAMEMODE:ShadowText(IsValid(Profiteers.ActiveMarkers[id].owner) and Profiteers.ActiveMarkers[id].owner:GetName() or "UNKNOWN", "CGHUD_24_Unscaled", x, y2, clr, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
                y2 = y2 - 22
            end
            GAMEMODE:ShadowText(markertbl.name, "CGHUD_24_Unscaled", x, y2, clr, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
            if Profiteers.ActiveMarkers[id].timeout and CurTime() < Profiteers.ActiveMarkers[id].timeout then
                local tt = string.ToMinutesSeconds(math.max(0, Profiteers.ActiveMarkers[id].timeout - CurTime()))
                GAMEMODE:ShadowText(tt, "CGHUD_24_Unscaled", x, y + s / 2, clr, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true)
            end
        end

        surface.SetDrawColor(clr:Unpack())
        surface.SetMaterial(markertbl.mat)
        surface.DrawTexturedRect(x - s * 0.5, y - s * 0.5, s, s)
    end
    surface.SetAlphaMultiplier(a2)
end)