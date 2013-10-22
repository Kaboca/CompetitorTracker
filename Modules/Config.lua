local addonName, TSMCT = ...

local Private = {}
local Config = TSMCT:NewModule("Config", "AceHook-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local viewerST

local configDB, dataDB, charDB

local CompetitorsTree = {
	{ value=1, text = L["TreeOptions"], },
	{ value=2, text = L["TreeCompetitors"], children = { }, },
}

function Config:Load(parent)
	configDB  = TSMCT.db.profile
	dataDB = TSMCT.db.factionrealm
	charDB = TSMCT.db.char
	
	Private.treeGroup = AceGUI:Create("TSMTreeGroup")
	local treeGroup = Private.treeGroup 
	
	treeGroup:SetLayout("Fill")
	treeGroup:SetCallback("OnGroupSelected", Private.SelectTree)
	treeGroup:SetStatusTable(configDB.treeGroupStatus)
	
	parent:AddChild(treeGroup)
	Private.UpdateTree()
	treeGroup:SelectByPath(1)
end

function Private.UpdateTree()
	wipe(CompetitorsTree[2].children)
	
	local ts = {}
	for k, v in pairs(dataDB.competitors) do
		if v.goblin then
			if not ts[v.goblin] then
				ts[v.goblin] = {}
			end
			local treeItem = {value=k, text=k}
			tinsert(ts[v.goblin],treeItem)
		else
			if not ts[k] then
				ts[k] = {}
			end
		end
    end

	for k, v in pairs(ts) do
		local treeItem = {value=k, text=k}
		
		if #v>0 then
			treeItem.children = v
		end
		
		tinsert(CompetitorsTree[2].children,treeItem)
    end
	
	sort(CompetitorsTree[2].children, function(a, b) return strlower(a.value) < strlower(b.value) end)

	Private.treeGroup:SetTree(CompetitorsTree)
end

function Private.SelectTree(treeFrame, _, selection)
	treeFrame:ReleaseChildren()

	local content = AceGUI:Create("TSMSimpleGroup")
	content:SetLayout("Fill")
	treeFrame:AddChild(content)
	content:DoLayout()
		
	local selectedParent, selectedChild, selectedSubChild = ("\001"):split(selection)
	
	if not selectedChild or tonumber(selectedchild) == 0 then
		if tonumber(selectedParent) == 1 then
			content:AddChild(Private.CreateOptionsTabGroup(content))
		elseif tonumber(selectedParent) == 2 then
			content:AddChild(Private.CreateGeneralTabGroup(content))
		end
	else
		if selectedSubChild then
			content:AddChild(Private.CreateCompetitorTabGroup(content, selectedSubChild))
		else
			content:AddChild(Private.CreateCompetitorTabGroup(content, selectedChild))
		end
	end
end

function Private.SlectCompetitor(name, parentName)
	if not Private.treeGroup then return end
	
	local path = "2\001"
	
	if parentName then
		path = path..parentName.."\001"..name
	else
		path = path..name
	end
	
	Private.treeGroup:SelectByPath(path)
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
							type = "Spacer",
							quantity = 2,
						},

						{
							type = "CheckBox",
							value = configDB.TrackMarked,
							label = L["OptTrackMakedLabel"],
							relativeWidth = 0.5,
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
							disabled = false,
							tooltip = L["OptSyncInfo"],
							callback = function(_,_,value) 
								if value == true then configDB.SyncCompetitors = true; else configDB.SyncCompetitors = false;	end
							end,
						},

						{
							type = "Spacer",
							quantity = 2,
						},

						{
							type = "Slider",
							value = configDB.ChatLevel,
							label = L["OptChatLevelLabel"],
							relativeWidth = 0.5,
							min = 1,
							max = 5,
							step = 1,
							callback = function(_,_,value) configDB.ChatLevel = value end,
							tooltip = L["OptChatLevelInfo"],
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
	local TabbedGroup = AceGUI:Create("TSMTabGroup")
	TabbedGroup:SetLayout("Fill")
	TabbedGroup:SetFullWidth(true)
	TabbedGroup:SetFullHeight(true)
	TabbedGroup:SetTabs({
		{value=1, text=L["HistoryTabText"]},
		{value=2, text=L["ManagementTabText"]},
	})
	TabbedGroup:SetCallback("OnGroupSelected",function(self,Crap,value)
		if viewerST then viewerST:Hide() end
		TabbedGroup:ReleaseChildren()
		content:DoLayout()

		if value==1 then
			Private.PersonHistory(TabbedGroup,selectedChild)
		elseif value==2 then
			Private.PersonManagement(TabbedGroup,selectedChild)
		end
	end)
	TabbedGroup:SelectTab(1)
	
	Config:HookScript(TabbedGroup.frame, "OnHide", function()
		Config:UnhookAll()
		if viewerST then viewerST:Hide() end
	end)
	
	return TabbedGroup
end


function GetHistoryData(competitor)
	local rowData = {}
	
	if competitor.records and #competitor.records > 0 then 
		local history = CopyTable(competitor.records)
		
		for i=1,#history-1 do
			history[i].periode = history[i+1].modified-history[i].modified
		end
		history[#history].periode = competitor.modified - history[#history].modified
		
		for i=#history,1,-1 do
			local itemData = history[i]
			local timeColor
			
			if itemData.connected then
				timeColor = "|cff00ff00"
			else
				timeColor = "|cffff0000"
			end

			tinsert(rowData, {
				cols = {
					{ value = TSMCT.GetFormattedTime(itemData.modified, "aidate") },
					{ value = TSMCT.GetFormattedTime(itemData.periode, "period") },
					{ value = timeColor..itemData.location.."|r" },
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
					type = "ScrollFrame", -- simple group didn't work here for some reason
					fullHeight = true,
					layout = "Flow",
					children = {},
				},
			}
		}
	}

	TSMAPI:BuildPage(container, page)

	-- scrolling table
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not viewerST then
		local stCols = {
			{ name = L["VHeadTime"],     width = 0.2, },
			{ name = L["VHeadPeriode"],  width = 0.2, },
			{ name = L["VHeadLocation"], width = 0.6, },
		}
		
		viewerST = TSMAPI:CreateScrollingTable(stParent, stCols)
		viewerST:EnableSorting(false)
		viewerST:DisableSelection(true)
	end

	viewerST:Show()
	viewerST:SetParent(stParent)
	viewerST:SetAllPoints()

	viewerST:SetData(GetHistoryData(competitor))
end

function Private.PersonManagement(container,name)
	local competitor = dataDB.competitors[name]
	if not competitor then return end
	
	local disableRemove = type(competitor.goblin) ~= "string"
	local disableDropdown = false
	local goblinList = {}
	
	for _, v in pairs(dataDB.competitors) do
		if v.goblin then
			if v.goblin==name or v.name==name then
				disableDropdown = true
			end
		else
			if v.name~=name then
				goblinList[v.name] = v.name
			end
		end
    end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["MHSTitle"],
					children = {
						{
							type = "Button",
							text = L["MHClearBtnText"],
							relativeWidth = 0.5,
							callback = function(_,_,value)
								wipe(competitor.records)
								Private.SlectCompetitor(name)
							end,
							tooltip = L["MHClearBtnInfo"],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["MGSTitle"],
					children = {
						{
							type = "Dropdown",
							label = L["MGDropdownLabel"],
							list = goblinList,
							disabled = disableDropdown,
							relativeWidth = 0.5,
							settingInfo = {competitor, "goblin"},
							multiselect = false,
							callback = function(self, _, value)
								Private.UpdateTree()
								Private.SlectCompetitor(name,value)
							end,
							tooltip = L["MGDropdownInfo"],
						},
						{
							type = "Button",
							text = L["MGRemoveBtnText"],
							disabled = disableRemove,
							relativeWidth = 0.5,
							callback = function(_,_,value)
								competitor.goblin = nil
								Private.UpdateTree()
								Private.SlectCompetitor(name)
							end,
							tooltip = L["MGRemoveBtnInfo"],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end
