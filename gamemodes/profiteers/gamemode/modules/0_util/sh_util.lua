local CLR_B = Color(0, 0, 0, 255)

function GM:ShadowText(text, font, x, y, color, color2, t, l, glow)
    draw.SimpleText(text, font .. "_Shadow", x + CGSS(4), y + CGSS(4), color2, t, l)

    if glow then
        draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
        draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
    end

    draw.SimpleText(text, font, x, y, color, t, l)
end

local threshold = {
    {1e12, "t", 1e12},
    {1e9, "b", 1e9},
    {1e6, "m", 1e6},
    {1e5, "k", 1e3},
}
local threshold_short = {
    {1e11, "t", 1e12},
    {1e8, "b", 1e9},
    {1e5, "m", 1e6},
    {1e3, "k", 1e3}
}

function GM:FormatMoney(amt, short)
    for _, v in ipairs(short and threshold_short or threshold) do
        if math.Round(amt / v[3]) >= v[1] / v[3] then
            return "$" .. math.Round(amt / v[3], short and 1 or 2) .. v[2]
        end
    end
    return "$" .. amt
end

function CGSS(size)
    return size * (ScrH() / 720)
end

function GM:ParsePlayerName(str)
    local candidate = nil
    str = string.lower(str)
    for _, ply in pairs(player.GetAll()) do
        local name = string.lower(ply:GetName())
        if name == str or ply:SteamID() == str or ply:SteamID64() == str then return ply end
        if string.find(name, str) then
            if candidate then
                return false -- ambigious
            else
                candidate = ply
            end
        end
    end
    return candidate
end

function GM:CalculateProjectilePitch(v, d, h)
    local g = -physenv.GetGravity().z
    --v = v * 0.8 -- Our physics function doesn't perfectly align at long distances, so just compensate for it a little

    local term = (v ^ 4 - g * (g * d ^ 2 + 2 * h * v ^ 2)) ^ 0.5
    return math.atan2(v ^ 2 - term, g * d) / math.pi * 180, math.atan2(v ^ 2 + term, g * d) / math.pi * 180
end