local MapName = game.GetMap()

GameVars.DutySpawn = Vector(0,0,0)
GameVars.FreedomSpawn = Vector(0,0,0)
GameVars.PointCount = 0
GameVars.PointEntities = {}
local PointPositions = {}--Most point information is temporary
local PointNames = {}

GameVars.WeightLimit = 120 --WeightLimit in metric tons (1000kg)
GameVars.CapMul = 0.015 --Feel free to override this in map setup
GameVars.PropCountMax = 300 --Feel free to override this in map setup

GameVars.SZRadius = 750 --Radius of safezones around spawns in units

if MapName == "gm_construct" then

	GameVars.FreedomSpawn = Vector(727,548,-143)
	GameVars.DutySpawn = Vector(-4970,-3434,251)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 1 --Feel free to override this in map setup
	GameVars.SZRadius = 750
	PointPositions = {Vector(-2563,-1217,240),Vector(-2563,-417,240)}
	PointNames = {"Roof","Roof1"}
end











--Do not edit below here

function spawnPoint(pointnum)

	local ent = ents.Create( "baiknor_controlpoint" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( PointPositions[pointnum] )
		ent:Spawn()
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
		ent.PointName = PointNames[pointnum] or "Unnamed Point"
		GameVars.PointEntities[pointnum] = ent
	end


end

--Swaps spawns around so the teams start at the propper spawns
local storespawn = GameVars.FreedomSpawn
GameVars.FreedomSpawn = GameVars.DutySpawn
GameVars.DutySpawn = storespawn

function setupGamemode()

	game.CleanUpMap( true )

local	storespawn = GameVars.FreedomSpawn
	GameVars.FreedomSpawn = GameVars.DutySpawn
	GameVars.DutySpawn = storespawn

	for i, ply in ipairs( player.GetAll() ) do --kills every player to ready respawns
		ply:Kill()
	end

	GameVars.PointsFree = 300
	GameVars.PointsDuty = 300
	GameVars.PropsFreeCount = 0
	GameVars.PropsDutyCount = 0

	for i=1,GameVars.PointCount do 
		spawnPoint(i)
	end 

	--Creates 2 circular safezone indicators
	local ent = ents.Create( "baiknor_safezonemarker" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.FreedomSpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end

	local ent = ents.Create( "baiknor_safezonemarker" )

	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.DutySpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end


end