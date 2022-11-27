util.AddNetworkString("pt_hint")

function GM:Hint(ply, mode, dur, msg)
    if isstring(dur) and msg == nil then
        msg = dur
        dur = nil
    end

    net.Start("pt_hint")
        net.WriteString(msg or "")
        net.WriteUInt(mode or 0, 3)
        net.WriteFloat(dur or 0)
    net.Send(ply)
end

function GM:HintOneTime(ply, mode, dur, msg)
    if isstring(dur) and msg == nil then
        msg = dur
        dur = nil
    end

    if not ply.Hints then ply.Hints = {} end
    local key = string.Replace(string.lower(msg), " ", "")
    if ply.Hints[key] then return end
    self:Hint(ply, mode, dur, msg)
    ply.Hints[key] = true
end