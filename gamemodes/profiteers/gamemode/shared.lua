DEFINE_BASECLASS( "gamemode_base" )

GM.Name 	= "Profiteers"
GM.Author 	= "Team Profiteers"
GM.Email 	= "888888zombies@gmail.com"
GM.Website 	= "https://github.com/Team-Profiteers/GMod_Profiteers"

Profiteers = {}

DeriveGamemode("sandbox")

-- Load modules
local path = GM.FolderName .. "/gamemode/modules/"
local modules, folders = file.Find(path .. "*", "LUA")

for _, v in ipairs(modules) do
    if string.GetExtensionFromFilename(v) ~= "lua" then continue end
    include(path .. v)
end

for _, folder in SortedPairs(folders, false) do
    if folder == "." or folder == ".." then continue end

    -- Shared modules
    for _, f in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), false) do
        AddCSLuaFile(path .. folder .. "/" .. f)
        include(path .. folder .. "/" .. f)
    end

    -- Server modules
    if SERVER then
        for _, f in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), false) do
            include(path .. folder .. "/" .. f)
        end
    end

    -- Client modules
    for _, f in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), false) do
        AddCSLuaFile(path .. folder .. "/" .. f)

        if CLIENT then
            include(path .. folder .. "/" .. f)
        end
    end
end

-- vgui
local path_vgui = GM.FolderName .. "/gamemode/vgui/"
for _, f in SortedPairs(file.Find(path_vgui .. "*.lua", "LUA"), false) do
    AddCSLuaFile(path_vgui .. f)

    if CLIENT then
        include(path_vgui .. f)
    end
end

include("player_class/player_pf.lua")


function GM:PostGamemodeLoaded()
    BaseClass.PostGamemodeLoaded(self)

    if SERVER then
        GAMEMODE:GenerateRandomWeaponLists()
    end

    physenv.SetPerformanceSettings({
        MaxVelocity = 1000000
    })
end