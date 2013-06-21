local addonName, TSMCT = ...

local Monitor = TSMCT:NewModule("Monitor","AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local viewerST
local db 

function Monitor:OnEnable()
	TSMCT:Print(L["MonitorEnabled"])
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

	TSMCT:Print(L["MonitorDisabled"])
end

local viewerColInfo = {
	{name = L["MHeadName"], width = 0.25,},
	{name = L["MHeadLocation"],	width = 0.25,},
	{name = L["MHeadBefore"],width = 0.25,},
	{name = L["MHeadNow"],width = 0.25,},
}

local function GetColInfo(width)
	local colInfo = CopyTable(viewerColInfo)
	
	for i=1, #colInfo do
		colInfo[i].width = floor(colInfo[i].width*width)
	end
	
	return colInfo
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
		local nameR, nameG, nameB
		local timeR, TimeG
		
		if itemData.connected then
			nameR, nameG, nameB = 0.0, 1.0, 0.0
			timeR, timeG = 0.0, 1.0
		else
			nameR, nameG, nameB = 1.0, 0.0, 0.0
			timeR, timeG = 1.0, 0.0
		end
		
		if not itemData.inFriendList then
			nameR, nameG, nameB = 0.0, 0.0, 1.0
		end

		--if not itemData.previous then itemData.previous = 0 end
		
		tinsert(rowData, {
			cols = {
				{ value = itemData.name, color = { ["r"] = nameR, ["g"] = nameG, ["b"] = nameB, ["a"] = 1.0, } },
				{ value = itemData.location	},
				{ value = TSMCT.GetFormattedTime(itemData.previous, "period")},
				{ value = TSMCT.GetFormattedTime(itemData.modified, "ago") , color = { ["r"] = timeR, ["g"] = timeG, ["b"] = 0.0, ["a"] = 1.0, } },
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
	local colInfo = GetColInfo(parentFrame:GetWidth())
	
	if viewerST then 
		viewerST:Hide() 
	else
		viewerST = TSMAPI:CreateScrollingTable(colInfo, true)
		viewerST.frame:SetScript("OnSizeChanged", function(_,width, height)
			viewerST:SetDisplayCols(GetColInfo(width))
			viewerST:SetDisplayRows(floor(height/16), 16)
		end)
		
		--hack: TSM too high thumbText (150)
		local scrollBar = _G[viewerST.scrollframe:GetName().."ScrollBar"]
		local thumbTex = scrollBar:GetThumbTexture()
		thumbTex:SetHeight(30)
	end

	for i, col in ipairs(viewerST.head.cols) do
		col:SetHeight(32)
	end

	viewerST.frame:SetParent(parentFrame)
	viewerST.frame:SetPoint("BOTTOMLEFT")
	viewerST.frame:SetPoint("TOPRIGHT",0,-20)
	viewerST:Show()
end

function Monitor:Update()
	viewerST:SetData(GetSTData())
	viewerST:Refresh();
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