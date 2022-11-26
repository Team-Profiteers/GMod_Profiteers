Profiteers.Enemies = {}

Profiteers.Enemies["Combine Soldiers"] = {
    ["class_type"] = "npc_combine_s",
    ["hp"] = 100,
    ["prof"] = WEAPON_PROFICIENCY_AVERAGE,
    ["wpn"] = {"weapon_ar2", "weapon_smg1", "weapon_shotgun"},
    ["squad"] = 1,
    ["minsize"] = 1,
    ["maxsize"] = 3,
    ["rels"] = {"npc_metropolice D_HT 40", "npc_stalker D_HT 50", "npc_manhack D_FR 80", "npc_hunter D_FR 90"},
    ["bounty"] = 500,
}

Profiteers.Enemies["Cops"] = { 
    ["class_type"] = "npc_metropolice",
    ["hp"] = 85,
    ["prof"] = WEAPON_PROFICIENCY_POOR,
    ["wpn"] = {"weapon_smg1", "weapon_pistol"},
    ["squad"] = 2,
    ["minsize"] = 1,
    ["maxsize"] = 5,
    ["rels"] = {"npc_combine_s D_FR 40", "CombinePrison D_FR 60", "npc_stalker D_HT 50", "npc_manhack D_FR 90", "npc_hunter D_FR 90"},
    ["bounty"] = 150,
}

Profiteers.Enemies["Zombies"] = { 
    ["class_type"] = "npc_zombie",
    ["hp"] = 150,
    ["prof"] = WEAPON_PROFICIENCY_POOR,
    ["wpn"] = nil,
    ["squad"] = 5,
    ["minsize"] = 4,
    ["maxsize"] = 12,
    ["rels"] = {""},
    ["bounty"] = 500,
}