local UTILS = require "Graffiti/Utils";
local PACK_DEFS = require "Graffiti/PacksDefs";
local TAG_SPRAY = require "Graffiti/Class/ISTagSpray";
local TAG_WINDOW = require "Graffiti/Class/ISTagWindow";
local COLORS = require "Graffiti/Colors";

local transformMessage = function(message, tileset, item)
	local transformed = {}
	local curSuffix = 0
	local curChar = nil
	local curCharIndex = 0
	local curPosition = 1	
	local index = 1
	
	if tileset.tilesetType == "text" then
		while index <= #message and item:getDrainableUsesInt() >= index - 1 do
			curChar = message:sub(index, index)
			
			curCharIndex = tileset.charIndexes[curChar]
			
			if curCharIndex == nil then
				curCharIndex = tileset.invalidCharOffset
				curSuffix = tileset.invalidCharOffset
			else
				curSuffix = curCharIndex + tileset.positionOffsets[curPosition]
			end
			

			if curCharIndex ~= nil or curChar == tileset.singleWhitespace then
				if curChar ~= tileset.singleWhitespace then
					--We have a character with a valid mapping that is not the whitespace character, so place it.
					table.insert(transformed, curSuffix)
				else
					table.insert(transformed, -1)
				end
				
				--Move the cursor position for either a single whitespace or a valid character
				curPosition = curPosition + 1

				if curPosition > tileset.positionsPerSquare then curPosition = 1 end
			end

			index = index + 1
		end
	elseif tileset.tilesetType == "image" then
		table.insert(transformed, tileset.charIndexes[message])
	end
	
	return transformed
end

local function GT_paintSquare(playerObj, item, squareObj, directionIndex, tileset, message, color)
	if playerObj == nil then return end

	if squareObj == nil or playerObj:getVehicle() ~= nil then return end
	
	local curPosition = 1
	
	local charsProcessed = 0
	
	local spriteNameBase = tileset.tilesetbase .. tileset.directionSuffixes[directionIndex]

	local spriteName = nil
	
	local index = 1
	
	local returnVals = { charsProcessed=0, actions={} }
	
	local wallObj = nil
	local conditionalWallType
	
	if directionIndex == 1 then
		conditionalWallType = IsoFlagType.WallW
	elseif directionIndex == 2 then
		conditionalWallType = IsoFlagType.WallN
	else
		--Invalid Direction
		return
	end

	local sqObjects = squareObj:getObjects()
	local objProperties = nil

	--We need a wall to paint on. If there aren't any objects, then there aren't any walls. How did we get here?
	if sqObjects == nil then return end
	
	local objIndex = 1
	local curObject = nil
	
	while objIndex <= sqObjects:size() do
		curObject = sqObjects:get(objIndex-1)
		
		objProperties = curObject:getProperties()
		
		if objProperties ~= nil then
			if objProperties:Is(conditionalWallType) or objProperties:Is(IsoFlagType.WallNW) then
				wallObj = curObject
				
				--We found our wall, stop here
				objIndex = sqObjects:size()
			end
		end
		
		objIndex = objIndex + 1
	end
	
	while index <= #message and curPosition <= tileset.positionsPerSquare do
		if message[index] ~= -1 then
			spriteName = spriteNameBase .. message[index]

			local action = TAG_SPRAY:new(playerObj, item, squareObj, wallObj, directionIndex, curPosition, tileset.positionsPerSquare, spriteName, color)

			if action ~= nil then
				table.insert(returnVals.actions, action)
			end
		end

		--Move the cursor position for either a single whitespace or a valid character
		curPosition = curPosition + 1
		
		returnVals.charsProcessed = returnVals.charsProcessed + 1
		index = index + 1
	end

	return returnVals
end

local paintMessage = function(playerNum, item, square, tileset, message, color, startingDirection, startX, startY, startZ)
	local player = getSpecificPlayer(playerNum)
	
	if player == nil then return end
	
	local curSquare = square;
	
	if curSquare == nil or player:getVehicle() ~= nil then return end

	local curX = curSquare:getX()
	local curY = curSquare:getY()
	local curZ = player:getZ()

	--TODO: Better direction starting
	-- 1 = Moving North, 2 = Moving West
	local curDirection = startingDirection
	local curWallType = curSquare:getWallType()
	
	--local spriteName = nil
	local objectName = nil
	
	--local curSuffix = 0
	--local curChar = nil
	
	--local curPosition = 1
	
	local curSubMessage = nil
	
	local index = 1
	
	local charsProcessed = 0
	local graffitiActions = nil
	local squarePaintResult = nil
	
	local transformedMessage = transformMessage(message, tileset, item)
	

	local actions = {}
	
	while index <= #transformedMessage do
		curSubMessage = {}
		
		for curSubMessageOffset=0,math.min(2, #transformedMessage - index) do
			table.insert(curSubMessage, transformedMessage[index + curSubMessageOffset])
		end
		
		curX = curSquare:getX()
		curY = curSquare:getY()
		curZ = player:getZ()
		
		squarePaintResult = GT_paintSquare(player, item, curSquare, curDirection, tileset, curSubMessage, color)
		
		charsProcessed = squarePaintResult.charsProcessed
		graffitiActions = squarePaintResult.actions
		
		if #graffitiActions > 0 then
			table.insert(actions, ISPathFindAction:pathToLocationF(player, curX + 0.5, curY + 0.5, curZ))
			
			for objIndex, curAction in pairs(graffitiActions) do
				table.insert(actions, curAction)
			end
		end
		
		if true then
			--Advance to the next square
			if curDirection == 1 and (curWallType == 5 or curWallType == 7) then
				--Change direction to the West, stay in same square
				curDirection = 2
			elseif curDirection == 1 then
				--Check to the North one square up (Y -= 1)
				curY = curY - 1
				curSquare = getCell():getGridSquare(curX, curY, curZ)
				
				if curSquare ~= nil then
					curWallType = curSquare:getWallType()
					
					if curWallType ~= 4 and curWallType ~= 5 and curWallType ~= 12 and curWallType ~= 13 then
						--Wall not found, stop here
						index = #transformedMessage + 1
					end
				end
			elseif curDirection == 2 then
				--Check to the West one square over (X += 1)
				curX = curX + 1
				curSquare = getCell():getGridSquare(curX, curY, curZ)
				
				if curSquare ~= nil then
					curWallType = curSquare:getWallType()
					
					if curWallType ~= 1 and curWallType ~= 3 and curWallType ~= 9 and curWallType ~= 11 then
						--Wall not found, Check to the North one square up (Y -= 1) so long as there is no blocking wall
						curY = curY - 1
						curSquare = getCell():getGridSquare(curX, curY, curZ)
						
						if curSquare ~= nil then
							curWallType = curSquare:getWallType()
							
							if curWallType ~= 4 and curWallType ~= 5 and curWallType ~= 12 and curWallType ~= 13 then
								--Wall not found, stop here
								index = #transformedMessage + 1
							else
								--Wall found, change direction and continue
								curDirection = 1
							end
						end
					else
						--Wall found, continue in same direction
					end
				end
			else
				--This is an error case, since curDirection is not 1 (North) or 2 (West). How did we even get here?
				index = #transformedMessage + 1
			end
		end
		
		index = index + charsProcessed
	end
	
	for i, curAction in pairs(actions) do
		ISTimedActionQueue.add(curAction)
	end
end

local cleanWall = function(square, wall) 
	local tagToRemove = {};
	local objects = square:getObjects();

	for i = 0, objects:size() - 1 do
		local object = objects:get(i);

		if object ~= nil then
			if object:getModData() and object:getModData().GTtag == true then
				table.insert(tagToRemove, object);
				object:getModData().GTtag = false;
				object:transmitModData();
			end
		end
	end

	for k, v in pairs(tagToRemove) do
		square:RemoveTileObject(v);
	end
	
	wall:getModData().GTtagged = false;
	wall:transmitModData();
end

local tagWindowCallback = function(item, square, dir, style, text)
	local source = getPlayer();
	local color = item:getModData().Graffiti.Color;

	paintMessage(source:getPlayerNum(), item, square, style, text, color, dir, source:getX(), source:getY(), source:getZ())
end

local tagWall = function(items, square, dir)
	local sw = getCore():getScreenWidth()
	local sh = getCore():getScreenHeight()
	local packs = PACK_DEFS.Packs

	local window = TAG_WINDOW:new(sw / 2 - 250, sh / 2 - 250, 500, 500, items, packs, square, dir, tagWindowCallback)
	window:instantiate()
	window:addToUIManager()
	window:setVisible(true, nil)
end

local setColorToItems = function(items)
	
	if items then
		for k, v in pairs(items) do
			v:getModData().Graffiti = {};

			local properties = v:getModData().Graffiti;
			local color = string.sub(v:getFullType(), 18, -1);
			
			properties.Color = COLORS[color];
		end
	end
end

local onFillWorldObjectContextMenu = function(player, context, worldObjects, test) -- Find Walls
	local source = getSpecificPlayer(player);
	local locations = { hash = {}, squares = {}};
	local sprayCans = {};
	
	for k, v in pairs(COLORS) do
		table.insert(sprayCans, "Graffiti.SprayCan" .. k)
	end

	local items = UTILS.findItems(source, sprayCans);
	setColorToItems(items);

	if items and worldObjects ~= nil then

		for k, v in ipairs(worldObjects) do --- Not repite square
			local square = v:getSquare();

			if (not locations.hash[square]) then
				locations.squares[#locations.squares+1] = square;
				locations.hash[square] = true;
			end
		end


		if locations.squares then -- Always gets only one square, it will fixed in clean code stage
			for k, v in pairs(locations.squares) do
				local wallType = v:getWallType();
				local tileObjects = v:getLuaTileObjectList();
				local tileObject;

				for k, v in pairs(tileObjects) do
					if v:getModData().GTtagged then
						tileObject = v;
						
						break;
					end
				end

				if tileObject then
					context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("IGUI_GT_Remove_Tags"), v, cleanWall, tileObject)
				end


				if wallType == 1 or wallType == 3 or wallType == 5 or wallType == 7 or wallType == 9 or wallType == 11 or wallType == 13 or wallType == 15 then
					context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("IGUI_GT_Tag_Northern_Wall"), items, tagWall, v, 2); --IsoFlagType.WallN
				end

				if wallType == 4 or wallType == 5 or wallType == 6 or wallType == 7 or wallType == 12 or wallType == 13 or wallType == 14 or wallType == 15 then
					context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("IGUI_GT_Tag_Western_Wall"), items, tagWall, v, 1); -- IsoFlagType.WallW
				end
			end
		end
	end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu);

LuaEventManager.AddEvent("Graffiti:AddPackDefs")
Events["Graffiti:AddPackDefs"].Add(function(packDefs)
    table.insert(PACK_DEFS.Packs, packDefs);
end)