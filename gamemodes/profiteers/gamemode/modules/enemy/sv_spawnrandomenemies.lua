Profiteers.Nodes = nil

local defaultrels = {"ww_frag_thrown D_FR 99", "ww_stun_thrown D_FR 99"}

local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37

local mindist = 2000 * 2000
local maxdist = 6000 * 6000

local function toUShort(b)
    local i = {string.byte(b, 1, SIZEOF_SHORT)}

    return i[1] + i[2] * 256
end

local function toInt(b)
    local i = {string.byte(b, 1, SIZEOF_INT)}

    i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
    if i > 2147483647 then return i - 4294967296 end

    return i
end

local function ReadInt(f)
    return toInt(f:Read(SIZEOF_INT))
end

local function ReadUShort(f)
    return toUShort(f:Read(SIZEOF_SHORT))
end

--Types:
--1 = ?
--2 = info_nodes
--3 = playerspawns
--4 = wall climbers
function ParseNodeFile()
    Profiteers.Nodes = {}
    print("Parsing node file...")
    f = file.Open("maps/graphs/" .. game.GetMap() .. ".ain", "rb", "GAME")
    if not f then return end
    local ainet_ver = ReadInt(f)
    local map_ver = ReadInt(f)

    if ainet_ver ~= AINET_VERSION_NUMBER then
        MsgN("Unknown graph file")

        return
    end

    local numNodes = ReadInt(f)

    if numNodes < 0 then
        MsgN("Graph file has an unexpected amount of nodes")

        return
    end

    for i = 1, numNodes do
        local v = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat())
        local yaw = f:ReadFloat()
        local flOffsets = {}

        for i = 1, NUM_HULLS do
            flOffsets[i] = f:ReadFloat()
        end

        local nodetype = f:ReadByte()
        local nodeinfo = ReadUShort(f)
        local zone = f:ReadShort()
        if nodetype == 4 then continue end
        local node = v
        table.insert(Profiteers.Nodes, node)
    end

    f:Close()
end

local function createEnemyNPC()
    local c = 0

    if not Profiteers.Nodes or table.Count(Profiteers.Nodes) == 0 then
        ParseNodeFile()
    end

    -- print( "Attempted to spawn new batch of NPCs!" )
    for i, k in pairs(ents.GetAll()) do
        if k:IsNPC() then
            c = c + 1
        end
    end

    if c > Profiteers.MaxNPCs then return end
    local a = table.Random(Profiteers.Nodes)

    if not a then
        ParseNodeFile()

        return
    end

    for i, k in pairs(player.GetAll()) do
        local dot = (k:GetPos() - a):GetNormalized():Dot(k:GetAngles():Forward())
        local distSqr = k:GetPos():DistToSqr(a)

        debugoverlay.Sphere(a, 32, 30, Color(255, 255, 255, 0), true)
        debugoverlay.Text((a - k:GetPos()):GetNormalized() * 16, dot)
        debugoverlay.Line(k:GetPos(), a, 30, distSqr >= maxdist and Color(0, 255, 0) or (distSqr <= mindist and Color(255, 0, 0) or Color(255, 255, 0)), true)

        if (distSqr <= mindist) and not (distSqr >= maxdist or (k:GetPos() - a):Dot(k:GetAngles():Forward()) > 0) then return end --k:VisibleVec( a )

        debugoverlay.Sphere(a, 128, 30, Color(0, 255, 0, 0), true)
    end

    local squad = table.Random(Profiteers.Enemies)
    local tospawn = math.random(squad["minsize"], squad["maxsize"])

    for i = 1, tospawn do
        local enemy = ents.Create(squad["class_type"])
        wp = nil

        if squad["wpn"] then
            wp = table.Random(squad["wpn"])
        end

        local va = a
        -- Spawn enemies in a circle
        local ang = i * (360 / tospawn)
        va.x = va.x + math.cos(math.rad(ang)) * 128
        va.y = va.y + math.sin(math.rad(ang)) * 128
        if not enemy:IsValid() then return end
        if util.PointContents(va) == CONTENTS_SOLID or util.PointContents(va + Vector(0, 0, 48)) == CONTENTS_SOLID then return end
        enemy:SetPos(va)
        enemy:SetAngles(Angle(0, math.random(0, 360), 0))
        enemy.ProfiteersSpawned = true

        if squad["model"] then
            enemy:SetModel(squad["model"])
        end

        enemy:Spawn()

        if wp then
            enemy:Give(wp)
        end

        for _, k in pairs(squad["rels"]) do
            enemy:AddRelationship(k)
        end

        -- for i, k in pairs(defaultrels) do
        --     enemy:AddRelationship(k)
        -- end

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
        -- print("Enemy spawned at " .. tostring(a))
    end
end

function GM:OnNPCKilled(npc, atk, inf)
    -- Spawn money entity
    if npc.bounty and npc.PlayerDamaged then
        -- local money = ents.Create("pt_money")
        -- money:SetAngles(AngleRand())
        -- money:SetPos(npc:GetPos())
        -- money:SetAmount(math.Round(npc.bounty * math.Rand(0.9, 1.1)))
        -- money:Spawn()
        if atk:IsPlayer() then
            atk:AddMoney(math.Round(npc.bounty * math.Rand(0.9, 1.1)))
        elseif npc:IsOnFire() and IsValid(npc.PlayerDamaged) then
            -- Combine NPCs with fire death logic attribute kills to themselves
            npc.PlayerDamaged:AddMoney(math.Round(npc.bounty * math.Rand(0.9, 1.1)))
        end
    end
end

timer.Create("Profiteers - Spawn NPCs", 5, 0, function()
    createEnemyNPC()
end)