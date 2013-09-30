local addonName, TSMCT = ...

local Monitor = TSMCT:NewModule("Monitor","AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local viewerST
local db 

function Monitor:OnEnable()
	TSMCT:Chat(2,L["MonitorEnabled"])
	db = TSMCT.db.char.Monitor
	
	if db.version < 2 then
		Monitor.ResetDB()
	end
	
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
	
	for _, v in pairs(TSMCT.db.factionrealm.competitors) do
        table.insert(compList, v)
    end
	
	table.sort(compList, function (a, b) return a.modified > b.modified; end)
	
	--for i=1,math.min(#compList,6) do
	for i=1,#compList do
		local itemData = compList[i]
		local nameColor, timeColor, notesText
		
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

		if db.NotesColumn == 2 then
			notesText = itemData.friendNote
		else
			notesText = itemData.location
		end
		--if not itemData.previous then itemData.previous = 0 end
		
		tinsert(rowData, {
			cols = {
				{ value = nameColor..itemData.name.."|r" },
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
	
	monitorWindow:SetStatusTable(db.status)
	monitorWindow:SetTitle(L["MonitorTitle"])
	Monitor:SecureHook(monitorWindow.frame, "Hide", Monitor.MonitorHide)
	
	local parentFrame = monitorWindow.content
	
	if viewerST then 
		viewerST:Hide() 
	else
		local function GetNotesColumnText()
			if db.NotesColumn == 2 then
				return L["MHeadNotes"]
			else
				return L["MHeadLocation"]
			end
		end

		local stCols = {
			{name = L["MHeadName"], width = 0.25,},
			{name = GetNotesColumnText(),	width = 0.25,},
			{name = L["MHeadBefore"],width = 0.25,},
			{name = L["MHeadNow"],width = 0.25,},
		}
		
		local handlers = {
			OnColumnClick = function(self, button)
				if self.colNum == 2 and button == "RightButton" then
					db.NotesColumn = db.NotesColumn + 1
					db.NotesColumn = db.NotesColumn > 2 and 1 or db.NotesColumn
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
end

function Monitor:Update()
	viewerST:SetData(GetSTData())
end

function Monitor.MonitorHide()
	TSMCT.MonitoringEnable(false)
end

function Monitor.ResetDB()
	if db and db.version < 2 then
		db.version = 2
		
		db.point = nil
		db.relativePoint = nil
		db.height = nil
		db.offsetY = nil
		db.offsetX = nil
		db.width = nil

		TSMCT:Chat(1,"Monitor-Window position data cleaned and upgraded according to the new addon version.")
	end
end