hook.Add("HUDPaint", "Profiteers Compass", function()
    // Show a linear compass across the top of the screen

    local ply = LocalPlayer()

    local dir = ply:GetAngles().y

    // Draw direction text in top middle

    dir = math.NormalizeAngle(dir)

    // between -180 and 180

    local dir_str = "N"

    if dir >= -22.5 and dir <= 22.5 then
        dir_str = "N"
    elseif dir >= 22.5 and dir <= 67.5 then
        dir_str = "NE"
    elseif dir >= 67.5 and dir <= 112.5 then
        dir_str = "E"
    elseif dir >= 112.5 and dir <= 157.5 then
        dir_str = "SE"
    elseif dir >= 157.5 or dir <= -157.5 then
        dir_str = "S"
    elseif dir >= -157.5 and dir <= -112.5 then
        dir_str = "SW"
    elseif dir >= -112.5 and dir <= -67.5 then
        dir_str = "W"
    elseif dir >= -67.5 and dir <= -22.5 then
        dir_str = "NW"
    end

    draw.SimpleText(dir_str, "DermaLarge", ScrW() / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

end)