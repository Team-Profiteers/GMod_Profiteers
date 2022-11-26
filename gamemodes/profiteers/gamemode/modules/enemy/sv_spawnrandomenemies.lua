

Profiteers.Nodes = nil


local defaultrels = {"ww_frag_thrown D_FR 99",
                     "ww_stun_thrown D_FR 99"}

local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37
local function toUShort(b)
    local i = {string.byte(b,1,SIZEOF_SHORT)}
    return i[1] + i[2] * 256
end
local function toInt(b)
    local i = {string.byte(b,1,SIZEOF_INT)}
    i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
    if (i > 2147483647) then return i -4294967296 end
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
    Profiteers.Nodes = {}

    if found_ain then
        return
    end

    f = file.Open("maps/graphs/" .. game.GetMap() .. ".ain","rb","GAME")
    if (!f) then
        return
    end

    found_ain = true
    local ainet_ver = ReadInt(f)
    local map_ver = ReadInt(f)
    if (ainet_ver != AINET_VERSION_NUMBER) then
        MsgN("Unknown graph file")
        return
    end

    local numNodes = ReadInt(f)
    if (numNodes < 0) then
        MsgN("Graph file has an unexpected amount of nodes")
        return
    end

    for i = 1,numNodes do
        local v = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
        local yaw = f:ReadFloat()
        local flOffsets = {}
        for i = 1, NUM_HULLS do
            flOffsets[i] = f:ReadFloat()
        end
        local nodetype = f:ReadByte()
        local nodeinfo = ReadUShort(f)
        local zone = f:ReadShort()

        if nodetype == 4 then
            continue
        end

        local node = v

        table.insert(Profiteers.Nodes, node)
    end
end

function createEnemyNPC()

    local c = 0

    if !Profiteers.Nodes then
        ParseFile()
    end

    // print( "Attempted to spawn new batch of NPCs!" )

    for i, k in pairs( ents.GetAll() ) do
        if k:IsNPC() then
            c = c + 1
        end
    end

    if c > Profiteers.MaxNPCs then
        return
    end

    local a = table.Random( Profiteers.Nodes )

    if !a then ParseFile() return end

    for i, k in pairs( player.GetAll() ) do
        if (k:GetPos():Distance( a ) < 6500 ) and k:VisibleVec( a ) then
            return
        end
    end

    local squad = table.Random(Profiteers.Enemies)

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
        enemy.ProfiteersSpawned = true

        if squad["model"] then
            enemy:SetModel(squad["model"])
        end

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

        enemy.DamageMult = squad["dmgmult"] or 1

        enemy:Fire("StartPatrolling")
        enemy:Fire("SetReadinessHigh")
        enemy:SetNPCState(NPC_STATE_COMBAT)

        // print("Enemy spawned at " .. tostring(a))
    end
end

function GM:OnNPCKilled( npc, atk, inf )
    // Spawn money entity

    if npc.bounty then
        local money = ents.Create("pt_money")
        money:SetAngles(AngleRand())
        money:SetPos(npc:GetPos())
        money:SetAmount(math.Round(npc.bounty * math.Rand(0.9, 1.1)))
        money:Spawn()
    end
end

timer.Create("Profiteers - Spawn NPCs", 5, 0, function()
    createEnemyNPC()
end)