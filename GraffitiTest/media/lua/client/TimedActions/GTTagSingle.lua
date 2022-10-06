--***********************************************************
--**                    Based on code by                   **
--**                                                       **
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

local GTTagSingle = ISBaseTimedAction:derive("GTTagSingle")

function GTTagSingle:isValid()
	--TODO: Test for the character being on the same square as our action
	return self.square ~= nil and self.character ~= nil
end

function GTTagSingle:waitToStart()
	self.character:faceLocationF(self.dirSquareX, self.dirSquareY)
	return self.character:shouldBeTurning()
end

function GTTagSingle:update()
	self.character:faceLocationF(self.dirSquareX, self.dirSquareY)
	--self.item:setJobDelta(self:getJobDelta())

	--TODO: ? Maybe set this to something?
    --self.character:setMetabolicTarget(Metabolics.MediumWork)
end

function GTTagSingle:start()
	--self.item:setJobType(self.jobType)
	
	-- Todo? - Find a better animation for working on a raised object
	self:setActionAnim("Bob_Spray");
end

function GTTagSingle:stop()
	--self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function GTTagSingle:perform()
	local isoObject = IsoObject.new(self.square, self.sprite, nil, false)
	local sprite = nil
	
	if isoObject ~= nil then
		sprite = isoObject:getSprite()
		
		--if sprite ~= nil and self.color ~= nil then
		--	local colorInfo = ColorInfo:new()
		---	colorInfo:set(self.color.r,self.color.g,self.color.b,self.color.a)
			
		--sprite:ChangeTintMod(colorInfo)
		--end
		
		if self.color ~= nil then 
			isoObject:setCustomColor(self.color.r, self.color.g, self.color.b, self.color.a)
			isoObject:setAlphaAndTarget(self.color.a)
		end
		
		self.square:AddTileObject(isoObject)
		
		local modData = isoObject:getModData()
		
		if modData ~= nil then
			modData.GTtag = true
			isoObject:transmitModData()
		end
		
		modData = self.wall:getModData()
		
		if modData ~= nil then
			modData.GTtagged = true
			self.wall:transmitModData()
		end
	end
	
	--self.item:setJobDelta(0)
		
	ISBaseTimedAction.perform(self)
end

function GTTagSingle:new(character, squareObj, wallObj, direction, position, positionCount, spriteName, colorObj)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.character = character

	o.square = squareObj
	o.wall = wallObj
	
	o.direction = direction

	local positionShift
	
	if positionCount == 1 then
		positionShift = 0
	else
		positionShift = (positionCount - position - 1) / (positionCount + 1)
	end
	 
	if direction == 1 then
		o.dirSquareX = squareObj:getX()
		o.dirSquareY = squareObj:getY() + 0.5 + positionShift
	elseif direction == 2 then
		o.dirSquareX = squareObj:getX() + 0.5 - positionShift
		o.dirSquareY = squareObj:getY()
	end
	
	o.sprite = spriteName
	o.color = colorObj

	o.maxTime = 50
	
	o.jobType = getText("IGUI_GT_Tag_Wall")
	return o
end

return GTTagSingle