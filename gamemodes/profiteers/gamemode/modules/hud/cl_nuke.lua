local nukemat = Material("profiteers/nuke.png", "smooth nomips")

hook.Add("HUDPaint", "Profiteers Nuke Warning", function()
    local nuke = Profiteers.ActiveNuke

    if !nuke or !IsValid(nuke) then return end

    if !nuke:GetArmed() then return end

    local armtime = nuke:GetArmTime()
    local dettime = nuke.DetonationTime

    local timeleft = dettime - (CurTime() - armtime)

    local text = "T-" .. tostring(math.ceil(timeleft))

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_2")
    surface.SetTextPos(ScreenScale(48), ScreenScale(12))
    surface.DrawText(text)

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_6")
    surface.SetTextPos(ScreenScale(48), ScreenScale(4))
    surface.DrawText("ALERT ALERT ALERT")

    local owner = nuke:GetOwner()
    local name = "UNKNOWN"

    if IsValid(owner) then
        name = owner:Nick()
        name = string.upper(name)
    end

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_6")
    surface.SetTextPos(ScreenScale(48), ScreenScale(36))
    surface.DrawText(name .. " ARMED NUCLEAR DEVICE")

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nukemat)
    surface.DrawTexturedRectRotated(ScreenScale(24), ScreenScale(24), ScreenScale(32), ScreenScale(32), CurTime() * 360)
end)