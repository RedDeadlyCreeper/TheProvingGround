AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function GM:PlayerInitialSpawn( ply ) --"When the player first joins the server and spawns" function

	local FreeCount = (team.NumPlayers(1))
	local DutyCount = (team.NumPlayers(2))

	if FreeCount < DutyCount then --Unbalanced Teams autobalance free
		ply:SetTeam( 1 )
		ply:Spawn()	
	elseif DutyCount < FreeCount then --Unbalanced Teams autobalance duty
		ply:SetTeam( 2 )
		ply:Spawn()	
	else
		ply:SetTeam( 0 )
		ply:ConCommand( "team_menu" )
	end

	ply:SetModel( "models/player/Group03/Male_0"..math.random(1,9)..".mdl")

end

function GM:PlayerSetModel( ply ) --Double double check
	ply:SetModel( "models/player/Group03/Male_0"..math.random(1,9)..".mdl")
 end

concommand.Add( "team_change", function( ply, cmd, args )

	local FreeCount = (team.NumPlayers(1)) --If I remove the parenthesis the game sometimes reads just the variable 'team' and kills the script
	local DutyCount = (team.NumPlayers(2)) --Honestly I don't know why, its confusing as hell but it happens sometime

	n = math.Round(args[1] or 0,0)
--	print(teams[n].name)

	if not teams[n] then print("Invalid Team") return end

	 if n == 1 and (FreeCount>DutyCount) then --Cannot manually unbalance teams
		chatMessagePly(ply, "Teams cannot be unbalanced. Assigned to Duty" )
		n = 2
	 elseif n == 2 and (DutyCount>FreeCount) then
		chatMessagePly(ply, "Teams cannot be unbalanced. Assigned to Freedom" )
		n = 1
	 end



	ply:SetTeam(n)
	ply:Spawn()	
	ply:SetPlayerColor( teams[n].color)
	ply:SetWeaponColor( teams[n].color )
	
	ply:SetModel( "models/player/Group03m/Male_0"..math.random(1,9)..".mdl")

	print( "["..ply:Nick().. "] has been assigned to team ["..teams[n].name.."]" )
	chatMessagePly(ply, "You have joined team ["..teams[n].name.."]" )	

	if n == 1 then

		ply:SetPos( GameVars.FreedomSpawn )

	elseif n == 2 then

		ply:SetPos( GameVars.DutySpawn )
	
	end

end )

function chatMessagePly( ply , message)
	ply:PrintMessage( HUD_PRINTTALK, message )
end

--IK its inefficient
PrimaryWeaponsTable = {}
PrimaryWeaponsTable[0] = "NoWeapon"
PrimaryWeaponsTable[1] = "m16"
PrimaryWeaponsTable[2] = "ak47"
PrimaryWeaponsTable[3] = "famas"
PrimaryWeaponsTable[4] = "aug"
PrimaryWeaponsTable[5] = "m3super90"
PrimaryWeaponsTable[6] = "xm1014"
PrimaryWeaponsTable[7] = "p90"
PrimaryWeaponsTable[8] = "tmp"
PrimaryWeaponsTable[9] = "awp"
PrimaryWeaponsTable[10] = "scout"
PrimaryWeaponsTable[11] = "m249saw"

SecWeaponsTable = {}
SecWeaponsTable[0] = "NoWeapon"
SecWeaponsTable[1] = "glock"
SecWeaponsTable[2] = "fiveseven"
SecWeaponsTable[3] = "deagle"
SecWeaponsTable[4] = "grenade"
SecWeaponsTable[5] = "weapon_medkit"

SpWeaponsTable = {}
SpWeaponsTable[0] = "NoWeapon"
SpWeaponsTable[1] = "at4"
SpWeaponsTable[2] = "at4t"
SpWeaponsTable[3] = "amr"
SpWeaponsTable[4] = "xm25"
SpWeaponsTable[5] = "mines"



function GM:PlayerLoadout( ply )
	
	ply:Give( "weapon_physgun" )
	ply:Give( "gmod_camera" )

	n = ply:Team()
	ply:SetPlayerColor( teams[n].color )
	ply:SetWeaponColor( teams[n].color )
	
	ply:SetModel( "models/player/Group03/Male_0"..math.random(1,9)..".mdl")

	if n == 1 then

		ply:SetPos( GameVars.FreedomSpawn )

	elseif n == 2 then

		ply:SetPos( GameVars.DutySpawn )
	
	end

--Loadout part

if n == 0 then
	 return true 
end --Neutral shouldn't get weapons

ply:Give( "gmod_tool" ) --Just so people dont dupe before joining a team.

--Default loadout is an m16, no pistol, and an at-4, else set loadout to player sql

PrimWep = ply:GetPData("Baik_PrimeWep", -1)
if PrimWep == -1 then
	ply:SetPData("Baik_PrimeWep",1)
	PrimWep = 1
end

SecWep = ply:GetPData("Baik_SecWep", -1)
if SecWep == -1 then
	ply:SetPData("Baik_SecWep",0)
	SecWep = 0
end

SpecWep = ply:GetPData("Baik_SpecWep", -1)
if SpecWep == -1 then
	ply:SetPData("Baik_SpecWep",1)
	SpecWep = 1
end


local pWepString = PrimaryWeaponsTable[math.floor(PrimWep)]
local sWepString = SecWeaponsTable[math.floor(SecWep)]
local spWepString = SpWeaponsTable[math.floor(SpecWep)]
local hp = 100

if pWepString == "NoWeapon" then hp = hp + 50 else
	ply:Give( pWepString )
end --Adds 50 hp for forgoing a primary weapon

if sWepString == "NoWeapon" then hp = hp + 25 else
	ply:Give( sWepString )
end --Adds 25 hp for forgoing a secondary weapon

if spWepString == "NoWeapon" then hp = hp + 75 elseif spWepString == "mines" then
	ply:Give( "antipersonmine" )
	ply:Give( "boundingmine" )
	ply:Give( "antitankmine" )
else
	ply:Give( spWepString )	
end --Adds 75 hp for forgoing a special weapon

ply:SetHealth(hp)
ply:SetMaxHealth(hp)

--End of loadouts

	return true
end


concommand.Add( "loadout_change", function( ply, cmd, args )
local	wepclass = math.floor(args[1])
local	wid = math.floor(args[2]) --Because sometimes an integer becomes a floating point somehow *shrugs*

--If you manually enter this in console and get a wrong value your stupid and I am not helping you if you enter it wrong.

if wepclass == 1 then
	ply:SetPData("Baik_PrimeWep",wid)
elseif wepclass == 2 then
	ply:SetPData("Baik_SecWep",wid)
elseif wepclass == 3 then
	ply:SetPData("Baik_SpecWep",wid)
end


end )

function TestTeamLims(ArgTable) --Use the same arguments as the original function you're hooking to
local	testplayer = ArgTable[1]["Player"]
local	testteam = testplayer:Team()
local	proplist = ArgTable[1]["EntityList"]

	if testteam == 1 then --Redundant but for deltas, deal with it.
	oldtestprops = GameVars.PropsFreeCount
	oldtestweight = GameVars.WeightFreeCount / 1000
	elseif testteam == 2 then
	oldtestprops = GameVars.PropsDutyCount
	oldtestweight = GameVars.WeightDutyCount / 1000
	end
	updatePropcount()--Update propcount after dupefinish

	if testteam == 1 then --Get propcounts
	testprops = GameVars.PropsFreeCount
	testweight = GameVars.WeightFreeCount / 1000
	elseif testteam == 2 then
	testprops = GameVars.PropsDutyCount
	testweight = GameVars.WeightDutyCount / 1000
	end

	local delweight = (testweight - oldtestweight)
	
	if testprops > GameVars.PropCountMax or testweight > GameVars.WeightLimit then
--		print("OverOnProps")
		chatMessagePly(testplayer, "[Baik2] Contraption deleted due to going over limits" )	
		for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
			ent:Remove()
		end
	
	elseif CurTime() < (GameVars.DupeWaitTime[testplayer] or 0) then

		local waitdelay = GameVars.DupeWaitTime[testplayer]-CurTime()

		chatMessagePly(testplayer, "[Baik2] duplicator on cooldown for ["..math.ceil(waitdelay).."] seconds." )	
		for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
			ent:Remove()
		end

	else
		local spawndelay = delweight*3 --4 seconds per ton, makes 180 second wait for 60t
		GameVars.DupeWaitTime[testplayer] = CurTime() + spawndelay
		chatMessagePly(testplayer, "[Baik2] duplicator on cooldown for ["..math.ceil(spawndelay).."] seconds." )	
	end


--	print("Player: "..testplayer)

	
end
hook.Add("AdvDupe_FinishPasting","BaikPropLimitCleanupHook",TestTeamLims)


--ply:Team()
--updatePropcount()