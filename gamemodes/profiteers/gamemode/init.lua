DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

include("sv_events.lua")
include("sh_maps.lua")

AddCSLuaFile("sh_maps.lua")

Profiteers = {}