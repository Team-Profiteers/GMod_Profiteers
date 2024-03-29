local bgmat = Material("profiteers/topshadow.png", "noclamp smooth")

local last_stronk = 0
local last_strink = 0
local last_strenk = 0
local nextstronktime = 0
local spikes = {}

hook.Add("HUDPaint", "Profiteers Enemy Finder", function()
    -- draw bg

    local bgw = ScreenScale(200)
    local bgh = bgw / 2
    surface.SetDrawColor(0, 0, 0, 200)
    surface.SetMaterial(bgmat)
    surface.DrawTexturedRect(ScrW() / 2 - bgw / 2, 0, bgw, bgh)

    local stronk = 0 -- for NPCs
    local strink = 0 -- for players
    local strenk = 0 -- for base
    local spikecount = 12

    if nextstronktime < CurTime() then
        -- count stuff (no point in using cone since we're checking for dot and dist anyways)

        for k, v in pairs(ents.GetAll()) do
            if v:IsNPC() or v:IsPlayer() or (v:GetClass() == "pt_beacon") then
                -- get dot product
                local dot = LocalPlayer():GetAimVector():Dot((v:GetPos() - LocalPlayer():GetShootPos()):GetNormalized())

                -- get dist
                local dist = LocalPlayer():GetShootPos():DistToSqr(v:GetPos())

                -- Calculate stronk value based on dot product and distance
                -- The closer we are and the more we're looking at the NPC, the higher the value

                if v:IsNPC() then
                    stronk = stronk + (dot * (5000 * 5000 / dist))
                elseif v:IsPlayer() and v != LocalPlayer() then
                    strink = strink + (dot * (5000 * 5000 / dist))
                elseif v:GetClass() == "pt_beacon" then
                    strenk = strenk + (dot * (5000 * 5000 / dist))
                end
            end
        end

        stronk = math.Clamp(stronk, 0, 25)
        strink = math.Clamp(strink, 0, 25)
        strenk = math.Clamp(strenk, 0, 25)

        stronk = math.Approach(last_stronk, stronk, FrameTime() * 250)
        strink = math.Approach(last_strink, strink, FrameTime() * 250)
        strenk = math.Approach(last_strenk, strenk, FrameTime() * 250)

        for i = 1, spikecount do
            local spike = 0

            spike = spike + math.sin((CurTime() + (i * 1.12)) * 10) * ((spikecount / 2) - math.abs((spikecount / 2) - i)) * (stronk / 50)
            spike = spike + math.sin((CurTime() + (i * 1.12) - 4) * 3) * ((spikecount / 2) - math.abs((spikecount / 2) - i)) * (strink / 50)
            spike = spike + math.sin((CurTime() + (i * 1.12) - 1) * 25) * ((spikecount / 2) - math.abs((spikecount / 2) - i)) * (strenk / 50)

            spikes[i] = spike
        end

        last_stronk = stronk
        last_strink = strink
        last_strenk = strenk
        nextstronktime = CurTime() + 0.2
    end

    -- draw stronk

    -- local str = tostring(math.Round(stronk, 2))
    -- surface.SetFont("CGHUD_5")
    -- local strw = surface.GetTextSize(str)

    -- surface.SetTextColor(255, 255, 255, 255)
    -- surface.SetTextPos(ScrW() / 2 - strw / 2, ScreenScale(2))
    -- surface.DrawText(str)

    for i, sp in ipairs(spikes) do
        surface.SetDrawColor(255, 255, 255, 255)

        local x = (ScrW() / 2) - ((spikecount / 2) * ScreenScale(4)) + (ScreenScale(4) * i)
        local h = sp * ScreenScale(14)
        local w = ScreenScale(1)
        local y = ScreenScale(24) - h

        surface.DrawRect(x, y, w, h)
    end

    local label = "[        Radar Return        ]"
    surface.SetFont("CGHUD_8")
    local labelw = surface.GetTextSize(label)

    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 2 - labelw / 2, ScreenScale(24))
    surface.DrawText(label)
end)