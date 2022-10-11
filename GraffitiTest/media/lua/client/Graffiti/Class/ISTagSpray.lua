require "TimedActions/ISBaseTimedAction"

local ISTagSpray = ISBaseTimedAction:derive("ISTagSpray")

function ISTagSpray:new(character, item, squareObj, wallObj, direction, position, positionCount, spriteName, colorObj)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.character = character;
	o.item = item;
	o.square = squareObj;
	o.wall = wallObj;
	o.direction = direction
	o.sprite = spriteName
	o.color = colorObj
	o.maxTime = 50
	o.jobType = getText("IGUI_GT_Tag_Wall")

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
	
	return o
end

function ISTagSpray:isValid()
	return self.square ~= nil and self.character ~= nil;
end

function ISTagSpray:waitToStart()
	self.character:faceLocationF(self.dirSquareX, self.dirSquareY)
	return self.character:shouldBeTurning()
end

function ISTagSpray:update()
	self.character:faceLocationF(self.dirSquareX, self.dirSquareY)
end

function ISTagSpray:start()
	self:setActionAnim("Bob_Spray");
	self:setOverrideHandModels(self.item, nil);
end

function ISTagSpray:stop()
	ISBaseTimedAction.stop(self)
end

function ISTagSpray:perform()
	local isoObject = IsoObject.new(self.square, self.sprite, nil, false)
	local sprite = nil
	
	if isoObject ~= nil then
		sprite = isoObject:getSprite()

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

		self.item:Use();
	end
		
	ISBaseTimedAction.perform(self)
end

return ISTagSpray