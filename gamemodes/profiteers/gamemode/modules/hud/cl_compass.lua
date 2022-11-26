local bgmat = Material("profiteers/topshadow.png", "noclamp smooth")

local last_stronk = 0
local last_strink = 0
local nextstronktime = 0
local spikes = {}

hook.Add("HUDPaint", "Profiteers Enemy Finder", function()
    // draw bg

    local bgw = ScreenScale(200)
    local bgh = bgw / 2
    surface.SetDrawColor(0, 0, 0, 200)
    surface.SetMaterial(bgmat)
    surface.DrawTexturedRect(ScrW() / 2 - bgw / 2, 0, bgw, bgh)

    local stronk = 0 -- for NPCs
    local strink = 0 -- for players
    local spikecount = 8

    if nextstronktime < CurTime() then
        // count NPCs in the direction you're looking

        local ents = ents.FindInCone(LocalPlayer():GetShootPos(), LocalPlayer():GetAimVector(), 30000, 0.5)

        for k, v in pairs(ents) do
            if v:IsNPC() or v:IsPlayer() then
                // get dot product
                local dot = LocalPlayer():GetAimVector():Dot((v:GetPos() - LocalPlayer():GetShootPos()):GetNormalized())

                // get dist
                local dist = LocalPlayer():GetShootPos():Distance(v:GetPos())

                // Calculate stronk value based on dot product and distance
                // The closer we are and the more we're looking at the NPC, the higher the value

                if v:IsNPC() then
                    stronk = stronk + (dot * (5000 / dist))
                elseif v:IsPlayer() then
                    strink = strink + (dot * (5000 / dist))
                end
            end
        end

        stronk = math.max(stronk, 0)
        strink = math.max(strink, 0)

        stronk = math.Approach(last_stronk, stronk, FrameTime() * 100)
        strink = math.Approach(last_strink, strink, FrameTime() * 100)

        for i = 1, spikecount do
            local spike = 0

            spike = spike + math.sin((CurTime() + (i * 1.12)) * 10) * ((spikecount / 2) - math.abs((spikecount / 2) - i)) * (stronk / 50)
            spike = spike + math.sin((CurTime() + (i * 1.12) - 4) * 3) * ((spikecount / 2) - math.abs((spikecount / 2) - i)) * (strink / 50)

            spikes[i] = spike
        end

        last_stronk = stronk
        last_strink = strink
        nextstronktime = CurTime() + 0.1
    end

    // draw stronk

    // local str = tostring(math.Round(stronk, 2))
    // surface.SetFont("CGHUD_5")
    // local strw = surface.GetTextSize(str)

    // surface.SetTextColor(255, 255, 255, 255)
    // surface.SetTextPos(ScrW() / 2 - strw / 2, ScreenScale(2))
    // surface.DrawText(str)

    for i, sp in ipairs(spikes) do
        surface.SetDrawColor(255, 255, 255, 255)

        local x = (ScrW() / 2) - ((spikecount / 2) * ScreenScale(4)) + (ScreenScale(4) * i)
        local h = sp * ScreenScale(14)
        local w = ScreenScale(1)
        local y = ScreenScale(14) - h

        surface.DrawRect(x, y, w, h)
    end

    local label = "mmWR Scan"
    surface.SetFont("CGHUD_8")
    local labelw = surface.GetTextSize(label)

    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 2 - labelw / 2, ScreenScale(14))
    surface.DrawText(label)
end)