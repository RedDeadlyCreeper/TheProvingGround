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
		chatMessagePly(ply, "[TPG] Teams cannot be unbalanced. Assigned to The Red Menace" , Color( 255, 0, 0 ) )
		n = 2
	 elseif n == 2 and (DutyCount>FreeCount) then
		chatMessagePly(ply, "[TPG] Teams cannot be unbalanced. Assigned to The Green Terror" , Color( 255, 0, 0 ) )
		n = 1
	 end



	ply:SetTeam(n)
	ply:Spawn()	
	ply:SetPlayerColor( teams[n].color)
	ply:SetWeaponColor( teams[n].color )
	
	ply:SetModel( "models/player/Group03/Male_0"..math.random(1,9)..".mdl")

	print( "["..ply:Nick().. "] has been assigned to team ["..teams[n].name.."]" )
	chatMessagePly(ply, "You have joined team ["..teams[n].name.."]" , Color( 0, 255, 255 ) )	

	if n == 1 then

		ply:SetPos( GameVars.FreedomSpawn )

	elseif n == 2 then

		ply:SetPos( GameVars.DutySpawn )
	
	end

end )

function chatMessagePly( ply , message, color) --In the name of colored chat!

	net.Start( "chatmessage" )
		net.WriteColor( color or Color( 255, 255, 255 ) ) --Must go first
		net.WriteString( message )
	net.Send( ply )
	
	end

function chatMessageGlobal( message, color) --Like chatMessagePly but it just goes to everyone.

	net.Start( "chatmessage" )
		net.WriteColor( color or Color( 255, 255, 255 ) ) --Must go first
		net.WriteString( message )
	net.Broadcast()
		
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
	
	GameVars.PlayerSafezoneTime[ply] = 5
--Loadout part

if n == 0 then
	 return true 
end --Neutral shouldn't get weapons

ply:Give( "gmod_tool" ) --Just so people dont dupe before joining a team.

--Default loadout is an m16, no pistol, and an at-4, else set loadout to player sql

PrimWep = ply:GetPData("Baik_PrimeWep", -1) --If you see this failz, this is the one thing i didnt want to change so servers dont have to overload the SQL file
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
local hp = 75 --75 is lowest hp you get for having all weapon types

if pWepString == "NoWeapon" then hp = hp + 25 else
	ply:Give( pWepString )
end --Adds 50 hp for forgoing a primary weapon

if sWepString == "NoWeapon" then hp = hp + 10 else
	ply:Give( sWepString )
end --Adds 25 hp for forgoing a secondary weapon

if spWepString == "NoWeapon" then hp = hp + 40 elseif spWepString == "mines" then
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
	oldtestprops = GameVars.PropsGreenCount
	oldtestweight = GameVars.WeightGreenCount / 1000
	elseif testteam == 2 then
	oldtestprops = GameVars.PropsRedCount
	oldtestweight = GameVars.WeightRedCount / 1000
	end
	updatePropcount(1)--Update propcount after dupefinish

	if testteam == 1 then --Get propcounts
	testprops = GameVars.PropsGreenCount
	testweight = GameVars.WeightGreenCount / 1000
	elseif testteam == 2 then
	testprops = GameVars.PropsRedCount
	testweight = GameVars.WeightRedCount / 1000
	end

	local delweight = (testweight - oldtestweight)
	local delprops = (testprops - oldtestprops)

	if delweight > 0.5 or delprops > 5 then --Makes 5ts able to spawn with a maxed weightlimit since neither of these should change the weight or proplimit. Also bypasses duplicator cooldown.

	if testprops > GameVars.PropCountMax or testweight > GameVars.WeightLimit then
--		print("OverOnProps")
		chatMessagePly(testplayer, "[TPG] Contraption deleted due to going over limits" , Color( 255, 0, 0 ) )	
		for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
			ent:Remove()
		end
	
	elseif CurTime() < (GameVars.DupeWaitTime[testplayer] or 0) then

		local waitdelay = GameVars.DupeWaitTime[testplayer]-CurTime()

		chatMessagePly(testplayer, "[TPG] Contraption removed. duplicator still on cooldown for ["..math.ceil(waitdelay).."] seconds." , Color( 255, 0, 0 ) )	
		for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
			ent:Remove()
		end

	else
		local spawndelay = delweight*6 --6 seconds per ton, makes 360 second wait for 60t, done to prevent vehicle spam
		GameVars.DupeWaitTime[testplayer] = CurTime() + spawndelay
		chatMessagePly(testplayer, "[TPG] duplicator on cooldown for ["..math.ceil(spawndelay).."] seconds." , Color( 0, 255, 255 ) )	
	end
	
	else --Lightweight vehicle

		chatMessagePly(testplayer, "[TPG] Light vehicle spawned, duplicator cooldown bypassed." , Color( 0, 255, 255 ) )	

	end

--	print("Player: "..testplayer)

	
end
hook.Add("AdvDupe_FinishPasting","TPGPropLimitCleanupHook",TestTeamLims)


--ply:Team()
--updatePropcount()

--[[ Broken
function GM:PostCleanupMap()

	print( "[TPG] Reseting gamemode due to cleanup") 

	local	storespawn = GameVars.FreedomSpawn
	GameVars.FreedomSpawn = GameVars.DutySpawn
	GameVars.DutySpawn = storespawn

	setupGamemode(1) --Tells to ignore cleanup

end
]]--


concommand.Add( "easy_entry", function( ply, cmd, args ) --Yes IK people can move away, but will they honestly do that within 4 seconds and be back by their vehicle? prob not.
	local etr = ply:GetEyeTrace()
	local eowner = etr.Entity:CPPIGetOwner() or nil

	if ply == eowner then --Valid entry, player is owner of entity

		local proplist = GameVars.SeatEntities
		local BestDist = 99999
		local dist = 99999
		local bestEnt = nil
			for id, entry in pairs( proplist ) do --Updates propcount and prop weight of each player
				ent = entry["Ent"]
				if ent:CPPIGetOwner() == eowner then --Owns seat

					dist = (ply:GetPos():Distance( ent:GetPos() )) --Gets distance to seat entity

					if dist < 750 then --Seat is within range of player

						if dist < BestDist then
							BestDist = dist
							bestEnt = ent
						end


					end
	


				end




			end

			if IsValid(bestEnt) then --Enter vehicle in 4 seconds if nearby
				timer.Simple( 4, function() EasyEntry(ply,bestEnt) end )
				chatMessagePly(ply, "[TPG] EasyEntry: Entering vehicle in 4 seconds, DO NOT MOVE." , Color( 0, 255, 255 ) )
			else
				chatMessagePly(ply, "[TPG] EasyEntry: Enterable vehicle not found." , Color( 255, 0, 0 ) )
			end

	end


end)


function EasyEntry(ply,seat)

	dist = (ply:GetPos():Distance( seat:GetPos() ))

	if dist < 750 then --Seat is within range of player

		chatMessagePly(ply, "[TPG] EasyEntry: Succesfully entered vehicle." , Color( 0, 255, 255 ) )
		ply:EnterVehicle( seat )
	else
		chatMessagePly(ply, "[TPG] EasyEntry: Moved away too far from vehicle." , Color( 255, 0, 0 ) )
	end


end


function populateMapChoices() --Fills the map votelist with votemap choices.
--GameVars.VoteMapList


	--Open maps
	local MapList1 = {"gm_emp_palmbay","gm_emp_midbridge","gm_greenchoke","gm_emp_arid","gm_baik_coast_03","gm_baik_coast_03_night","gm_baik_frontline","gm_baik_trenches","gm_baik_valley_split","gm_diprip_village","gm_emp_bush","gm_greenland","gm_islandrain_v3","gm_pacific_island_a3","gm_toysoldiers"}
	local Count1 = table.Count( MapList1 )


	--Urban maps
	local MapList2 = {"gm_emp_manticore","gm_baik_stalingrad","gm_bigcity_improved","gm_diprip_refinery","gm_emp_commandergrad","gm_freedom_city","gm_yanov","gm_baik_construct_draft1","gm_de_port_opened_v2","gm_baik_citycentre_v3"}
	local Count2 = table.Count( MapList2 )

	local Map1 = MapList1[math.random( 1, Count1 )]
	GameVars.VoteMapList[1] = Map1

	local Map2 = MapList1[math.random( 1, Count1 )]	
	GameVars.VoteMapList[2] = Map2

	if Count1 > 1 then --Are there enough maps for us to re-roll?
		while Map2 == Map1 do --No repeating maps for you, more choices for everyone.
			Map2 = MapList1[math.random( 1, Count1 )]	
			GameVars.VoteMapList[2] = Map2
		end
	end

	local Map3 = MapList2[math.random( 1, Count2 )]	
	GameVars.VoteMapList[3] = Map3

	local Map4 = ""
	--Randomly pick between an urban map or open map
	if math.Rand(0,1) > 0.4 then --Urban
		Map4 = MapList2[math.random( 1, Count2 )]	
		GameVars.VoteMapList[4] = Map4

		if Count2 > 1 then --Reroll if more than 2 maps exist in map list 1
			while Map4 ==  Map3 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList2[math.random( 1, Count2 )]	
				GameVars.VoteMapList[4] = Map4
			end
		end
		
	else --Open
		local Map4 = MapList1[math.random( 1, Count1 )]
		GameVars.VoteMapList[4] = Map4

		if Count1 > 2 then --Are there enough maps for us to re-roll?
			while Map4 == Map1 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList1[math.random( 1, Count1 )]
				GameVars.VoteMapList[4] = Map4
			end

			while Map4 == Map2 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList1[math.random( 1, Count1 )]
				GameVars.VoteMapList[4] = Map4
			end
		end

	end

	local allplayers = player.GetAll()
		
	for i, ply in ipairs( player.GetAll() ) do --Fucks given: 0

		ply:SendLua( "GameVars.VoteMapList[1]=\"" .. GameVars.VoteMapList[1] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[2]=\"" .. GameVars.VoteMapList[2] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[3]=\"" .. GameVars.VoteMapList[3] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[4]=\"" .. GameVars.VoteMapList[4] .. "\";" )

	end

	print("Open Map [1]: "..GameVars.VoteMapList[1])
	print("Open Map [2]: "..GameVars.VoteMapList[2])
	print("Urban Map [1]: "..GameVars.VoteMapList[3])
	print("Bonus Map [1]: "..GameVars.VoteMapList[4])

end

GameVars.PlayerVotes = {}
concommand.Add( "tpg_votemap", function( ply, cmd, args )
	GameVars.PlayerVotes[ply] = args[1]
	chatMessageGlobal( "[TPG] "..ply:GetName().." voted for map ("..GameVars.VoteMapList[math.ceil(args[1])]..")" , Color( 0, 0, 255 ) )
end)


function tallyVotes()

	local Votes = {}
	Votes[1] = 0
	Votes[2] = 0
	Votes[3] = 0
	Votes[4] = 0
		
	for i, ply in ipairs( player.GetAll() ) do
		local vote = GameVars.PlayerVotes[ply] 

		if vote == 1 then
			Votes[1] = Votes1 + 1
		elseif vote == 2 then
			Votes[2] = Votes2 + 1
		elseif vote == 3 then
			Votes[3] = Votes3 + 1
		elseif vote == 4 then
			Votes[4] = Votes4 + 1
		end
	end
	bestvote = math.ceil(1) --Change to integer
	votecount = 0

	for I=1, 4 do
		local curvotecount = Votes[I]

		if curvotecount >= votecount then
			votecount = curvotecount
			bestvote = math.ceil(I) --Change to integer
		end

	end

	print(bestvote)
	print(GameVars.VoteMapList[bestvote])


	RunConsoleCommand( "gamemode", "theprovingground" ) --Can never be too cautious
	RunConsoleCommand( "map", GameVars.VoteMapList[bestvote] )

chatMessageGlobal( "[TPG] Changing to map ["..GameVars.VoteMapList[bestvote].."]" , Color( 0, 255, 0 ) )


end



--GameVars.PlayerScoreTrackers = {} -- Holds all of the players in this array,
--[1]Kills, [2]Kills/Ton, [3]Objective kills

hook.Add( "PlayerDeath", "CommendationTracker", function( victim, inflictor, attacker )

	local attackerIsPlayer = attacker:IsPlayer()

	if attackerIsPlayer then --Player killed player
		GameVars.PlayerScoreTrackers[attacker] = GameVars.PlayerScoreTrackers[attacker] or {} --Create if table does not exist

		--Kill tracker
		GameVars.PlayerScoreTrackers[attacker][1] = (GameVars.PlayerScoreTrackers[attacker][1] or 0) + 1

		--Kills/ton tracker
		local plypropinfo = GameVars.PlayerPropInfo[attacker] or {}
		GameVars.PlayerScoreTrackers[attacker][2] = (GameVars.PlayerScoreTrackers[attacker][2] or 0) + (1 / math.max((plypropinfo[1] or 1),1) )

			--Objective kills tracer
			local bestent = nil
			local bestdist = 99999999

			local points = ents.FindByClass( "tpg_controlpoint" )

			for id, ent in pairs( points ) do
				local dist = (victim:GetPos():Distance( ent:GetPos() ))
				if dist < bestdist then
					bestent = dist
					bestent = ent
				end
			end

			if bestdist < 2000 then
				GameVars.PlayerScoreTrackers[attacker][3] = (GameVars.PlayerScoreTrackers[attacker][3] or 0) + 1
			end

			local searchteam = attacker:Team()

			if searchteam == 1 then
				inrange = ((attacker:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
			elseif searchteam == 2 then
				inrange = ((attacker:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
			else
				inrange = 1
			end

			--For people who kill in safezone with a drone.
			if inrange == 1 then
				chatMessagePly(attacker, "[TPG] Do not kill while in safezone." , Color( 255, 0, 0 ) )	
				attacker:Kill()		
				attacker:Spawn()			
			end

	end

end)