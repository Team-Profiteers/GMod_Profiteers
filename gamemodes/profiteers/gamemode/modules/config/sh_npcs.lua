Profiteers.Enemies = {}

Profiteers.Enemies["Combine Elites"] = {
	["class_type"] = "npc_combine_s",
	["model"] = "models/combine_super_soldier.mdl",
	["hp"] = 500,
	["prof"] = WEAPON_PROFICIENCY_PERFECT,
	["wpn"] = {"weapon_ar2", "weapon_crossbow", "weapon_shotgun"},
	["squad"] = 1,
	["minsize"] = 4,
	["maxsize"] = 6,
	["rels"] = {"npc_metropolice D_HT 40", "npc_stalker D_HT 50", "npc_manhack D_FR 80", "npc_hunter D_FR 90"},
	["bounty"] = 17500,
	["dmgmult"] = 3
}

Profiteers.Enemies["Combine Guards"] = {
	["class_type"] = "npc_combine_s",
	["model"] = "models/combine_soldier_prisonguard.mdl",
	["hp"] = 200,
	["prof"] = WEAPON_PROFICIENCY_VERY_GOOD,
	["wpn"] = {"weapon_ar2", "weapon_smg", "weapon_shotgun"},
	["squad"] = 1,
	["minsize"] = 6,
	["maxsize"] = 10,
	["rels"] = {"npc_metropolice D_HT 40", "npc_stalker D_HT 50", "npc_manhack D_FR 80", "npc_hunter D_FR 90"},
	["bounty"] = 10000,
	["dmgmult"] = 2
}

Profiteers.Enemies["Combine Soldiers"] = {
	["class_type"] = "npc_combine_s",
	["hp"] = 100,
	["prof"] = WEAPON_PROFICIENCY_AVERAGE,
	["wpn"] = {"weapon_ar2", "weapon_smg1", "weapon_shotgun"},
	["squad"] = 1,
	["minsize"] = 6,
	["maxsize"] = 10,
	["rels"] = {"npc_metropolice D_HT 40", "npc_stalker D_HT 50", "npc_manhack D_FR 80", "npc_hunter D_FR 90"},
	["bounty"] = 7500,
	["dmgmult"] = 2
}

Profiteers.Enemies["Cops"] = { 
	["class_type"] = "npc_metropolice",
	["hp"] = 85,
	["prof"] = WEAPON_PROFICIENCY_POOR,
	["wpn"] = {"weapon_smg1", "weapon_pistol"},
	["squad"] = 2,
	["minsize"] = 10,
	["maxsize"] = 15,
	["rels"] = {"npc_combine_s D_FR 40", "CombinePrison D_FR 60", "npc_stalker D_HT 50", "npc_manhack D_FR 90", "npc_hunter D_FR 90"},
	["bounty"] = 5000,
	["dmgmult"] = 1.5
}

Profiteers.Enemies["Zombies"] = { 
	["class_type"] = "npc_zombie",
	["hp"] = 500,
	["prof"] = WEAPON_PROFICIENCY_POOR,
	["wpn"] = nil,
	["squad"] = 5,
	["minsize"] = 5,
	["maxsize"] = 10,
	["rels"] = {""},
	["bounty"] = 8000,
	["dmgmult"] = 5
}

Profiteers.Enemies["Antlions"] = { 
	["class_type"] = "npc_antlion",
	["hp"] = 100,
	["prof"] = WEAPON_PROFICIENCY_POOR,
	["wpn"] = nil,
	["squad"] = 6,
	["minsize"] = 6,
	["maxsize"] = 7,
	["rels"] = {""},
	["bounty"] = 8500,
	["dmgmult"] = 2.5
}

Profiteers.MaxNPCs = 50