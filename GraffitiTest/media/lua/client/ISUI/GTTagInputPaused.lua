-------------------------------------------------------------------------------
--                     Based on code by The Indie Stone                      --
--                 client/OptionScreens/CoopCharacterCreation                --
-------------------------------------------------------------------------------

require "ISUI/ISPanelJoypad"

local GTTagInputPaused = ISPanelJoypad:derive("GTTagInputPaused");

function GTTagInputPaused:accept()
--	self:setVisible(false)
	self:removeFromUIManager()

	if UIManager.getSpeedControls() then
		setShowPausedMessage(true)
		UIManager.getSpeedControls():SetCurrentGameSpeed(1)
		if self.joypadData then
			self.joypadData.activeWhilePaused = nil
		end
	end

	GTTagInputPaused.setVisibleAllUI(true)
	GTTagInputPaused.instance = nil

	--Removed
	--[[
	if ISPostDeathUI.instance[self.playerIndex] then
		ISPostDeathUI.instance[self.playerIndex]:removeFromUIManager()
		ISPostDeathUI.instance[self.playerIndex] = nil
	end
	]]--

	if not self.joypadData then
		setPlayerMouse(nil)
		return
	end

	local controller = self.joypadData.controller
	local joypadData = JoypadState.joypads[self.playerIndex+1]
	JoypadState.players[self.playerIndex+1] = joypadData
	joypadData.player = self.playerIndex
	joypadData:setController(controller)
	joypadData:setActive(true)
	
	--Related to character creation or joypad management?
	local username = nil
	if isClient() and self.playerIndex > 0 then
		username = CoopUserName.instance:getUserName()
	end
	setPlayerJoypad(self.playerIndex, self.joypadIndex, nil, username)

	self.joypadData.focus = nil
	self.joypadData.lastfocus = nil
	self.joypadData.prevfocus = nil
	self.joypadData.prevprevfocus = nil
end

function GTTagInputPaused:cancel()
	self:removeFromUIManager()
	GTTagInputPaused.setVisibleAllUI(true)
	GTTagInputPaused.instance = nil

	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(true)
		UIManager.getSpeedControls():SetCurrentGameSpeed(1)
	end
	
	if self.joypadData then
		self.joypadData.activeWhilePaused = nil
		self.joypadData.focus = nil -- self.joypadData.listBox
		self.joypadData.lastfocus = nil
		self.joypadData.prevfocus = nil
		self.joypadData.prevprevfocus = nil
	end

	if ISPostDeathUI.instance[self.playerIndex] then
		ISPostDeathUI.instance[self.playerIndex]:setVisible(true)
		if self.joypadData then
			self.joypadData.focus = ISPostDeathUI.instance[self.playerIndex]
		end
	end
end

function GTTagInputPaused:createChildren()
	ISCollapsableWindowJoypad.createChildren(self)
	
	local th = self:titleBarHeight()
	local rh = self:resizeWidgetHeight()
	
	local buttonHgt = FONT_HGT_SMALL + 3 * 2
	local buttonBuffer = 3 * 2
	local buttonPanelHeight = buttonHgt + buttonBuffer + 3 * 2
	
	self.tabs = ISTabPanel:new(0, th, self.width, self.height - th - rh - buttonPanelHeight)
	self.tabs:initialise()
	self.tabs:instantiate()
	self.tabs:setAnchorTop(true)
	self.tabs:setAnchorLeft(true)
	self.tabs:setAnchorRight(true)
	self.tabs:setAnchorBottom(true)
	self.tabs:setEqualTabWidth(false)
	self:addChild(self.tabs)

	self.buttonPanel = ISPanelJoypad:new(0, self.tabs.height + th, self.width, buttonPanelHeight)
	self.buttonPanel:initialise()
	self.buttonPanel:instantiate()
	self.buttonPanel:setAnchorLeft(true)
	self.buttonPanel:setAnchorRight(true)
	self.buttonPanel:setAnchorTop(false)
	self.buttonPanel:setAnchorBottom(true)
	self:addChild(self.buttonPanel)
	
	self.tagEntryPanel = ISPanelJoypad:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
	--self.tagEntryPanel.backgroundColor = { r=0, g=0, b=0, a=0.8 }
	--self.tagEntryPanel.borderColor = { r=1, g=1, b=1, a=0.5 }
	self.tagEntryPanel:initialise()
	self.tagEntryPanel:instantiate()
	self.tagEntryPanel:setAnchorRight(true)
	self.tagEntryPanel:setAnchorLeft(true)
	self.tagEntryPanel:setAnchorBottom(true)
	self.tagEntryPanel:setAnchorTop(true)
	self.tabs:addView("Message", self.tagEntryPanel)
	
	self.colorEntryPanel = ISPanel:new(0, self.tabs.tabHeight, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
	--self.colorEntryPanel.backgroundColor = { r=0, g=0, b=0, a=0.8 }
	--self.colorEntryPanel.borderColor = { r=1, g=1, b=1, a=0.5 }
	self.colorEntryPanel:initialise()
	self.colorEntryPanel:instantiate()
	self.colorEntryPanel:setAnchorRight(true)
	self.colorEntryPanel:setAnchorLeft(true)
	self.colorEntryPanel:setAnchorBottom(true)
	self.colorEntryPanel:setAnchorTop(true)
	self.tabs:addView("Color", self.colorEntryPanel)
	
	--[[
	local w = self.width * 0.75;
	if(w < 400) then
		w = 400;
	end
	local tw = self.width;
	local mainPanelY = 48
	local mainPanelPadBottom = 80
	if getCore():getScreenHeight() <= 600 then
		mainPanelPadBottom = 16
	end
	self.mainPanel = ISPanel:new((tw-w)/2, 48, w, self.height - mainPanelPadBottom - mainPanelY);
	self.mainPanel.backgroundColor = {r=0, g=0, b=0, a=0.8};
	self.mainPanel.borderColor = {r=1, g=1, b=1, a=0.5};
	
	self.mainPanel:initialise();
	self.mainPanel:setAnchorRight(true);
	self.mainPanel:setAnchorLeft(true);
	self.mainPanel:setAnchorBottom(true);
	self.mainPanel:setAnchorTop(true);
	self:addChild(self.mainPanel);
	]]--
	

	
	-- BOTTOM BUTTON
	self.backButton = ISButton:new(16, buttonBuffer, 100, buttonHgt, getText("UI_btn_cancel"), self, self.onOptionMouseDown);
	self.backButton.internal = "CANCEL";
	self.backButton:initialise();
	self.backButton:instantiate();
	self.backButton:setAnchorLeft(true);
	self.backButton:setAnchorTop(false);
	self.backButton:setAnchorBottom(true);
	self.backButton.borderColor = {r=1, g=1, b=1, a=0.1};
--	self.backButton.setJoypadFocused = self.setJoypadFocusedBButton
	self.buttonPanel:addChild(self.backButton);


	self.playButton = ISButton:new(self.tagEntryPanel.width - 116, buttonBuffer, 100, buttonHgt, getText("UI_GT_btn_tag"), self, self.onOptionMouseDown);
	self.playButton.internal = "TAG";
	self.playButton:initialise();
	self.playButton:instantiate();
	self.playButton:setAnchorLeft(false);
	self.playButton:setAnchorRight(true);
	self.playButton:setAnchorTop(false);
	self.playButton:setAnchorBottom(true);
	self.playButton:setEnable(true); -- sets the hard-coded border color
--	self.playButton.setJoypadFocused = self.setJoypadFocusedAButton
	--self.playButton:setSound("activate", "graffiti_spray")
	self.buttonPanel:addChild(self.playButton);
	
	--[[
	local textWid = getTextManager():MeasureStringX(UIFont.Small, getText("UI_characreation_random"))
	local buttonWid = math.max(100, textWid + 8 * 2)
	self.randomButton = ISButton:new(self.playButton:getX() - 10 - buttonWid, self.playButton:getY(), buttonWid, buttonHgt, getText("UI_characreation_random"), self, self.onOptionMouseDown);
	self.randomButton.internal = "RANDOM";
	self.randomButton:initialise();
	self.randomButton:instantiate();
	self.randomButton:setAnchorLeft(false);
	self.randomButton:setAnchorRight(true);
	self.randomButton:setAnchorTop(false);
	self.randomButton:setAnchorBottom(true);
	self.randomButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
--	self.backButton.setJoypadFocused = self.setJoypadFocusedYButton
	self.buttonPanel:addChild(self.randomButton);
	]]--


	local labelMaxWid = 0
	labelMaxWid = math.max(labelMaxWid, getTextManager():MeasureStringX(UIFont.Small, getText("UI_GT_text_entry")))
	local entryX = 16 + labelMaxWid + 6
	local entryHgt = math.max(FONT_HGT_SMALL + 2 * 2, FONT_HGT_MEDIUM)
	
	local labelY = (16 + (entryHgt / 2)) - (FONT_HGT_SMALL / 2)
	
	--TODO: Create labels
	local label = ISLabel:new(16, labelY, FONT_HGT_SMALL, getText("UI_GT_text_entry"), 1, 1, 1, 1, UIFont.Small, true)
	label:initialise()
	label:instantiate()
	label:setAnchorLeft(true)
	label:setAnchorTop(true)
	self.tagEntryPanel:addChild(label)
	

	--TODO: Create text input box
	self.tagTextEntry = ISTextEntryBox:new("Test", entryX, 16, self.width - entryX - 16, entryHgt);
	self.tagTextEntry:initialise();
	self.tagTextEntry:instantiate();
	self.tagTextEntry:setAnchorLeft(true)
	self.tagTextEntry:setAnchorRight(true)
	self.tagTextEntry:setAnchorTop(true)
	self.tagTextEntry:setAnchorBottom(false)

	self.tagEntryPanel:addChild(self.tagTextEntry);

	
	--TODO: Create color sliders
end

--TODO: Handle last 3 parameters
function GTTagInputPaused:new(x, y, width, height, joypadIndex, joypadData, playerIndex)
	local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	
	o.borderColor = { r=0.4, g=0.4, b=0.4, a=1 }
	o.backgroundColor = { r=0, g=0, b=0, a=0.8 }
	
	o.itemheightoverride = {};
	
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	
	o.colorPanel = {};
	
	o.title = getText("UI_GT_Input_Title")
	
	o.titleFont = UIFont.Medium
	o.titleFontHgt = getTextManager():getFontHeight(o.titleFont)
	
	o.joypadIndex = joypadIndex
	o.joypadData = joypadData
	o.playerIndex = playerIndex
	
	o:setUIName("GTTagInputPaused")
	
	GTTagInputPaused.instance = o
	return o
end

GTTagInputPaused.visibleUI = {}

function GTTagInputPaused.setVisibleAllUI(visible)
	local ui = UIManager.getUI()
	if not visible then
		for i=0,ui:size()-1 do
			if ui:get(i):isVisible() then
				table.insert(GTTagInputPaused.visibleUI, ui:get(i):toString())
				ui:get(i):setVisible(false)
			end
		end
	else
		for i,v in ipairs(GTTagInputPaused.visibleUI) do
			for i=0,ui:size()-1 do
				if v == ui:get(i):toString() then
					ui:get(i):setVisible(true)
					break
				end
			end
		end
		GTTagInputPaused.visibleUI = {}
	end
	UIManager.setVisibleAllUI(visible)
end

function GTTagInputPaused.newPlayer(joypadIndex, joypadData)
	if GTTagInputPaused.instance then return end
	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(false)
		UIManager.getSpeedControls():SetCurrentGameSpeed(0)
		joypadData.activeWhilePaused = true
	end
	GTTagInputPaused.setVisibleAllUI(false)
	local playerIndex = joypadData.player
	if not playerIndex then -- true when not respawning
		for i=0,getMaxActivePlayers()-1 do
			local player = getSpecificPlayer(i)
			if not player or player:isDead() then
				playerIndex = i
				break
			end
		end
	end
	local w = GTTagInputPaused:new(joypadIndex, joypadData, playerIndex)
	w:initialise()
	w:addToUIManager()
	if w.coopUserName:shouldShow() then
		w.coopUserName:beforeShow()
		w.coopUserName:setVisible(true, joypadData)
	elseif w.mapSpawnSelect:hasChoices() then
		w.mapSpawnSelect:fillList()
		w.mapSpawnSelect:setVisible(true, joypadData)
	else
		w.mapSpawnSelect:useDefaultSpawnRegion()
		w.charCreationProfession:setVisible(true, joypadData)
	end
end

function GTTagInputPaused:newPlayerMouse()
    ProfessionFactory.Reset();
    BaseGameCharacterDetails.DoProfessions();
	if GTTagInputPaused.instance then return end
	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(false)
		UIManager.getSpeedControls():SetCurrentGameSpeed(0)
	end
	GTTagInputPaused.setVisibleAllUI(false)
	local w = GTTagInputPaused:new(nil, nil, 0)
	w:initialise()
	w:addToUIManager()
	if w.mapSpawnSelect:hasChoices() then
		w.mapSpawnSelect:fillList()
		w.mapSpawnSelect:setVisible(true)
	else
		w.mapSpawnSelect:useDefaultSpawnRegion()
		w.charCreationProfession:setVisible(true)
	end
end

function GTTagInputPaused:OnJoypadBeforeDeactivate(index)
	if self.joypadData and (self.joypadData.id == index) then
		-- Controller disconnected, cancel creation.
		-- Other windows are children of this ui.
		self:cancel()
	end
end


return GTTagInputPaused