local SCORE_B = Color(0, 0, 0, 127)
local SCORE_W = Color(255, 255, 255, 255)
local SCORE_BG = Color(41 * 1, 46 * 1, 76 * 1, 200)
local SHOWSCORE2 = false
local SCORE_FADE = 0
local dead = Material("tdm/dead.png", "smooth")
local dead_glow = Material("tdm/dead_glow.png", "smooth")

if Pixie then
    Pixie:Remove()
end

Pixie = nil
local pliskin = {}

hook.Add("ScoreboardShow", "TDMScore2_ScoreboardShow", function()
    SHOWSCORE2 = true

    if Pixie then
        Pixie:SetMouseInputEnabled(true)
    end

    return true
end)

hook.Add("ScoreboardHide", "TDMScore2_ScoreboardHide", function()
    SHOWSCORE2 = false

    if Pixie then
        Pixie:SetMouseInputEnabled(false)
    end

    return true
end)

local function ShadowText(text, font, x, y, color, t, l, glow)
    local c = CGSS(1)
    draw.SimpleText(text, font .. "_Shadow", x + (c * 3), y + (c * 3), SCORE_B, t, l)

    if glow then
        draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
        draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
    end

    draw.SimpleText(text, font, x, y, color, t, l)
end

local function ShadowBox(x, y, w, h, color)
    local c = CGSS(1)
    surface.SetDrawColor(SCORE_B)
    surface.DrawRect(x + (c * 3), y + (c * 3), w, h)
    surface.SetDrawColor(color)
    surface.DrawRect(x, y, w, h)
end

hook.Add("HUDDrawScoreBoard", "Profiteers_HUDDrawScoreBoard", function()
    SCORE_FADE = math.Approach(SCORE_FADE, SHOWSCORE2 and 1 or 0, FrameTime() / 0.15)
    SCORE_B.a = Lerp(SCORE_FADE, 0, 127)
    SCORE_W.a = Lerp(SCORE_FADE, 0, 255)
    SCORE_BG.a = Lerp(SCORE_FADE, 0, 200)
    local c = CGSS(1)
    local brd = c * 12
    local bbl = c * 20

    -- Begin
    if SCORE_FADE > 0 then
        if not Pixie then
            -- create "pixie"
            Pixie = vgui.Create("DFrame")
            Pixie:SetSize(ScrW() - (c * 32), ScrH() - (c * 32))
            Pixie:Center()
            Pixie:SetTitle("")
            Pixie:ShowCloseButton(false)
            Pixie:MakePopup()
            Pixie:SetDraggable(false)
            Pixie:SetSizable(false)
            Pixie:SetKeyboardInputEnabled(false)

            function Pixie:Paint(w, h)
                local bog_x, bog_y, bog_w, bog_h = 0, 0, w, h
                draw.RoundedBox(brd, bog_x, bog_y, bog_w, bog_h, SCORE_BG)
                ShadowText(GetHostName(), "CGHUD_3", bog_x + bbl, bog_y + bbl, SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText(game.GetMap(), "CGHUD_5", bog_x + bbl, bog_y + bbl + (c * 34), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                -- Middle bar
                ShadowBox(bog_x + (bog_w * 0.5) - (c * 2 * 0.5), bog_y + bbl, c * 2, bog_h - (bbl * 2), SCORE_W)
                -- Middle left
                ShadowBox(bog_x + bbl, bog_y + (bog_h * 0.5) - (c * 2 * 0.5), (bog_w * 0.5) - (bbl * 2), c * 2, SCORE_W)

                for index, p in ipairs(player.GetAll()) do
                    if not IsValid(pliskin[p]) then
                        local Poncho = vgui.Create("DButton", Pixie)
                        pliskin[p] = Poncho
                        Poncho.Player = p
                        Poncho:SetSize(9999, c * 28)

                        function Poncho:Paint(w, h)
                            --ShadowBox(0, 0, w, h, SCORE_BG)
                            local old = DisableClipping(true)
                            local tc = team.GetColor(self.Player:Team())
                            tc = Color(Lerp(0.5, 255, tc.r), Lerp(0.5, 255, tc.g), Lerp(0.5, 255, tc.b), Lerp(SCORE_FADE, 0, 255))
                            ShadowText(self.Player:Nick(), "CGHUD_5", c * 38, h * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            DisableClipping(old)

                            return true
                        end

                        function Poncho:DoRightClick()
                            local MenuButtonOptions = DermaMenu()
                            MenuButtonOptions:AddOption("hello", function() end)
                            MenuButtonOptions:Open()
                        end

                        local Av = vgui.Create("AvatarImage", Poncho)
                        local ico = c * 28
                        Av:SetPlayer(p, 64)
                        Av:SetSize(ico, ico)
                        Av:SetPos(0, 0 + (Poncho:GetTall() * 0.5) - (ico * 0.5))
                    end
                end

                -- who is invalid
                for i, v in pairs(pliskin) do
                    if not IsValid(v.Player) then
                        v:Remove()
                    end
                end

                local ybump = c * 0
                ShadowText("", "CGHUD_6", bog_x + (bog_w * 0.5) + bbl, bog_y + bbl, SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText("Ping", "CGHUD_6", bog_x + bog_w - bbl - (c * 0), bog_y + bbl, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                ShadowText("Deaths", "CGHUD_6", bog_x + bog_w - bbl - (c * 50), bog_y + bbl, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                ShadowText("Kills", "CGHUD_6", bog_x + bog_w - bbl - (c * 110), bog_y + bbl, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                ShadowText("Cash", "CGHUD_6", bog_x + bog_w - bbl - (c * 160), bog_y + bbl, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

                --ShadowText("Score", "CGHUD_6", bog_x + (bog_w) - bbl	- (c*170), bog_y + bbl, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                for t, teamdata in pairs(team.GetAllTeams()) do
                    local collect = team.GetPlayers(t)

                    if #collect > 0 then
                        local tc = team.GetColor(t)
                        tc = Color(Lerp(0.5, 255, tc.r), Lerp(0.5, 255, tc.g), Lerp(0.5, 255, tc.b), Lerp(SCORE_FADE, 0, 255))
                        ShadowText(teamdata.Name, "CGHUD_5", bog_x + (bog_w * 0.5) + bbl, bog_y + bbl + ybump, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        ybump = ybump + (c * 28)
                        ShadowBox(bog_x + (bog_w * 0.5) + bbl, bog_y + bbl + ybump, (bog_w * 0.5) - (bbl * 2), c * 2, tc)
                        ybump = ybump + (c * 8)

                        -- Draw user info
                        for index, p in ipairs(collect) do
                            --ShadowText(p:Nick(), "CGHUD_5", bog_x + (bog_w*0.5) + bbl, bog_y + bbl + ybump, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            if pliskin[p] then
                                local bas = pliskin[p]
                                bas:SetPos(bog_x + (bog_w * 0.5) + bbl, bog_y + bbl + ybump)
                            end

                            ShadowText(p:Ping(), "CGHUD_6", bog_x + bog_w - bbl - (c * 0), bog_y + bbl + ybump, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            ShadowText(p:Deaths(), "CGHUD_6", bog_x + bog_w - bbl - (c * 50), bog_y + bbl + ybump, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            ShadowText(p:Frags(), "CGHUD_6", bog_x + bog_w - bbl - (c * 110), bog_y + bbl + ybump, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            ShadowText("$" .. tostring(p:GetMoney()), "CGHUD_6", bog_x + bog_w - bbl - (c * 160), bog_y + bbl + ybump, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            --ShadowText("0", "CGHUD_6", bog_x + (bog_w) - bbl - (c*170), bog_y + bbl + ybump, SCORE_W, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            -- Bump y
                            ybump = ybump + (c * 30)
                        end
                    end
                end

                ShadowText("How to Play?", "CGHUD_5", bog_x + bbl + (c * 2), bog_y + (bog_h * 0.5) + bbl, SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText("IT'S SIMPLE!", "CGHUD_2", bog_x + bbl, bog_y + (bog_h * 0.5) + bbl + (c * 18), Color(255, 50, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText("1. Kill NPCs", "CGHUD_5", bog_x + bbl + (c * 8), bog_y + (bog_h * 0.5) + bbl + (c * 62), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText("2. Get money", "CGHUD_5", bog_x + bbl + (c * 8), bog_y + (bog_h * 0.5) + bbl + (c * 84), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                ShadowText("3. Buy a nuke", "CGHUD_5", bog_x + bbl + (c * 8), bog_y + (bog_h * 0.5) + bbl + (c * 106), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end
    else
        if Pixie then
            Pixie:Remove()
            Pixie = nil
        end
    end
end)