require "client/GT_GraffitiPacksDef"
require "TimedActions/GTTagSingle"

local function GT_transformMessage(message, tileset)
	local transformed = {}

	local curSuffix = 0
	local curChar = nil
	local curCharIndex = 0
	
	local curPosition = 1
	
	local index = 1
	
	if tileset.tilesetType=="text" then
		while index <= #message do
			--Get a single UTF-16 character.
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
	elseif tileset.tilesetType=="image" then
		while index <= #message do
			curChar = message[index]
			
			curCharIndex = tileset.charIndexes[curChar]
			
			if curCharIndex == nil then
				curCharIndex = tileset.invalidCharOffset
				curSuffix = tileset.invalidCharOffset
			else
				curSuffix = curCharIndex + tileset.positionOffsets[curPosition]
			end
			

			if curCharIndex ~= nil or curChar == tileset.singleWhitespace then
				if curChar ~= tileset.singleWhitespace then
					table.insert(transformed, curSuffix)
				else
					table.insert(transforemd, -1)
				end

				--Move the cursor position for either a single whitespace or a valid character
				curPosition = curPosition + 1
				
				if curPosition > tileset.positionsPerSquare then curPosition = 1 end
			end
			
			index = index + 1
		end		
	else
		--Invalid or future type
	end
	
	return transformed
end

local function GT_paintSquare(playerObj, squareObj, directionIndex, tileset, message, color)
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
			
			local action = GTTagSingle:new(playerObj, squareObj, wallObj, directionIndex, curPosition, tileset.positionsPerSquare, spriteName, color)

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

local function GT_paintMessage(playerNum, tileset, message, color, startingDirection, startX, startY, startZ)
	local player = getSpecificPlayer(playerNum)
	
	if player == nil then return end
	
	local curSquare = player:getSquare()
	
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
	
	local transformedMessage = GT_transformMessage(message, tileset)
	
	local actions = {}
	
	while index <= #transformedMessage do
		curSubMessage = {}
		
		for curSubMessageOffset=0,math.min(2, #transformedMessage - index) do
			table.insert(curSubMessage, transformedMessage[index + curSubMessageOffset])
		end
		
		curX = curSquare:getX()
		curY = curSquare:getY()
		curZ = player:getZ()
		
		squarePaintResult = GT_paintSquare(player, curSquare, curDirection, tileset, curSubMessage, color)
		
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

local function GT_eraseGraffiti(playerNum, tilesetBase)
	local player = getSpecificPlayer(playerNum)
	
	if player == nil then return end
	
	local curSquare = player:getSquare()
	
	if curSquare == nil or player:getVehicle() ~= nil then return end
	
	local objects = curSquare:getObjects()
	
	if objects == nil then return end
	
	local isoObject = nil
	
	local objectsForRemoval = {}
	
	for index = 1, objects:size() do
		local i = index-1
		
		isoObject = objects:get(i)
		
		if isoObject ~= nil then
			local spriteName = isoObject:getSpriteName()
			
			if spriteName == nil then
				local sprite = isoObject:getSprite()
				
				if sprite ~= nil then
					spriteName = sprite:getName()
				end
			end
			
			if spriteName ~= nil and string.find(spriteName, tilesetBase) then
				table.insert(objectsForRemoval, isoObject)
			end
		end
	end
	
	for index = 1, #objectsForRemoval do
		curSquare:RemoveTileObject(objectsForRemoval[index])
	end
end

local function GT_cleanWall(objects, player, square, wall)
	if player == nil or square == nil or wall == nil then return end

	local curObject = nil
	
	local objsToRemove = {}
	
	for i=1,square:getObjects():size() do
		curObject = square:getObjects():get(i - 1)
		
		if curObject ~= nil then
			if curObject:getModData().GTtag == true then
				--TODO: Make this a timed action
				
				table.insert(objsToRemove, curObject)
			end
		end
	end
	
	for i, curObject in pairs(objsToRemove) do
		square:RemoveTileObject(curObject)
	end
	
	wall:getModData().GTtagged = false
	wall:transmitModData()
end

--Text
--GTTest = "zeds must die"
--GTTileset = mod_graffiti_style2

--Symbols
GTTest = { "Yin_Yang", "Troll", "Aza" }
GTTileset = mod_graffiti_symbols

GTColor = { r=0.9, g=0, b=0, a=0.5 }
GTDir = 1

local function GT_helloWorld(playerNum)
	local player = getSpecificPlayer(playerNum)
	
	GT_paintMessage(playerNum, GTTileset, GTTest, GTColor, GTDir, player:getX(), player:getY(), player:getZ())
end

local function GT_keyHandler(keyNum)
	local player = getPlayer()
	
	if keyNum == Keyboard.KEY_Y and player ~= nil and player:getVehicle() == nil then
		GT_helloWorld(player:getPlayerNum())
	elseif keyNum == Keyboard.KEY_U and player ~= nil and player:getVehicle() == nil then
		GT_eraseGraffiti(player:getPlayerNum(), mod_graffiti.tilesetbase)
		GT_eraseGraffiti(player:getPlayerNum(), mod_graffiti_style2.tilesetbase)
	end
end

local function GT_tagWall(objects, playerObj, curSquare)
	local sw = getCore():getScreenWidth()
	local sh = getCore():getScreenHeight()
	
	local textInput = GTTagInput:new(sw / 2 - 250, sh / 2 - 250, 500, 500)
	textInput:instantiate()
	textInput:addToUIManager()
	textInput:setVisible(true, nil)
end

local function GT_addToWorldObjectContextMenu(playerNum, context, objects, testing)
	local playerObj = getSpecificPlayer(playerNum)
	
	if playerNum == nil or context == nil or testing == true then return end
	
	local locations = {}
	
	local objProperties = nil
	local wallObj = nil
	local modData = nil
	
	if objects ~= nil then
		for i, curObject in pairs(objects) do
			if curObject:getSquare() ~= nil then
				table.insert(locations, curObject:getSquare())
			end
			
			objProperties = curObject:getProperties()
		
			if objProperties ~= nil then
				if objProperties:Is(IsoFlagType.WallW) or objProperties:Is(IsoFlagType.WallN) or objProperties:Is(IsoFlagType.WallNW) then
					wallObj = curObject

					modData = wallObj:getModData()
					
					if modData ~= nil and modData.GTtagged == true then
						--TODO: Add Option to remove graffiti
						context:addOption(getText("IGUI_GT_Remove_Tags"), objects, GT_cleanWall, playerObj, curObject:getSquare(), wallObj)
					end
				end
			end
		end
		
		if #locations > 0 then
			for i, curSquare in pairs(locations) do
				local wallType = curSquare:getWallType()
				if wallType == 4 or wallType == 5 or wallType == 6 or wallType == 7 or wallType == 12 or wallType == 13 or wallType == 14 or wallType == 15 then
					--TODO: Check we can path to that square
					--TODO: Add West option
					context:addOption(getText("IGUI_GT_Tag_Western_Wall"), objects, GT_tagWall, playerObj, curSquare)
				end
				
				if wallType == 1 or wallType == 3 or wallType == 5 or wallType == 7 or wallType == 9 or wallType == 11 or wallType == 13 or wallType == 15 then
					--TODO: Check we can path to that square
					--TODO: Add North option
					context:addOption(getText("IGUI_GT_Tag_Northern_Wall"), objects, GT_tagWall, playerObj, curSquare)
				end
			end
		end
	end
	
	local blah = locations
end

Events.OnKeyPressed.Add(GT_keyHandler);
Events.OnFillWorldObjectContextMenu.Add(GT_addToWorldObjectContextMenu);