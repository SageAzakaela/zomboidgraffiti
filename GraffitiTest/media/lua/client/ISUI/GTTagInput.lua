-------------------------------------------------------------------------------
--                     Based on code by The Indie Stone                      --
--                client/OptionScreens/CharacterCreationMain                 --
-------------------------------------------------------------------------------

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISTabPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"

local GTTagInput = ISCollapsableWindowJoypad:derive("GTTagInput")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function GTTagInput:initialise()
	ISCollapsableWindowJoypad.initialise(self);
end

--************************************************************************--
--** ISPanel:instantiate
--**
--************************************************************************--
function GTTagInput:instantiate()
	--self:initialise();
	self.javaObject = UIElement.new(self);
	self.javaObject:setX(self.x);
	self.javaObject:setY(self.y);
	self.javaObject:setHeight(self.height);
	self.javaObject:setWidth(self.width);
	self.javaObject:setAnchorLeft(self.anchorLeft);
	self.javaObject:setAnchorRight(self.anchorRight);
	self.javaObject:setAnchorTop(self.anchorTop);
	self.javaObject:setAnchorBottom(self.anchorBottom);
	self:createChildren();
end

function GTTagInput:createChildren()
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
	labelMaxWid = math.max(labelMaxWid, getTextManager():MeasureStringX(UIFont.Small, getText("UI_GT_style_choice")))
	labelMaxWid = math.max(labelMaxWid, getTextManager():MeasureStringX(UIFont.Small, getText("UI_GT_text_entry")))
	
	local entryX = 16 + labelMaxWid + 6
	local entryHgt = math.max(FONT_HGT_SMALL + 2 * 2, FONT_HGT_MEDIUM)
	
	local labelY = (16 + (entryHgt / 2)) - (FONT_HGT_SMALL / 2)
	
	--TODO: Create labels
	local label = ISLabel:new(16, labelY, FONT_HGT_SMALL, getText("UI_GT_style_choice"), 1, 1, 1, 1, UIFont.Small, true)
	label:initialise()
	label:instantiate()
	label:setAnchorLeft(true)
	label:setAnchorTop(true)
	self.tagEntryPanel:addChild(label)
	
	labelY = (16 + entryHgt + 8) + (entryHgt / 2) - (FONT_HGT_SMALL / 2)
	
	label = ISLabel:new(16, labelY, FONT_HGT_SMALL, getText("UI_GT_text_entry"), 1, 1, 1, 1, UIFont.Small, true)
	label:initialise()
	label:instantiate()
	label:setAnchorLeft(true)
	label:setAnchorTop(true)
	self.tagEntryPanel:addChild(label)	

	--TODO: Create text input box
	self.tagStyleEntry = ISComboBox:new(entryX, 16, self.width - entryX - 16, entryHgt)
	self.tagStyleEntry:initialise()
	self.tagStyleEntry:instantiate()
	self.tagStyleEntry:setAnchorLeft(true)
	self.tagStyleEntry:setAnchorRight(true)
	self.tagStyleEntry:setAnchorTop(true)
	self.tagStyleEntry:setAnchorBottom(false)
	self.tagStyleEntry:setEditable(false)

	for k, v in pairs(self.styles) do
		self.tagStyleEntry:addOptionWithData(v.displayName, v);
		--self.tagStyleEntry:addOption(v.displayName);
	end

	self.tagEntryPanel:addChild(self.tagStyleEntry)

	
	
	
	self.tagTextEntry = ISTextEntryBox:new("Test", entryX, 16 + 8 + entryHgt, self.width - entryX - 16, entryHgt);
	self.tagTextEntry:initialise();
	self.tagTextEntry:instantiate();
	self.tagTextEntry:setAnchorLeft(true)
	self.tagTextEntry:setAnchorRight(true)
	self.tagTextEntry:setAnchorTop(true)
	self.tagTextEntry:setAnchorBottom(false)

	self.tagEntryPanel:addChild(self.tagTextEntry);

	
	--TODO: Create color sliders
end

function GTTagInput:getText()
	return self.tagTextEntry:getText();
end

function GTTagInput:getStyle()
	return self.tagStyleEntry.options[self.tagStyleEntry.selected].data;
end

function GTTagInput:setVisible(bVisible, joypadData)
	if self.javaObject == nil then
		self:instantiate();
	end
	
	ISCollapsableWindowJoypad.setVisible(self, bVisible, joypadData)
end


function GTTagInput:onOptionMouseDown(button, x, y)
	if button.internal == "CANCEL" then
		self:setVisible(false, nil)
	end
	if button.internal == "TAG" then
		self:setVisible(false, nil)
		--print(self.tagTextEntry:getText())
		--print(self:getStyle());
		self.callback(self:getStyle(), self:getText());
	end
end


function GTTagInput:prerender()
	GTTagInput.instance = self
	ISCollapsableWindowJoypad.prerender(self);
	
	--TODO: Adjust height (10?) for size of font
	--self:drawTextCentre(getText("UI_GT_Input_Title"), self.width / 2, 10, 1, 1, 1, 1, UIFont.Large);
end

function GTTagInput:onGainJoypadFocus(joypadData)
--	local oldFocus = self:getJoypadFocus()
	ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData);
	self:setISButtonForA(self.playButton);
	self:setISButtonForB(self.backButton);
	self:setISButtonForY(self.randomButton);
	-- init all the button for the controller
	self:loadJoypadButtons(joypadData);
--[[
	if not oldFocus or not oldFocus:isVisible() then
		self:clearJoypadFocus(joypadData)
		self.joypadIndexY = #self.joypadButtonsY;
		self.joypadButtons = self.joypadButtonsY[self.joypadIndexY];
		self.joypadIndex = #self.joypadButtons;
		self.playButton:setJoypadFocused(true);
	end
--]]
end

function GTTagInput:onLoseJoypadFocus(joypadData)
	self.playButton:clearJoypadButton()
	self.backButton:clearJoypadButton()
	self.randomButton:clearJoypadButton()
--	self:clearJoypadFocus()
	ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
end

function GTTagInput:onJoypadDirLeft(joypadData)
	joypadData.focus = self.presetPanel
	updateJoypadFocus(joypadData)
end

function GTTagInput:onJoypadDirRight(joypadData)
	joypadData.focus = self.presetPanel
	updateJoypadFocus(joypadData)
end

function GTTagInput:onJoypadDirUp(joypadData)
	joypadData.focus = self.characterPanel
	updateJoypadFocus(joypadData)
end


function GTTagInput:onResolutionChange(oldw, oldh, neww, newh)
	local th = self:titleBarHeight()
	local rh = self:resizeWidgetHeight()

	self.tabs:setX(0)
	self.tabs:setY(th)
	self.tabs:setWidth(self.width)
	self.tabs:setHeight(self.height-th-rh)
	self.tabs:setAnchorRight(true)
	self.tabs:setAnchorBottom(true)
	self.tabs:setEqualTabWidth(false)
	self.tabs:recalcSize()
	
	--[[
	local w = neww * 0.75;
	if (w < 768) then
		w = 768;
	end
	local tw = neww;
	local mainPanelY = 48
	local mainPanelPadBottom = 80
	if getCore():getScreenHeight() <= 600 then
		mainPanelPadBottom = 16
	end
	self.mainPanel:setWidth(w)
	self.mainPanel:setHeight(self.height - mainPanelPadBottom - mainPanelY)
	self.mainPanel:setX((tw - w) / 2)
	self.mainPanel:setY(48)
	self.mainPanel:recalcSize()
	]]--
end

function GTTagInput:new (x, y, width, height, styles, cb)
	local o = {};
	o = ISCollapsableWindowJoypad.new(self, x, y, width, height);
	setmetatable(o, self);
	self.__index = self;

	o.styles = styles;
	o.callback = cb;
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
	
	GTTagInput.instance = o;
	return o;
end


return GTTagInput