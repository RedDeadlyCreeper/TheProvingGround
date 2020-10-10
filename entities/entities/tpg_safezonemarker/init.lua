AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/hunter/misc/shell2x2.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_NONE);
	self:SetSolid(SOLID_NONE);

	self.Scale = self.Scale or 3000
--	Scale = 1500
	self.Scale = self.Scale / 95.4 / 2 --Converts the model to radius units --Just doesn't work needs fixed
	self:SetModelScale(self.Scale,0)
	self:SetMaterial( "models/props_combine/com_shield001a" )




end

function ENT:Think()

end


function ENT:OnRemove()

end









