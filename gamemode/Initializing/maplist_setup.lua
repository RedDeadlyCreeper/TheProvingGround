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

elseif MapName == "gm_baik_citycentre_v3" then
	GameVars.FreedomSpawn = Vector(5280, 4760, 256)
	GameVars.DutySpawn = Vector(-5280,-4760, 256)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 300
	GameVars.PointCount = 2
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 4000
	PointPositions = {Vector(3400, -1928, 16),Vector(-3400, 1928, 16)}
	PointNames = {"Green Park","Red Park"}

elseif MapName == "gm_baik_coast_03" then
	GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
	GameVars.DutySpawn = Vector(7312, 4011, 295)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 0.025	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-5137, 3755, 256),Vector(-217, 8201, 62)}
	PointNames = {"Beach House","Docks"}
elseif MapName == "gm_baik_coast_03_night" then
	GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
	GameVars.DutySpawn = Vector(7312, 4011, 295)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 0.025	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-5137, 3755, 256),Vector(-217, 8201, 62)}
	PointNames = {"Beach House","Docks"}
elseif MapName == "gm_baik_construct_draft1" then
	GameVars.FreedomSpawn = Vector(-3038, 3038, 17)
	GameVars.DutySpawn = Vector(3038, -3038, 17)
	GameVars.WeightLimit = 60
	GameVars.PropCountMax = 250
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 3000
	PointPositions = {Vector(2802, 3016, 4),Vector(0,0,424),Vector(-2802, -3016, 4)}
	PointNames = {"Parking Lot A","Parking Garage","Parking Lot B"}
elseif MapName == "gm_de_port_opened_v2" then --V1 not included
	GameVars.FreedomSpawn = Vector(-1920, 3944, 513)
	GameVars.DutySpawn = Vector(2245, -3674, 777)
	GameVars.WeightLimit = 40
	GameVars.PropCountMax = 200
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 3000
	PointPositions = {Vector(-1022, 137, 512),Vector(1119, 190, 642),Vector(2212, 1339, 512)}
	PointNames = {"Warehouse","Oil","Coast"}
elseif MapName == "gm_emp_arid" then
	GameVars.FreedomSpawn = Vector(13127,-11026,513)
	GameVars.DutySpawn = Vector(-11004, 12164, 537)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-1065, -12302, 512),Vector(-604, -874, 359),Vector(-4341, 6071, 472)}
	PointNames = {"Bunker","Bridge","Small Hill"}
elseif MapName == "gm_emp_manticore" then
	GameVars.FreedomSpawn = Vector(-6670, -3958, 1760)
	GameVars.DutySpawn = Vector(10288, 2047, 1761)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 300
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(3897, -4170, 1744),Vector(12,251,2048),Vector(-3988, 4155, 1744)}
	PointNames = {"Brick Factory","Bridge","Office"}
elseif MapName == "gm_emp_midbridge" then
	GameVars.FreedomSpawn = Vector(632, -9715, 2081)
	GameVars.DutySpawn = Vector(-628, 9755, 2081)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 4
	GameVars.CapMul = 0.01	
	GameVars.SZRadius = 8000
	PointPositions = {Vector(7931, -3408, 32),Vector(-7909, 3435, 32),Vector(0,0,2048),Vector(0,0,-255)}
	PointNames = {"A Ruins","B Ruins","Hell aBridged","Under the Bridge"}
elseif MapName == "gm_emp_palmbay" then
	GameVars.FreedomSpawn = Vector(-6577, -8994, -2331)
	GameVars.DutySpawn = Vector(8857, 10746, -2331)
	GameVars.WeightLimit = 40
	GameVars.PropCountMax = 200
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-7173, 11422, -2884),Vector(313, -499, -2953),Vector(3801, -9546, -2575)}
	PointNames = {"Island","Beach House","Grassland"}
elseif MapName == "gm_greenchoke" then
	GameVars.FreedomSpawn = Vector(-9156, 10610, 1038)
	GameVars.DutySpawn = Vector(9055, -10722, 1038)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 250
	GameVars.PointCount = 5
	GameVars.CapMul = 0.01	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(6295, 2018, 1043),Vector(-5961, 2032, 929),Vector(495, -1037, 1184),Vector(-85, 3492, 910),Vector(175, -5296, 844)}
	PointNames = {"Mountain Outpost","Town Outpost","Bridge","Island A","Island B"}
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