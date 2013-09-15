-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Window.lua
-- This Window container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "CTMWindow", 2
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent


--[[----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function frameOnClose(frame)
	frame.obj:Fire("OnClose")
end

local function closeOnClick(frame)
	PlaySound("gsTitleOptionExit")
	frame.obj:Hide()
end

local function frameOnMouseDown(frame)
	frame:StartMoving()
	AceGUI:ClearFocus()
end

local function frameOnMouseUp(frame)
	frame:StopMovingOrSizing()
	AceGUI:ClearFocus()

	local self = frame.obj
	local status = self.status or self.localstatus
	
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
end

local function sizerOnMouseDown(sizerFrame)
	sizerFrame:GetParent():StartSizing("BOTTOMRIGHT")
	AceGUI:ClearFocus()
end

local function sizerOnMouseUp(sizerFrame)
	local frame = sizerFrame:GetParent()
	frameOnMouseUp(frame)
end


--[[----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("MEDIUM")
		self:ApplyStatus()
		self:EnableResize(true)
		self:Show()
	end,
	
	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,
	
	["Show"] = function(self)
		self.frame:Show()
	end,
	
	["Hide"] = function(self)
		self.frame:Hide()
	end,
	
	["SetTitle"] = function(self,title)
		self.titletext:SetText(title)
	end,
	
	-- called to set an external table to store status in
	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 300)
		self:SetHeight(status.height or 200)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end,
	
	["EnableResize"] = function(self, state)
		local func = state and "Show" or "Hide"
		
		self.sizer[func](self.sizer)
	end,
	
	
	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,
	
	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local unicID = AceGUI:GetNextWidgetNum(Type)
	local frameName = Type..unicID
	local contentFrameName = Type.."Content"..unicID
	
	local frame = CreateFrame("Frame",frameName,  UIParent)
	frame:Hide()
	
	frame:SetPoint("CENTER")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("MEDIUM")
	frame:SetScript("OnMouseDown", frameOnMouseDown)
	frame:SetScript("OnMouseUp", frameOnMouseUp)
	frame:SetScript("OnHide", frameOnClose)
	frame:SetMinResize(250,125)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
	close:SetScript("OnClick", closeOnClick)
	
	local titletext = frame:CreateFontString(nil, "ARTWORK")
	titletext:SetFont(TSMAPI.Design:GetBoldFont(), 18)
	TSMAPI.Design:SetTitleTextColor(titletext)
	titletext:SetPoint("TOP", 0, -4)
	
	local line = frame:CreateTexture()
	line:SetPoint("TOPLEFT", 2, -28)
	line:SetPoint("TOPRIGHT", -2, -28)
	line:SetHeight(2)
	TSMAPI.Design:SetIconRegionColor(line)
	
	local sizer = CreateFrame("Frame",nil,frame)
	sizer:SetPoint("BOTTOMRIGHT", -2, 2)
	sizer:SetWidth(20)
	sizer:SetHeight(20)
	sizer:EnableMouse()
	sizer:SetScript("OnMouseDown",sizerOnMouseDown)
	sizer:SetScript("OnMouseUp", sizerOnMouseUp)
	local image = sizer:CreateTexture(nil, "BACKGROUND")
	image:SetAllPoints()
	image:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\Sizer")
	
	--Container Support
	local content = CreateFrame("Frame", contentFrameName, frame)
	content:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 13)
	
	local widget = {
		type = Type,

		frame = frame,
		content = content,
		sizer = sizer,
		title = title,
		titletext = titletext,
		closebutton = close,

		localstatus = {},
	}
	
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj, content.obj, close.obj = widget, widget, widget
	
	widget.Add = TSMAPI.AddGUIElement
	
	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type,Constructor,Version)