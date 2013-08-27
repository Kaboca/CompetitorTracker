local addonName, TSMCT = ...

local Monitor = TSMCT:NewModule("Monitor","AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local viewerST
local db 

function Monitor:OnEnable()
	TSMCT:Chat(2,L["MonitorEnabled"])
	db = TSMCT.db.char.Monitor
	
	Monitor:CreateWindowWidget()
	Monitor.Window:Show()
	
	TSMAPI:CreateTimeDelay("CompMonitorUpdate", 10, Monitor.Update, 10)
end

function Monitor:OnDisable()
	TSMAPI:CancelFrame("CompMonitorUpdate")
	
	if Monitor.Window then
		Monitor.Window:Hide()
	end

	TSMCT:Chat(2,L["MonitorDisabled"])
end

function GetSTData()
	local compList, rowData = {}, {}
	
	for _, v in pairs(TSMCT.db.factionrealm.competitors) do
        table.insert(compList, v)
    end
	
	table.sort(compList, function (a, b) return a.modified > b.modified; end)
	
	--for i=1,math.min(#compList,6) do
	for i=1,#compList do
		local itemData = compList[i]
		local nameColor, timeColor
		
		if itemData.connected then
			nameColor = "|cff00ff00"
			timeColor = "|cff00ff00"
		else
			nameColor = "|cffff0000"
			timeColor = "|cffff0000"
		end
		
		if not itemData.inFriendList then
			nameColor = "|cff0000ff"
		end

		--if not itemData.previous then itemData.previous = 0 end
		
		tinsert(rowData, {
			cols = {
				{ value = nameColor..itemData.name.."|r" },
				{ value = itemData.location	},
				{ value = TSMCT.GetFormattedTime(itemData.previous, "period")},
				{ value = timeColor..TSMCT.GetFormattedTime(itemData.modified, "ago").."|r"},
			},
		})
	end
	
	return rowData
end

function Monitor:CreateWindowWidget()
	local monitorWindow = AceGUI:Create("CTMWindow")
	Monitor.Window = monitorWindow
	
	monitorWindow:SetWidth(db.width)
	monitorWindow:SetHeight(db.height)
	monitorWindow:SetPoint(db.point, UIParent, db.relativePoint, db.offsetX, db.offsetY)
	
	monitorWindow:SetTitle(L["MonitorTitle"])
	
	Monitor:SecureHook(monitorWindow.frame, "StopMovingOrSizing", Monitor.StopMovingOrSizing)
	
	local parentFrame = monitorWindow.content
	
	if viewerST then 
		viewerST:Hide() 
	else
		local stCols = {
			{name = L["MHeadName"], width = 0.25,},
			{name = L["MHeadLocation"],	width = 0.25,},
			{name = L["MHeadBefore"],width = 0.25,},
			{name = L["MHeadNow"],width = 0.25,},
		}
		
		local handlers = {}
		
		viewerST = TSMAPI:CreateScrollingTable(parentFrame, stCols, handlers)
		viewerST:EnableSorting(false)
		viewerST:DisableSelection(true)
	end

	viewerST:Show()
	viewerST:SetParent(parentFrame)
	
	--viewerST:SetPoint("BOTTOMLEFT")
	--viewerST:SetPoint("TOPRIGHT",0,-20)
	
end

function Monitor:Update()
	viewerST:SetData(GetSTData())
end

function Monitor:StopMovingOrSizing()
	local point, relativeTo, relativePoint, xOfs, yOfs = Monitor.Window:GetPoint(1)
	
	db.point=point
    db.relativeTo=relativeTo
    db.relativePoint=relativePoint
    db.offsetX=xOfs
    db.offsetY=yOfs
	
    db.width=Monitor.Window.frame:GetWidth()
    db.height=Monitor.Window.frame:GetHeight()
end