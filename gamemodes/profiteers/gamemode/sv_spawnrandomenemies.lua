GM.Enemies = {}

Nodes = Nodes or {}

GM.Enemies["Combine Soldiers"] = {
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

GM.Enemies["Cops"] = { 
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

GM.Enemies["Zombies"] = { 
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

local defaultrels = {"ww_frag_thrown D_FR 99",
                     "ww_stun_thrown D_FR 99"}

local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37
local function toUShort(b)
	local i = {string.byte(b,1,SIZEOF_SHORT)}
	return i[1] +i[2] *256
end
local function toInt(b)
	local i = {string.byte(b,1,SIZEOF_INT)}
	i = i[1] +i[2] *256 +i[3] *65536 +i[4] *16777216
	if(i > 2147483647) then return i -4294967296 end
	return i
end
local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end

--Types:
--1 = ?
--2 = info_nodes
--3 = playerspawns
--4 = wall climbers
function ParseFile()
    if found_ain then
        return
    end

    f = file.Open("maps/graphs/"..game.GetMap()..".ain","rb","GAME")
    if(!f) then
        return
    end

    found_ain = true
    local ainet_ver = ReadInt(f)
    local map_ver = ReadInt(f)
    if(ainet_ver != AINET_VERSION_NUMBER) then
        MsgN("Unknown graph file")
        return
    end

    local numNodes = ReadInt(f)
    if(numNodes < 0) then
        MsgN("Graph file has an unexpected amount of nodes")
        return
    end

    for i = 1,numNodes do
        local v = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
        local yaw = f:ReadFloat()
        local flOffsets = {}
        for i = 1,NUM_HULLS do
            flOffsets[i] = f:ReadFloat()
        end
        local nodetype = f:ReadByte()
        local nodeinfo = ReadUShort(f)
        local zone = f:ReadShort()

        if nodetype == 4 then
            continue
        end

        local node = v

        table.insert(Nodes,node)
    end
end

function createEnemyNPC()

    local c = 0

    print( "Attempted to spawn new batch of NPCs!" )

    for i, k in pairs( ents.GetAll() ) do
    if k:IsNPC() then
        c = c + 1
    end
    end

    if c > 100 then
    return
    end

    local a = table.Random( Nodes )

    local squad = table.Random(GM.Enemies)

    for i = 0,math.random(squad["minsize"],squad["maxsize"]) do
        local enemy = ents.Create(squad["class_type"])
        wp = nil
        if squad["wpn"] then
            wp = table.Random(squad["wpn"])
        end
        local va = a + Vector( math.random(-128, 128), math.random(-128, 128), 16 )
        if !enemy:IsValid() then return end
        if (util.PointContents( va ) == CONTENTS_SOLID or util.PointContents( va + Vector(0, 0, 48) ) == CONTENTS_SOLID )then return end
        enemy:SetPos( va )
        enemy:SetAngles(Angle(0, math.random(0, 360), 0))
        enemy:Spawn()

        if wp then
            enemy:Give( wp )
        end

        for i, k in pairs(squad["rels"]) do
            enemy:AddRelationship( k )
        end

        for i, k in pairs(defaultrels) do
            enemy:AddRelationship( k )
        end

        if squad["bounty"] then
            enemy.bounty = squad["bounty"]
        end

        enemy:SetHealth(squad["hp"])

        enemy:SetMaxHealth(squad["hp"])

        enemy:SetCurrentWeaponProficiency(squad["prof"])

        enemy:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

        enemy:Fire("StartPatrolling")
        enemy:Fire("SetReadinessHigh")
        enemy:SetNPCState(NPC_STATE_COMBAT)

        print("Enemy spawned at "..tostring(a))
    end
end

function GM:OnNPCKilled( npc, atk, inf )

    if npc.bounty and atk:IsPlayer() then
        atk:AddMoney( npc.bounty )
    end

end

ParseFile()