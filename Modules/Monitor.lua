local addonName, TSMCT = ...

local Monitor = TSMCT:NewModule("Monitor","AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local viewerST
local dbCharMonitor, dbData 

function Monitor:OnEnable()
	TSMCT:Chat(2,L["MonitorEnabled"])
	dbCharMonitor = TSMCT.db.char.Monitor
	dbData = TSMCT.db.factionrealm
	
	Monitor:CreateWindowWidget()
	Monitor.Window:Show()

	TSMAPI:CreateTimeDelay("CompMonitorUpdate", 10, Monitor.Update, 10)
end

function Monitor:OnDisable()
	TSMAPI:CancelFrame("CompMonitorUpdate")
	Monitor:UnhookAll()
	
	if viewerST then 
		viewerST:Hide() 
	end

	if Monitor.Window then
		Monitor.Window:Hide()
	end
end

function GetSTData()
	local compList, rowData = {}, {}
	
	for _, v in pairs(dbData.competitors) do
		if v.goblin then
			if v.connected then
				table.insert(compList, v)
			end
		else
			table.insert(compList, v)
		end
    end
	
	table.sort(compList, function (a, b) return a.modified > b.modified; end)
	
	for i=1,#compList do
		local itemData = compList[i]
		local name, nameColor, timeColor, notesText
		
		if itemData.goblin then
			name = itemData.goblin.."<<"..itemData.name
		else
			name = itemData.name
		end
		
		if itemData.connected then
			nameColor = "|cff00ff00"
			timeColor = "|cff00ff00"
		else
			nameColor = "|cff9482C9"
			timeColor = "|cff9482C9"
		end
		
		if not itemData.inFriendList then
			nameColor = "|cffFFF569"
		end

		if dbCharMonitor.NotesColumn == 2 then
			notesText = itemData.friendNote
		else
			notesText = itemData.location
		end
		
		tinsert(rowData, {
			cols = {
				{ value = nameColor..name.."|r" },
				{ value = notesText	},
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
	
	monitorWindow:SetStatusTable(dbCharMonitor.status)
	monitorWindow:SetTitle(L["MonitorTitle"])
	Monitor:SecureHook(monitorWindow.frame, "Hide", Monitor.MonitorHide)
	
	local parentFrame = monitorWindow.content
	
	if viewerST then 
		viewerST:Hide() 
	else
		local function GetNotesColumnText()
			if dbCharMonitor.NotesColumn == 2 then
				return L["MHeadNotes"]
			else
				return L["MHeadLocation"]
			end
		end

		local stCols = {
			{name = L["MHeadName"], width = 0.3,},
			{name = GetNotesColumnText(),	width = 0.3,},
			{name = L["MHeadBefore"],width = 0.2,},
			{name = L["MHeadNow"],width = 0.2,},
		}
		
		local handlers = {
			OnColumnClick = function(self, button)
				if self.colNum == 2 and button == "RightButton" then
					dbCharMonitor.NotesColumn = dbCharMonitor.NotesColumn + 1
					dbCharMonitor.NotesColumn = dbCharMonitor.NotesColumn > 2 and 1 or dbCharMonitor.NotesColumn
					self:SetText(GetNotesColumnText())
					viewerST:SetData(GetSTData())
				end
			end,
		}
		
		viewerST = TSMAPI:CreateScrollingTable(parentFrame, stCols, handlers)
		viewerST:EnableSorting(false)
		viewerST:DisableSelection(true)
	end

	viewerST:Show()
	viewerST:SetParent(parentFrame)
	viewerST:SetAllPoints()
	viewerST:SetData(GetSTData())
	
	--Scale the monitor window according to the config option
	if monitorWindow.frame:GetScale() ~= 1 and dbCharMonitor.FrameScale == 1 then 
		dbCharMonitor.FrameScale = monitorWindow.frame:GetScale() 
	end
	monitorWindow.frame:SetScale(dbCharMonitor.FrameScale)
end

function Monitor:Update()
	viewerST:SetData(GetSTData())
end

function Monitor.MonitorHide()
	TSMCT.MonitoringEnable(false)
end
