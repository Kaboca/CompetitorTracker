local addonName, TSMCT = ...

local Private = {}
local Config = TSMCT:NewModule("Config", "AceHook-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local viewerST

local configDB, dataDB

local CompetitorsTree = {
	{ value=1, text = L["TreeOptions"], },
	{ value=2, text = L["TreeCompetitors"], children = { }, },
}

function Config:Load(parent)
	configDB  = TSMCT.db.profile
	dataDB = TSMCT.db.factionrealm
	
	local treeGroup = AceGUI:Create("TSMTreeGroup")
	treeGroup:SetLayout("Fill")
	treeGroup:SetCallback("OnGroupSelected", Private.SelectTree)
	treeGroup:SetStatusTable(configDB.treeGroupStatus)
	
	parent:AddChild(treeGroup)
	Private.UpdateTree()
	
	treeGroup:SetTree(CompetitorsTree)
	treeGroup:SelectByPath(1)
end

function Private.UpdateTree()
	wipe(CompetitorsTree[2].children)

	for k, v in pairs(dataDB.competitors) do
		local treeItem = {value=k, text=k}
		tinsert(CompetitorsTree[2].children,treeItem)
    end
	
	sort(CompetitorsTree[2].children, function(a, b) return strlower(a.value) < strlower(b.value) end)
end

function Private.SelectTree(treeFrame, _, selection)
	treeFrame:ReleaseChildren()

	local content = AceGUI:Create("TSMSimpleGroup")
	content:SetLayout("Fill")
	treeFrame:AddChild(content)
	content:DoLayout()
		
	local selectedParent, selectedChild, selectedSubChild = ("\001"):split(selection)
	--print(selectedParent, selectedChild, selectedSubChild)
	
	if not selectedChild or tonumber(selectedchild) == 0 then
		if tonumber(selectedParent) == 1 then
			content:AddChild(Private.CreateOptionsTabGroup(content))
		elseif tonumber(selectedParent) == 2 then
			content:AddChild(Private.CreateGeneralTabGroup(content))
		end
	else
		content:AddChild(Private.CreateCompetitorTabGroup(content, selectedChild))
	end
end

function Private.CreateOptionsTabGroup(content)
	local TabbedGroup = AceGUI:Create("TSMTabGroup")
	TabbedGroup:SetLayout("Fill")
	TabbedGroup:SetFullWidth(true)
	TabbedGroup:SetFullHeight(true)
	TabbedGroup:SetTabs({
		{value=1, text=L["OptTabOptions"]},
		{value=2, text=L["OptTabProfiles"]},
	})
	TabbedGroup:SetCallback("OnGroupSelected",function(self,Crap,value)
		TabbedGroup:ReleaseChildren()
		content:DoLayout()
		if value==1 then
			Private.OptionsMain(TabbedGroup)
		elseif value==2 then
			Private.ProfilesPage(TabbedGroup, function() TabbedGroup:SelectTab(2) end)
		end
	end)
	TabbedGroup:SelectTab(1)
	
	return TabbedGroup
end

function Private.OptionsMain(parent)

	local page = { 
		{
			type = "SimpleGroup",
			layout = "list",
	
			children = {
				{
					type="InlineGroup",
					layout="Flow",
					title="Options",
					children = {
						{
							type = "CheckBox",
							value = configDB.DataModuleEnabled,
							label = L["OptDataModuleEnabledLabel"],
							relativeWidth = 0.5,
							disabled = false,
							tooltip = L["OptDataModuleEnabledInfo"],
							callback = function(self,_,value) 
								TSMCT.TrackingEnable(value);
								self.parent.children[3]:SetValue(value)
							end,
						},
						{
							type = "Slider",
							value = configDB.TrackMaxRecord,
							label = L["OptTrackMaxRecordLabel"],
							relativeWidth = 0.5,
							min = 1,
							max = 100,
							step = 1,
							callback = function(_,_,value) configDB.TrackMaxRecord = value end,
							tooltip = L["OptTrackMaxRecordInfo"],
						},
						{
							type = "CheckBox",
							value = configDB.MonitorModuleEnabled,
							label = L["OptMonitorModuleEnabledLabel"],
							fullWidth = true,
							disabled = false,
							tooltip = L["OptMonitorModuleEnabledInfo"],
							callback = function(_,_,value) TSMCT.MonitoringEnable(value) end,
						},
						{
							type = "CheckBox",
							value = configDB.TrackMarked,
							label = L["OptTrackMakedLabel"],
							fullWidth = false,
							disabled = false,
							tooltip = L["OptTrackMakedInfo"],
							callback = function(_,_,value) 
								if value == true then configDB.TrackMarked = true; else configDB.TrackMarked = false;	end
							end,
						},
						{
							type = "EditBox",
							value = configDB.TrackMark,
							label = L["OptTrackMakLabel"],
							relativeWidth = 0.5,
							disabled = false,
							disabledTooltip = L["OptTrackMakDisabledInfo"],
							callback = function(self, _, value) configDB.TrackMark = value end,
							tooltip = L["OptTrackMakInfo"],
						},
						
						{
							type = "CheckBox",
							value = configDB.SyncCompetitors,
							label = L["OptSyncLabel"],
							fullWidth = false,
							disabled = false,
							tooltip = L["OptSyncInfo"],
							callback = function(_,_,value) 
								if value == true then configDB.SyncCompetitors = true; else configDB.SyncCompetitors = false;	end
							end,
						},
						
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(parent, page)
end

function Private.ProfilesPage(parent,refreshPage)
	local AceDB = TSMCT.db
	
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMCompetitorTrackerProfiles.DeleteConfirm"] = StaticPopupDialogs["TSMCompetitorTrackerProfiles.DeleteConfirm"] or {
		text = L["ProfileDeleteSure"],
		button1 = L["ProfileAccept"],
		button2 = L["ProfileCancel"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}
	
	-- Returns a list of all the current profiles with common and nocurrent modifiers.
	-- This code taken from AceDBOptions-3.0.lua
	local function GetProfileList(db, common, nocurrent)
		local profiles = {}
		local tmpprofiles = {}
		local defaultProfiles = {["Default"] = L["ProfileDefault"]}
		
		-- copy existing profiles into the table
		local currentProfile = db:GetCurrentProfile()
		for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
			if not (nocurrent and v == currentProfile) then 
				profiles[v] = v 
			end 
		end
		
		-- add our default profiles to choose from ( or rename existing profiles)
		for k,v in pairs(defaultProfiles) do
			if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
				profiles[k] = v
			end
		end
		
		return profiles
	end
	
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Profile Options",
					noBorder = true,
					children = {
						{
							type = "Label",
							text = L["ProfileIntro"] .. "\n" .. "\n",
							fullWidth = true,
						},
						{
							type = "Label",
							text = L["ProfileResetDesc"],
							fullWidth = true,
						},
						{	--simplegroup1 for the reset button / current profile text
							type = "SimpleGroup",
							layout = "flow",
							fullWidth = true,
							children = {
								{
									type = "Button",
									text = L["ProfileReset"],
									callback = function()
											AceDB:ResetProfile()
											refreshPage()
										end,
								},
								{
									type = "Label",
									text = L["ProfileCurrent"] .. " " .. TSMAPI.Design:GetInlineColor("link") .. AceDB:GetCurrentProfile() .. "|r",
								},
							},
						},
						{
							type = "Spacer",
							quantity = 2,
						},
						{
							type = "Label",
							text = L["ProfileChooseDesc"],
							fullWidth = true,
						},
						{	--simplegroup2 for the new editbox / existing profiles dropdown
							type = "SimpleGroup",
							layout = "flow",
							fullWidth = true,
							children = {
								{
									type = "EditBox",
									label = L["ProfileNew"],
									value = "",
									callback = function(_,_,value) 
											AceDB:SetProfile(value)
											refreshPage()
										end,
								},
								{
									type = "Dropdown",
									label = L["ProfileChoose"],
									list = GetProfileList(AceDB, true, nil),
									value = AceDB:GetCurrentProfile(),
									callback = function(_,_,value)
											if value ~= AceDB:GetCurrentProfile() then
												AceDB:SetProfile(value)
												refreshPage()
											end
										end,
								},
							},
						},
						{
							type = "Spacer",
							quantity = 1,
						},
						{
							type = "Label",
							text = L["ProfileCopyDesc"],
							fullWidth = true,
						},
						{
							type = "Dropdown",
							label = L["ProfileCopy"],
							list = GetProfileList(AceDB, true, nil),
							value = "",
							disabled = not GetProfileList(AceDB, true, nil) and true,
							callback = function(_,_,value)
									if value ~= AceDB:GetCurrentProfile() then
										AceDB:CopyProfile(value)
										refreshPage()
									end
								end,
						},
						{
							type = "Spacer",
							quantity = 2,
						},
						{
							type = "Label",
							text = L["ProfileDeleteDesc"],
							fullWidth = true,
						},
						{
							type = "Dropdown",
							label = L["ProfileDelete"],
							list = GetProfileList(AceDB, true, nil),
							value = "",
							disabled = not GetProfileList(AceDB, true, nil) and true,
							callback = function(_,_,value)
									StaticPopupDialogs["TSMCompetitorTrackerProfiles.DeleteConfirm"].OnAccept = function()
											AceDB:DeleteProfile(value)
											refreshPage()
										end
									TSMAPI:ShowStaticPopupDialog("TSMCompetitorTrackerProfiles.DeleteConfirm")
								end,
						}
					}
				}
			}
		}
	}
	
	TSMAPI:BuildPage(parent, page)
end


-- Tree - Competitor Section --
function Private.CreateGeneralTabGroup(content)
	local TabbedGroup = AceGUI:Create("TSMTabGroup")
	TabbedGroup:SetLayout("Fill")
	TabbedGroup:SetFullWidth(true)
	TabbedGroup:SetFullHeight(true)
	
	TabbedGroup:SetTabs({
		{value=1, text=L["DeletedTab"]},
	})
	
	TabbedGroup:SetCallback("OnGroupSelected",function(self,Crap,value)
		TabbedGroup:ReleaseChildren()
		content:DoLayout()
		
		if value==1 then
			Private.CreateDeletedCompTab(TabbedGroup, function() TabbedGroup:SelectTab(1) end)
		end
	end)
	TabbedGroup:SelectTab(1)

	return TabbedGroup
end

local function RemoveDeletedCompetitorFromList(TabbedGroup, competitor, refreshPage)
	if competitor and dataDB.deleted[competitor] then
		dataDB.deleted[competitor] = nil
		refreshPage()
	end
end

function Private.CreateDeletedCompTab(content, refreshPage)
	local deletedWidgets = { }
	
	for competitor, _ in pairs(dataDB.deleted) do
		local widgets = { 
			{ 	type = "Label", text = competitor, relativeWidth = 0.7,	},
			{ 	type = "Button", text = "Remove", relativeWidth = 0.3,
				callback = function() RemoveDeletedCompetitorFromList(content, competitor, refreshPage) end,
			}
		}

		for _, widget in ipairs(widgets) do
			tinsert(deletedWidgets, widget)
		end
	end

	local page = { 
		{
			type = "ScrollFrame",
			layout = "flow",
			fullHeight = true,
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["DeletedTitle"],
					relativeWidth = 1,
					children = {
						{ type = "Label", relativeWidth = 1, text = L["DeletedInfo"] },
						{ type = "Spacer", },
						{ type = "HeadingLine", },
						{ type = "SimpleGroup", layout = "flow", children = deletedWidgets, }
					}
				}
			}
		}
	}
	
	TSMAPI:BuildPage(content, page)
end

function Private.CreateCompetitorTabGroup(content,selectedChild)
	local groupTabs = {}

	groupTabs[1] = {value=1, text="History"}

	local TabbedGroup = AceGUI:Create("TSMTabGroup")
	TabbedGroup:SetLayout("Fill")
	TabbedGroup:SetFullWidth(true)
	TabbedGroup:SetFullHeight(true)
	TabbedGroup:SetTabs(groupTabs)
	TabbedGroup:SetCallback("OnGroupSelected",function(self,Crap,value)
		if viewerST then viewerST:Hide() end
		TabbedGroup:ReleaseChildren()
		content:DoLayout()

		if value==1 then
			Private.PersonHistory(TabbedGroup,selectedChild)
		end
	end)
	TabbedGroup:SelectTab(1)
	
	Config:HookScript(TabbedGroup.frame, "OnHide", function()
		Config:UnhookAll()
		if viewerST then viewerST:Hide() end
	end)
	
	return TabbedGroup
end

-- Viewer Section --
local viewerColInfo = {
	{ name = L["VHeadTime"],     width = 0.2, },
	{ name = L["VHeadPeriode"],  width = 0.2, },
	{ name = L["VHeadLocation"], width = 0.6, },
}

local function GetColInfo(width)
	local colInfo = CopyTable(viewerColInfo)
	
	for i=1, #colInfo do
		colInfo[i].width = floor(colInfo[i].width*width)
	end
	
	return colInfo
end

function GetHistoryData(competitor)
	local rowData = {}
	--TSMCT:Print(competitor.name)
	
	if competitor.records and #competitor.records > 0 then 
		local history = CopyTable(competitor.records)
		
		for i=1,#history-1 do
			history[i].periode = history[i+1].modified-history[i].modified
		end
		history[#history].periode = competitor.modified - history[#history].modified
		
		for i=#history,1,-1 do
			local itemData = history[i]
			local timeR, TimeG
			
			if itemData.connected then
				timeR, timeG = 0.0, 1.0
			else
				timeR, timeG = 1.0, 0.0
			end

			tinsert(rowData, {
				cols = {
					{ value = TSMCT.GetFormattedTime(itemData.modified, "aidate") },
					{ value = TSMCT.GetFormattedTime(itemData.periode, "period") },
					{ value = itemData.location, color = { ["r"] = timeR, ["g"] = timeG, ["b"] = 0.0, ["a"] = 1.0, } },
				},
			})
		end
	end
	return rowData
end

function Private.PersonHistory(container,name)
	local competitor = dataDB.competitors[name] 
	if not competitor then return end
	
	local linkColor = TSMAPI.Design:GetInlineColor("link")
	
	local page = { 
		{	-- scroll frame to contain everything
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Competitor Data",
					children = {
						{
							type = "Label",
							text = linkColor..L["CName"]..":|r"..name ,
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = linkColor..L["CClass"]..":|r"..competitor.class..linkColor.." "..L["CLevel"]..":|r"..competitor.level,
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = linkColor..L["CLocation"]..":|r"..competitor.location ,
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = linkColor..L["CStatus"]..":|r"..competitor.status ,
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = linkColor..L["CNote"]..":|r"..(competitor.friendNote or "") ,
							relativeWidth = 1,
						},
						
					}
				},
				{
					type = "SimpleGroup",
					layout = "Flow",
					fullHeight = true,
					children = {},
				},
			}
		}
	}

	TSMAPI:BuildPage(container, page)

	-- scrolling table
	local colInfo = GetColInfo(container.frame:GetWidth())
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not viewerST then
		viewerST = TSMAPI:CreateScrollingTable(colInfo, true)
	end

	viewerST.frame:SetParent(stParent)
	viewerST.frame:SetPoint("BOTTOMLEFT")
	viewerST.frame:SetPoint("TOPRIGHT", 0, -20)
	viewerST.frame:SetScript("OnSizeChanged", function(_,width, height)
			viewerST:SetDisplayCols(GetColInfo(width))
			viewerST:SetDisplayRows(floor(height/16), 16)
		end)
	viewerST:Show()
	viewerST:SetData(GetHistoryData(competitor))
	for i, col in ipairs(viewerST.head.cols) do
		col:SetHeight(32)
	end
end

