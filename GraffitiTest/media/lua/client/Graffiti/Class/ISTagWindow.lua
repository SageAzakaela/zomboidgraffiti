require "ISUI/ISCollapsableWindowJoypad";
require "ISUI/ISTabPanel";
require "ISUI/ISButton";
require "ISUI/ISInventoryPane";
require "ISUI/ISResizeWidget";
require "ISUI/ISMouseDrag";

local ISTagWindow = ISCollapsableWindowJoypad:derive("ISTagWindow");
local TABLE = require "Graffiti/Utils/Table";
local COLORS = require "Graffiti/Colors";

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISTagWindow:new (x, y, width, height, items, styles, square, dir, cb)
	local o = {};
	o = ISCollapsableWindowJoypad.new(self, x, y, width, height);
	setmetatable(o, self);
	self.__index = self;

	o.items = items;
	o.styles = styles;
	o.square = square;
	o.dir = dir;
	o.callback = cb;
	o.borderColor = { r=0.4, g=0.4, b=0.4, a=1 }
	o.backgroundColor = { r=0, g=0, b=0, a=0.8 }
	o.type = "text";
	o.itemheightoverride = {};
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.colorPanel = {};
	o.title = getText("UI_GT_Input_Title")
	o.titleFont = UIFont.Medium
	o.titleFontHgt = getTextManager():getFontHeight(o.titleFont)
	
	ISTagWindow.instance = o;
	return o;
end

function ISTagWindow:initialise()
	ISCollapsableWindowJoypad.initialise(self);
end

function ISTagWindow:instantiate()
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

function ISTagWindow:createChildren()
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
	self.tagEntryPanel:initialise()
	self.tagEntryPanel:instantiate()
	self.tagEntryPanel:setAnchorRight(true)
	self.tagEntryPanel:setAnchorLeft(true)
	self.tagEntryPanel:setAnchorBottom(true)
	self.tagEntryPanel:setAnchorTop(true)
	self.tabs:addView("Message", self.tagEntryPanel)

	self.colorEntryPanel = ISPanel:new(0, self.tabs.tabHeight, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
	self.colorEntryPanel:initialise()
	self.colorEntryPanel:instantiate()
	self.colorEntryPanel:setAnchorRight(true)
	self.colorEntryPanel:setAnchorLeft(true)
	self.colorEntryPanel:setAnchorBottom(true)
	self.colorEntryPanel:setAnchorTop(true)
	self.tabs:addView("Color", self.colorEntryPanel)

	self.backButton = ISButton:new(16, buttonBuffer, 100, buttonHgt, getText("UI_btn_cancel"), self, self.onOptionMouseDown);
	self.backButton.internal = "CANCEL";
	self.backButton:initialise();
	self.backButton:instantiate();
	self.backButton:setAnchorLeft(true);
	self.backButton:setAnchorTop(false);
	self.backButton:setAnchorBottom(true);
	self.backButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.buttonPanel:addChild(self.backButton);


	self.playButton = ISButton:new(self.tagEntryPanel.width - 116, buttonBuffer, 100, buttonHgt, getText("UI_GT_btn_tag"), self, self.onOptionMouseDown);
	self.playButton.internal = "TAG";
	self.playButton:initialise();
	self.playButton:instantiate();
	self.playButton:setAnchorLeft(false);
	self.playButton:setAnchorRight(true);
	self.playButton:setAnchorTop(false);
	self.playButton:setAnchorBottom(true);
	self.playButton:setEnable(false);
	self.buttonPanel:addChild(self.playButton);


	local labelMaxWid = 0
	labelMaxWid = math.max(labelMaxWid, getTextManager():MeasureStringX(UIFont.Small, getText("UI_GT_style_choice")))
	labelMaxWid = math.max(labelMaxWid, getTextManager():MeasureStringX(UIFont.Small, getText("UI_GT_text_entry")))
	
	local entryX = 16 + labelMaxWid + 6
	local entryHgt = math.max(FONT_HGT_SMALL + 2 * 2, FONT_HGT_MEDIUM)
	local labelY = (16 + (entryHgt / 2)) - (FONT_HGT_SMALL / 2)
	
	self.tagStylelabel = ISLabel:new(16, labelY, FONT_HGT_SMALL, getText("UI_GT_style_choice"), 1, 1, 1, 1, UIFont.Small, true)
	self.tagStylelabel:initialise()
	self.tagStylelabel:instantiate()
	self.tagStylelabel:setAnchorLeft(true)
	self.tagStylelabel:setAnchorTop(true)

	self.tagEntryPanel:addChild(self.tagStylelabel)
	
	labelY = (16 + entryHgt + 8) + (entryHgt / 2) - (FONT_HGT_SMALL / 2)

	self.tagTypelabel = ISLabel:new(16, labelY, FONT_HGT_SMALL, getText("UI_GT_text_entry"), 1, 1, 1, 1, UIFont.Small, true)
	self.tagTypelabel:initialise()
	self.tagTypelabel:instantiate()
	self.tagTypelabel:setAnchorLeft(true)
	self.tagTypelabel:setAnchorTop(true)

	self.tagEntryPanel:addChild(self.tagTypelabel)	

	self.tagStyleEntry = ISComboBox:new(entryX, 16, self.width - entryX - 16, entryHgt, self, self.onChangeComboBox)
	self.tagStyleEntry:initialise()
	self.tagStyleEntry:instantiate()
	self.tagStyleEntry:setAnchorLeft(true)
	self.tagStyleEntry:setAnchorRight(true)
	self.tagStyleEntry:setAnchorTop(true)
	self.tagStyleEntry:setAnchorBottom(false)
	self.tagStyleEntry:setEditable(false)

	for k, v in pairs(self.styles) do
		self.tagStyleEntry:addOptionWithData(v.displayName, v);
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

	self.tagSymbolEntry = ISComboBox:new(entryX, 16 + 8 + entryHgt, self.width - entryX - 16, entryHgt, self, self.onChangeComboBox)
	self.tagSymbolEntry:initialise()
	self.tagSymbolEntry:instantiate()
	self.tagSymbolEntry:setAnchorLeft(true)
	self.tagSymbolEntry:setAnchorRight(true)
	self.tagSymbolEntry:setAnchorTop(true)
	self.tagSymbolEntry:setAnchorBottom(false)
	self.tagSymbolEntry:setEditable(false)
	self.tagSymbolEntry:setVisible(false)

	for k, v in pairs(self.styles.mod_graffiti_symbols.charIndexes) do
		self.tagSymbolEntry:addOptionWithData(k, k);
	end

	self.tagEntryPanel:addChild(self.tagSymbolEntry)

	local colorPadding = 16
	local showColors = 0

	for k in pairs(COLORS) do
		for i = 1, TABLE.size(self.items) do
			local color = string.sub(self.items[i]:getFullType(), 18, -1)
			
			if k == color then
				local colorRGB = self.items[i]:getModData().Graffiti.Color;
				self.DrawColor = ISButton:new(colorPadding, 16, 45, 45, "", self, self.onOptionMouseDown)
				self.DrawColor:initialise()
				self.DrawColor:instantiate()
				self.DrawColor:setBackgroundRGBA(colorRGB.r, colorRGB.g, colorRGB.b, colorRGB.a);
				self.DrawColor:setBackgroundColorMouseOverRGBA(colorRGB.r + 0.1, colorRGB.g + 0.1, colorRGB.b + 0.1, colorRGB.a)
				self.DrawColor.internal = "COLOR";
				self.DrawColor.data = self.items[i];

				self.colorEntryPanel:addChild(self.DrawColor)

				colorPadding = colorPadding + 16 + 45;
				showColors = showColors + 1;
				break;
			end
		end
	end

	if showColors == 1 then
		self.itemSelected = self.items[1]
		self.playButton:setEnable(true);
	end
end

function ISTagWindow:getSquare()
	return self.square;
end

function ISTagWindow:getDir()
	return self.dir;
end

function ISTagWindow:getStyle()
	return self.tagStyleEntry.options[self.tagStyleEntry.selected].data;
end

function ISTagWindow:getEntry()

	if self:getStyle().tilesetType == "text" then
		return self.tagTextEntry:getText();
	else
		return self.tagSymbolEntry.options[self.tagSymbolEntry.selected].data;
	end

	return nil;
end

function ISTagWindow:setVisible(bVisible, joypadData)
	if self.javaObject == nil then
		self:instantiate();
	end
	
	ISCollapsableWindowJoypad.setVisible(self, bVisible, joypadData)
end


function ISTagWindow:onOptionMouseDown(button)
	
	if button.internal == "CANCEL" then
		self:setVisible(false, nil);
	end
	if button.internal == "TAG" then
		self:setVisible(false, nil);
		self.callback(self.itemSelected, self:getSquare(), self:getDir(), self:getStyle(), self:getEntry());
	end

	if button.internal == "COLOR" then
		self.itemSelected = button.data;
		self.playButton:setEnable(true);
	end
end

function ISTagWindow:onChangeComboBox(combo)

	if self:getStyle().tilesetType == "text" then
		self.tagTextEntry:setVisible(true)
		self.tagSymbolEntry:setVisible(false)
		self.tagTypelabel:setName(getText("UI_GT_text_entry"))
	else
		self.tagTextEntry:setVisible(false)
		self.tagSymbolEntry:setVisible(true)
		self.tagTypelabel:setName("Graffiti Symbol")
	end
end


function ISTagWindow:prerender()
	ISTagWindow.instance = self
	ISCollapsableWindowJoypad.prerender(self);
end

function ISTagWindow:onGainJoypadFocus(joypadData)
	ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData);
	self:setISButtonForA(self.playButton);
	self:setISButtonForB(self.backButton);
	self:setISButtonForY(self.randomButton);
	self:loadJoypadButtons(joypadData);
end

function ISTagWindow:onLoseJoypadFocus(joypadData)
	self.playButton:clearJoypadButton()
	self.backButton:clearJoypadButton()
	self.randomButton:clearJoypadButton()
	ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
end

function ISTagWindow:onJoypadDirLeft(joypadData)
	joypadData.focus = self.presetPanel
	updateJoypadFocus(joypadData)
end

function ISTagWindow:onJoypadDirRight(joypadData)
	joypadData.focus = self.presetPanel
	updateJoypadFocus(joypadData)
end

function ISTagWindow:onJoypadDirUp(joypadData)
	joypadData.focus = self.characterPanel
	updateJoypadFocus(joypadData)
end


function ISTagWindow:onResolutionChange(oldw, oldh, neww, newh)
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
end


return ISTagWindow