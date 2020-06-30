

function HUD()
	local client = LocalPlayer()
	
	if !client:Alive() then
		return
	end

	Team = client:Team()
--	Team = 2

if Team == 1 then

	TeamColor = Color(0,200,0)
	TeamPropCount = GameVars.PropsFreeCount or 0
	TeamWeight = GameVars.WeightFreeCount/1000
elseif Team == 2 then
	TeamColor = Color(200,0,0)
	TeamPropCount = GameVars.PropsDutyCount or 0
	TeamWeight = GameVars.WeightDutyCount/1000
else
	TeamColor = Color(200,200,200)
	TeamPropCount = 0	
	TeamWeight = 0
end

	--IK this is bad, I hate myself for doing this. Deal with it, its 3am. Better than 5 networked variables. Will prob make search occur every once in a while.

	local points = ents.FindByClass( "baiknor_controlpoint" )

	for id, ent in pairs( points ) do

		local point = ent:GetPos() + ent:OBBCenter() + Vector (0,0,100)
		local data2D = point:ToScreen()

--		if ( not data2D.visible ) then continue end

	draw.RoundedBox(10, data2D.x-5, data2D.y-5, 13, 13, ent:GetColor())

	draw.RoundedBox(3,ScrW()/2-30*GameVars.PointCount/2+2+((id-1)*30), 70, 20, 20,ent:GetColor())

--		draw.SimpleText( ent.PointName, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	points = team.GetPlayers(Team)

	for id, ent in pairs( points ) do
		local point = ent:GetPos() + ent:OBBCenter()
		local data2D = point:ToScreen()

--		if ( not data2D.visible ) then continue end

	surface.SetDrawColor(TeamColor)
	surface.DrawRect(data2D.x-5, data2D.y-5, 5, 5)

--		draw.SimpleText( ent.PointName, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	--Team Props and tonnage available
	draw.RoundedBox(5,20, 20, 230, 80, TeamColor or Color(255, 255, 255) )--CornerCurvature radius, x, y, width, height, color
	draw.SimpleText("Team Props: "..TeamPropCount.."/"..GameVars.PropCountMax, "DermaDefaultBold", 40, 30, Color(255,255,255), 0, 0)
	draw.SimpleText("Team Weight: "..TeamWeight.."/"..GameVars.WeightLimit, "DermaDefaultBold", 40, 70, Color(255,255,255), 0, 0)
	draw.RoundedBox(5,12.5, 10, 245, 95, Color(0,0,0,100) )--CornerCurvature radius, x, y, width, height, color
	
	--Middle Point Box
	
	draw.RoundedBox(5,ScrW()/2-375, 10, 750, 50, Color(0,0,0,100) )--CornerCurvature radius, x, y, width, height, color	

	--*Health Boxes*
	local Length = math.max(GameVars.PointsFree/300,0.0001) --Point Ratio
	draw.RoundedBox(5,ScrW()/2-370*1, 15, 365*Length, 40, Color(0,255,0,255) ) --Freedom
	Length = math.max(GameVars.PointsDuty/300,0.0001)
	draw.RoundedBox(5,ScrW()/2+370*(1-Length), 15, 365*Length, 40, Color(255,0,0,255) ) --Duty

	--Points Left Text
	draw.SimpleText(GameVars.PointsFree, "DermaDefaultBold", ScrW()/2-200, 28, Color(255,255,255), 0, 0)	
	draw.SimpleText(GameVars.PointsDuty, "DermaDefaultBold", ScrW()/2+180, 28, Color(255,255,255), 0, 0)	
	--GameVars.setNWInt("PointsFree",GameVars.PointsFree)
	--GameVars.setNWInt("PointsDuty",GameVars.PointsDuty)





end

hook.Add("HUDPaint", "DrawGamemodeHud", HUD)

local hide = { -- CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

--concommand.Add( "team_menu", set_team )

net.Receive("update_cappoints_freedom", function()
	GameVars.PointsFree = net.ReadInt(10) or -1
--	print(GameVars.PointsFree)
end)

net.Receive("update_cappoints_duty", function()
	GameVars.PointsDuty = net.ReadInt(10) or -1
--	print(GameVars.PointsDuty)
end)

net.Receive("update_propcount_freedom", function()
	GameVars.PropsFreeCount = net.ReadInt(10) or -1
end)

net.Receive("update_propcount_duty", function()
	GameVars.PropsDutyCount = net.ReadInt(12) or -1
end)

net.Receive("update_weight_freedom", function()
	GameVars.WeightFreeCount = net.ReadInt(13)*500 or -1
--	print(GameVars.PointsFree)
end)

net.Receive("update_weight_duty", function()
	GameVars.WeightDutyCount = net.ReadInt(13)*500 or -1
--	print(GameVars.PointsDuty)
end)