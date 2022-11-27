
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

	self.Player:SwitchToDefaultWeapon()
end

function PLAYER:SetModel()
	BaseClass.SetModel( self )

	local skin = self.Player:GetInfoNum( "cl_playerskin", 0 )
	self.Player:SetSkin( skin )

	local groups = self.Player:GetInfo( "cl_playerbodygroups" )
	if ( groups == nil ) then groups = "" end
	local groups = string.Explode( " ", groups )
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

-- Shared
function PLAYER:StartMove( cmd, mv ) end	-- Copies from the user command to the move
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
