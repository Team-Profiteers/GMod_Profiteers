CreateClientConVar("pt_team_update_name", "")
CreateClientConVar("pt_team_update_col_r", "255")
CreateClientConVar("pt_team_update_col_g", "255")
CreateClientConVar("pt_team_update_col_b", "255")
CreateClientConVar("pt_team_update_open", "")

Profiteers.InvitedToTeam = {}

function Profiteers:CanJoinTeam(ply, p_team)
    if team.Joinable(p_team) then return true end

    if Profiteers.ActiveTeamInvites[p_team] then
        return true
    end

    if ply:UserID() == p_team then return true end // this is YOUR team

    return false
end

net.Receive("pt_team_update", function(len, ply)
    local id = net.ReadUInt(8)
    local name = net.ReadString()
    local col = net.ReadColor()
    local open = net.ReadBool()

    team.SetUp(id, name, col, open or false)

end)

net.Receive("pt_team_invite", function(len, ply)
    local p_team = net.ReadUInt(8)
    local allow = net.ReadBool()
    Profiteers.ActiveTeamInvites[p_team] = allow
end)

concommand.Add("pt_team_update", function(ply, cmd, args)
    local name = GetConVar("pt_team_update_name"):GetString()
    local col = Color(GetConVar("pt_team_update_col_r"):GetInt(), GetConVar("pt_team_update_col_g"):GetInt(), GetConVar("pt_team_update_col_b"):GetInt())
    local open = GetConVar("pt_team_update_open"):GetBool()

    if !name then return end
    name = string.Trim(name)
    // limit to 64 characters
    if string.len(name) > 64 then
        name = string.sub(name, 1, 64)
    end

    net.Start("pt_team_update")
    net.WriteString(name)
    net.WriteColor(col)
    net.WriteBool(open)
    net.SendToServer()
end)

concommand.Add("pt_team_invite", function(ply, cmd, args)
    local playerid = tonumber(args[1])
    local allow = tobool(tonumber(args[2]))
    net.Start("pt_team_invite")
    net.WriteUInt(playerid, 8)
    net.WriteBool(allow)
    net.SendToServer()

    Profiteers.InvitedToTeam[playerid] = allow
end)

concommand.Add("pt_team_join", function(ply, cmd, args)
    local id = tonumber(args[1])
    if not id then return end
    if not Profiteers:CanJoinTeam(ply, id) then return end

    net.Start("pt_team_join")
    net.WriteUInt(id, 32)
    net.SendToServer()
end)

hook.Add("AddToolMenuTabs", "ProfiteersTeamMenu", function()
    spawnmenu.GetToolMenu("Profiteers", "Profiteers", "icon16/heart.png")
end)

hook.Add("AddToolMenuCategories", "ProfiteersTeamMenu", function()
    spawnmenu.AddToolCategory("Profiteers", "Teams", "Teams")
end)

hook.Add("PopulateToolMenu", "ProfiteersTeamMenu", function()
    spawnmenu.AddToolMenuOption("Profiteers", "Teams", "Join", "Join", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Join a team")

        local teamlist = vgui.Create("DListView", panel)
        teamlist:SetMultiSelect( false )
        teamlist:AddColumn("Team")
        teamlist:AddColumn("Open")
        teamlist:AddColumn("Invited")
        teamlist:SetTall(300)

        panel:AddItem(teamlist)

        local function refreshlistview()
            teamlist:Clear()
            local teams = team.GetAllTeams()

            for k, v in pairs(teams) do
                if not v.Name then continue end
                if k == TEAM_SPECTATOR then continue end
                if k == TEAM_CONNECTING then continue end
                print(k)
                local l = teamlist:AddLine(v.Name, v.Joinable and "Yes" or "No", Profiteers.ActiveTeamInvites[k] and "Yes" or "No")
                l.ID = k
            end
        end

        function teamlist:DoDoubleClick(lineid, line)
            RunConsoleCommand("pt_team_join", line.ID)
        end

        refreshlistview()

        local joinbtn = panel:Button("Join")
        joinbtn.DoClick = function()
            local line = teamlist:GetSelectedLine()
            if not line then return end
            local id = teamlist:GetLine(line).ID
            RunConsoleCommand("pt_team_join", id)
        end

        local refreshbtn = panel:Button("Refresh")
        refreshbtn.DoClick = function()
            refreshlistview()
        end
    end)

    spawnmenu.AddToolMenuOption("Profiteers", "Teams", "Create/Update", "Create/Update", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Make a new team or update your existing team")

        RunConsoleCommand("pt_team_update_team", teamname)

        panel:TextEntry("Name", "pt_team_update_name")

        local colorpicker = vgui.Create("DColorMixer")
        colorpicker:SetPalette(true)
        colorpicker:SetAlphaBar(false)
        colorpicker:SetWangs(true)
        colorpicker:SetColor(Color(GetConVar("pt_team_update_col_r"):GetInt(), GetConVar("pt_team_update_col_g"):GetInt(), GetConVar("pt_team_update_col_b"):GetInt()))
        colorpicker.ValueChanged = function(self, col)
            RunConsoleCommand("pt_team_update_col_r", col.r)
            RunConsoleCommand("pt_team_update_col_g", col.g)
            RunConsoleCommand("pt_team_update_col_b", col.b)
        end

        panel:AddItem(colorpicker)

        local randombtn = panel:Button("Random Color")

        randombtn.DoClick = function()
            local col = ColorRand()
            colorpicker:SetColor(col)
            RunConsoleCommand("pt_team_update_col_r", col.r)
            RunConsoleCommand("pt_team_update_col_g", col.g)
            RunConsoleCommand("pt_team_update_col_b", col.b)
        end

        panel:CheckBox("Open To Anyone", "pt_team_update_open")

        panel:Button("Create/Update", "pt_team_update")

        panel:Help("This will join your team if you are not already in it")
    end)

    spawnmenu.AddToolMenuOption("Profiteers", "Teams", "Invite", "Invite", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Allow players to join your team")

        local playerlist = vgui.Create("DListView", panel)
        playerlist:SetMultiSelect( false )
        playerlist:AddColumn("Name")
        playerlist:AddColumn("Invited")
        playerlist:SetTall(300)

        panel:AddItem(playerlist)

        local function refreshlistview()
            playerlist:Clear()
            local players = player.GetAll()

            for k, v in pairs(players) do
                if v == LocalPlayer() then continue end
                local l = playerlist:AddLine(v:Nick(), Profiteers.InvitedToTeam[v:UserID()] and "Yes" or "No")
                l.ID = v:UserID()
            end
        end

        refreshlistview()

        local invitebtn = panel:Button("Allow")
        invitebtn.DoClick = function()
            local line = playerlist:GetSelectedLine()
            if not line then return end
            local id = playerlist:GetLine(line).ID
            RunConsoleCommand("pt_team_invite", id, 1)

            timer.Simple(0.1, function()
                refreshlistview()
            end)
        end

        local denybtn = panel:Button("Deny")
        denybtn.DoClick = function()
            local line = playerlist:GetSelectedLine()
            if not line then return end
            local id = playerlist:GetLine(line).ID
            RunConsoleCommand("pt_team_invite", id, 0)

            timer.Simple(0.1, function()
                refreshlistview()
            end)
        end

        local refreshbtn = panel:Button("Refresh")
        refreshbtn.DoClick = function()
            refreshlistview()
        end
    end)
end)