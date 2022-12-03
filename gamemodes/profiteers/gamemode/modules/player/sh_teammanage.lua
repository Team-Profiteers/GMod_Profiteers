Profiteers.ActiveTeamInvites = {}
// on CLIENT:
// [teamid] = bool allow

// on  SERVER:
// [teamid] = {int userid = bool allow, int userid = bool allow...}

// automatically assign players to TEAM_UNASSIGNED 

hook.Add("PlayerInitialSpawn", "ProfiteersTeamAssign", function(ply)
    ply:SetTeam(TEAM_UNASSIGNED)
    Profiteers:SyncTeams()
end)

// Make changes to base teams at map load

hook.Add("InitPostEntity", "ProfiteersTeamInit", function()
    local col = team.GetColor(TEAM_UNASSIGNED)
    team.SetUp(TEAM_UNASSIGNED, "Profiteers", col, true)
end)