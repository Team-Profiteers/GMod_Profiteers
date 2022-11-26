local bgmat = Material("profiteers/topshadow.png", "noclamp smooth")

local last_stronk = 0
local nextstronktime = 0

hook.Add("HUDPaint", "Profiteers Enemy Finder", function()
    // draw bg

    local bgw = ScreenScale(200)
    local bgh = bgw / 2
    surface.SetDrawColor(0, 0, 0, 200)
    surface.SetMaterial(bgmat)
    surface.DrawTexturedRect(ScrW() / 2 - bgw / 2, 0, bgw, bgh)

    local stronk = 0

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
                    stronk = stronk + (dot * (15000 / dist))
                end
            end
        end

        stronk = math.max(stronk, 0)

        last_stronk = stronk

        nextstronktime = CurTime() + 0.1
    else
        stronk = last_stronk
    end

    // draw stronk

    local str = tostring(math.Round(stronk, 2))
    surface.SetFont("CGHUD_5")
    local strw = surface.GetTextSize(str)

    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 2 - strw / 2, ScreenScale(2))
    surface.DrawText(str)

    local label = "Radar Return"
    surface.SetFont("CGHUD_8")
    local labelw = surface.GetTextSize(label)

    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 2 - labelw / 2, ScreenScale(14))
    surface.DrawText(label)
end)