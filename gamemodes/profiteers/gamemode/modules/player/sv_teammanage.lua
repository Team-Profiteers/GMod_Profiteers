util.AddNetworkString("pt_team_update")
-- To SERVER:
-- Update the team you own
-- - Name
-- - Color
-- - Open or not
-- To CLIENT:
-- Update team data
-- - ID
-- - Name
-- - Color
-- - Open or not
util.AddNetworkString("pt_team_join")
-- Try to join a team
-- - Team ID
util.AddNetworkString("pt_team_invite")

-- TO SERVER:
-- Update player invite to team
-- - Player ID
-- - Whether to allow or disallow them
-- TO CLIENT:
-- Update player's invite status to a team
-- - Team ID
-- - Whether they are allowed or not
function Profiteers:CanJoinTeam(ply, p_team)
    if team.Joinable(p_team) then return true end
    if Profiteers.ActiveTeamInvites[p_team] and Profiteers.ActiveTeamInvites[p_team][ply:UserID()] then return true end
    if ply:UserID() == p_team then return true end

    return false
end

function Profiteers:SyncTeams()
    for k, v in pairs(team.GetAllTeams()) do
        if k > 255 then continue end
        net.Start("pt_team_update")
        net.WriteUInt(k, 8)
        net.WriteString(v.Name)
        net.WriteColor(v.Color)
        net.WriteBool(v.Open)
        net.Broadcast(v)
    end
end

net.Receive("pt_team_update", function(len, ply)
    local name = net.ReadString()
    local col = net.ReadColor()
    local open = net.ReadBool()
    local id = ply:UserID()
    if not name then return end
    if string.len(name) > 64 then
        name = string.sub(name, 1, 64)
    end
    if name == "Profiteers" then return end
    team.SetUp(id, name, col, open or false)
    ply:SetTeam(id)
    net.Start("pt_team_update")
    net.WriteUInt(id, 8)
    net.WriteString(name)
    net.WriteColor(col)
    net.WriteBool(open)
    net.Broadcast()
end)

net.Receive("pt_team_invite", function(len, ply)
    local id = net.ReadUInt(8)
    local allow = net.ReadBool()
    local invitee = Player(id)
    if not IsValid(invitee) then return end
    Profiteers.ActiveTeamInvites[ply:UserID()] = Profiteers.ActiveTeamInvites[ply:UserID()] or {}
    if Profiteers.ActiveTeamInvites[ply:UserID()][id] == allow then return end
    Profiteers.ActiveTeamInvites[ply:UserID()][id] = allow
    -- sync to invitee
    net.Start("pt_team_invite")
    net.WriteUInt(ply:UserID(), 8)
    net.WriteBool(allow)
    net.Send(invitee)
end)

net.Receive("pt_team_join", function(len, ply)
    local id = net.ReadUInt(32)
    if not Profiteers:CanJoinTeam(ply, id) then return end
    ply:SetTeam(id)
    GAMEMODE:Hint(ply, 0, 2.5, "You have joined " .. team.GetName(id) .. ".")

    -- Notify all players in the team
    if id ~= TEAM_UNASSIGNED then
        for k, v in pairs(team.GetPlayers(id)) do
            if v ~= ply then
                GAMEMODE:Hint(v, 0, 2.5, ply:Nick() .. " has joined your team!")
            end
        end
    end
end)

hook.Add("PlayerDisconnected", "ProfiteersTeamDisband", function(ply)
    local id = ply:UserID()
    Profiteers:DisbandTeam(id)
end)

function Profiteers:DisbandTeam(teamid)
    if Profiteers.ActiveTeamInvites[id] then
        Profiteers.ActiveTeamInvites[id] = nil
    end

    team.SetUp(id, "", Color(0, 0, 0), false)
end

hook.Add("PlayerCanJoinTeam", "ProfiteersTeamJoin", function(ply, teamid)
    print(teamid)
    if Profiteers:CanJoinTeam(ply, teamid) then return true end

    return false
end)