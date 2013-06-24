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
end

local function sizerseOnMouseDown(sizerFrame)
	sizerFrame:GetParent():StartSizing("BOTTOMRIGHT")
	AceGUI:ClearFocus()
end

local function sizersOnMouseDown(sizerFrame)
	sizerFrame:GetParent():StartSizing("BOTTOM")
	AceGUI:ClearFocus()
end

local function sizereOnMouseDown(sizerFrame)
	sizerFrame:GetParent():StartSizing("RIGHT")
	AceGUI:ClearFocus()
end

local function sizerOnMouseUp(sizerFrame)
	sizerFrame:GetParent():StopMovingOrSizing()
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
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
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
	
	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end,
	
	["EnableResize"] = function(self, state)
		local func = state and "Show" or "Hide"
		
		self.sizer_se[func](self.sizer_se)
		self.sizer_s[func](self.sizer_s)
		self.sizer_e[func](self.sizer_e)
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
	frame:SetWidth(300)
	frame:SetHeight(150)
	frame:SetPoint("CENTER")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("MEDIUM")
	frame:SetScript("OnMouseDown", frameOnMouseDown)
	frame:SetScript("OnMouseUp", frameOnMouseUp)
	frame:SetScript("OnHide", frameOnClose)
	frame:SetMinResize(250,100)
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
	
	local sizer_se = CreateFrame("Frame",nil,frame)
	sizer_se:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
	sizer_se:SetWidth(25)
	sizer_se:SetHeight(25)
	sizer_se:EnableMouse()
	sizer_se:SetScript("OnMouseDown",sizerseOnMouseDown)
	sizer_se:SetScript("OnMouseUp", sizerOnMouseUp)
	
	local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line1:SetWidth(14)
	line1:SetHeight(14)
	line1:SetPoint("BOTTOMRIGHT", -8, 8)
	line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	local x = 0.1 * 14/17
	line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

	local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line2:SetWidth(8)
	line2:SetHeight(8)
	line2:SetPoint("BOTTOMRIGHT", -8, 8)
	line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	local x = 0.1 * 8/17
	line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)
	
	local sizer_s = CreateFrame("Frame",nil,frame)
	sizer_s:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-25,0)
	sizer_s:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",0,0)
	sizer_s:SetHeight(25)
	sizer_s:EnableMouse()
	sizer_s:SetScript("OnMouseDown",sizersOnMouseDown)
	sizer_s:SetScript("OnMouseUp", sizerOnMouseUp)
		
	local sizer_e = CreateFrame("Frame",nil,frame)
	sizer_e:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,25)
	sizer_e:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
	sizer_e:SetWidth(25)
	sizer_e:EnableMouse()
	sizer_e:SetScript("OnMouseDown",sizereOnMouseDown)
	sizer_e:SetScript("OnMouseUp", sizerOnMouseUp)


	--Container Support
	local content = CreateFrame("Frame", contentFrameName, frame)
	content:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 13)
	
	local widget = {
		frame = frame,
		content = content,

		type = Type,
		localstatus = {},
		title = title,
		titletext = titletext,
		closebutton = close,
		
		sizer_se = sizer_se,
		line1 = line1,
		line2 = line2,
		sizer_s = sizer_s,
		sizer_e = sizer_e,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj, content.obj, close.obj = widget, widget, widget
	
	widget.Add = TSMAPI.AddGUIElement
	
	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type,Constructor,Version)