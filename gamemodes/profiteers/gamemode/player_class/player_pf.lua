
AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Profiteers Player Class"

PLAYER.SlowWalkSpeed		= 130		-- How fast to move when slow-walking (+WALK)
PLAYER.WalkSpeed			= 220		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.4		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.4		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.4		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight		= true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.MaxArmor				= 100			-- Max armor we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands

--
-- Name: PLAYER:SetupDataTables
-- Desc: Set up the network table accessors
-- Arg1:
-- Ret1:
--
function PLAYER:SetupDataTables()
end

--
-- Name: PLAYER:Init
-- Desc: Called when the class object is created (shared)
-- Arg1:
-- Ret1:
--
function PLAYER:Init()
end

--
-- Name: PLAYER:Spawn
-- Desc: Called serverside only when the player spawns
-- Arg1:
-- Ret1:
--
function PLAYER:Spawn()
    BaseClass.Spawn( self )

    local col = self.Player:GetInfo( "cl_playercolor" )
    self.Player:SetPlayerColor( Vector( col ) )

    local col = Vector( self.Player:GetInfo( "cl_weaponcolor" ) )
    if ( col:Length() < 0.001 ) then
        col = Vector( 0.001, 0.001, 0.001 )
    end
    self.Player:SetWeaponColor( col )
    self.Player:SetupHands()

    self.Player:SetArmor(50)
end

--
-- Name: PLAYER:Loadout
-- Desc: Called on spawn to give the player their default loadout
-- Arg1:
-- Ret1:
--
function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()

    self.Player:Give("weapon_crowbar")
    self.Player:Give("weapon_stunstick")
    self.Player:Give("weapon_physcannon")

    self.Player:Give("gmod_tool")
    self.Player:Give("gmod_camera")
    self.Player:Give("weapon_physgun")

    if table.Count(GAMEMODE.RandomPistolSpawnList or {}) > 0 then
        self.Player:Give(GAMEMODE.RandomPistolSpawnList[math.random(#GAMEMODE.RandomPistolSpawnList)])
    end
    if table.Count(GAMEMODE.RandomPrimarySpawnList or {}) > 0 then
        self.Player:Give(GAMEMODE.RandomPrimarySpawnList[math.random(#GAMEMODE.RandomPrimarySpawnList)])
    end

    self.Player:SwitchToDefaultWeapon()
end

function PLAYER:SetModel()
    BaseClass.SetModel( self )

    local skin = self.Player:GetInfoNum( "cl_playerskin", 0 )
    self.Player:SetSkin( skin )

    local groups = self.Player:GetInfo( "cl_playerbodygroups" )
    if ( groups == nil ) then groups = "" end
    groups = string.Explode( " ", groups )
    for k = 0, self.Player:GetNumBodyGroups() - 1 do
        self.Player:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
    end
end

function PLAYER:Death( inflictor, attacker )
end

-- Clientside only
function PLAYER:CalcView( view ) end		-- Setup the player's view
function PLAYER:CreateMove( cmd ) end		-- Creates the user command on the client
function PLAYER:ShouldDrawLocal() end		-- Return true if we should draw the local player

local sounds = {
    "npc/combine_soldier/gear1.wav",
    "npc/combine_soldier/gear2.wav",
    "npc/combine_soldier/gear3.wav",
    "npc/combine_soldier/gear4.wav",
    "npc/combine_soldier/gear5.wav",
    "npc/combine_soldier/gear6.wav",
}
local up = Vector(0, 0, 1)

-- This is actually SetupMove
function PLAYER:StartMove( mv, cmd )

    local ply = self.Player
    local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    if !ply:IsOnGround() and mv:KeyPressed(IN_JUMP) and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
        local done = false

        -- Retract parachute
        if !done and ply:GetNWBool("pt_parachute") then
            ply:SetNWBool("pt_parachute", false)
            if SERVER then
                ply:EmitSound("profiteers/para_close.wav", 110)
            end
            done = true
        end

        -- Wall climb
        if !done and ply:GetNWFloat("pt_nextclimb", 0) < CurTime() then
            local tr_climb = util.TraceHull({
                start = ply:EyePos(),
                endpos = ply:EyePos() + (ang:Forward() * 16),
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 16),
                filter = ply
            })
            if tr_climb.Hit and !tr_climb.HitSky and tr_climb.HitNormal.z <= 0.75 and tr_climb.HitNormal.z >= -0.75 then
                local forward = ang:Forward()

                local upforce = 400
                local forwardforce = 100

                vel = vel + up * upforce
                vel = vel + forward * forwardforce

                vel.z = math.min(vel.z, 400)

                mv:SetVelocity(vel)

                ply:SetNWFloat("pt_nextclimb", CurTime() + 0.25)
                if SERVER then ply:EmitSound(sounds[math.random(#sounds)]) end
                done = true
            end
        end

        print(math.abs(ang:Forward():Dot(up)))
        -- Wall jump
        if !done and ply:GetNWFloat("pt_nextclimb", 0) < CurTime() and math.abs(ang:Forward():Dot(up)) <= 0.5 then
            local tr_walljump = util.TraceHull({
                start = ply:GetPos(),
                endpos = ply:GetPos() - (ang:Forward() * 48),
                mins = Vector(-8, -8, 0),
                maxs = Vector(8, 8, 8),
                filter = ply
            })

            if tr_walljump.Hit and !tr_walljump.HitSky and tr_walljump.HitNormal.z <= 0.75 and tr_walljump.HitNormal.z >= -0.75 then
                local forward = eyeangles:Forward()

                local upforce = 250
                local forwardforce = 400

                vel = vel + up * upforce
                vel = vel + forward * forwardforce

                vel.z = math.Clamp(vel.z, 0, 200)

                mv:SetVelocity(vel)

                ply:SetNWFloat("pt_nextclimb", CurTime() + 0.5)
                if SERVER then ply:EmitSound("npc/zombie/zombie_hit.wav", 75, math.Rand(102, 107)) end
                done = true
            end
        end

        -- Deploy parachute
        if !done and (ply:GetNWBool("pt_parachute_manual") or ply:GetNWBool("pt_parachute_pending")) and !ply:GetNWBool("pt_parachute") and ply:GetVelocity().z < -200 then
            ply:SetNWBool("pt_parachute", true)
            if SERVER then
                local chute = ents.Create("pt_parachute")
                chute:SetOwner(ply)
                chute:Spawn()
                ply:EmitSound("profiteers/para_open.wav", 110)
            end
            done = true
        end
    end

    -- Parachute slow fall
    if ply:GetNWBool("pt_parachute") then
        vel.z = math.Approach(vel.z, -300, -FrameTime() * 2000)

        vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -50, 150)
        desiredmoveleft = math.Clamp(desiredmoveleft, -50, 50)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)
    elseif ply:GetNWBool("pt_parachute_pending") then
        vel.z = math.max(-1500, vel.z)

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -100, 300)
        desiredmoveleft = math.Clamp(desiredmoveleft, -100, 100)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)

        if ply:GetNWBool("pt_parachute_auto") then
            local tr = util.TraceLine({
                start = ply:GetPos(),
                endpos = ply:GetPos() - Vector(0, 0, 2048),
                mask = MASK_SOLID,
                filter = ply
            })
            if tr.Hit then
                deploy = true
                if SERVER then
                    ply:EmitSound("buttons/blip1.wav", 80, 115)
                end
                ply:SetNWBool("pt_parachute_auto", false)
                ply:SetNWBool("pt_parachute", true)
                if SERVER then
                    local chute = ents.Create("pt_parachute")
                    chute:SetOwner(ply)
                    chute:Spawn()
                    ply:EmitSound("profiteers/para_open.wav", 110)
                end
            end
        end
    end
end


function PLAYER:Move( mv ) end				-- Runs the move (can run multiple times for the same client)
function PLAYER:FinishMove( mv ) end		-- Copy the results of the move back to the Player

function PLAYER:ViewModelChanged( vm, old, new ) end
function PLAYER:PreDrawViewModel( vm, weapon ) end
function PLAYER:PostDrawViewModel( vm, weapon ) end

function PLAYER:GetHandsModel()
    local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
    playermodel = player_manager.TranslatePlayerHands( playermodel )
    return playermodel
end

player_manager.RegisterClass( "player_pf", PLAYER, "player_default" )
