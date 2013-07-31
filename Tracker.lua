local addonName, TSMCT = ...

TSMCT = LibStub("AceAddon-3.0"):NewAddon(TSMCT, addonName, "AceConsole-3.0","AceEvent-3.0")
TSMCT:SetDefaultModuleState(false)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

TSMCT.Version = GetAddOnMetadata(addonName, "Version")
TSMCT.DBVersion = 1
TSMCT.DBName = addonName.."DB" -- GetAddOnMetadata(addonName, "SavedVariables")

local savedDBDefaults = { 
	factionrealm = {
		sync = false, 
		competitors = {	},
		deleted = {},
		loginTime = 0,
		logoutTime = 0,
	},

	char = {
		["Monitor"] = {
			point="CENTER",
			relativeTo="",
			relativePoint="CENTER",
			offsetX = 0,
			offsetY = 0,
			width=300,
			height=100,
			numRows=10,
		},
	},
	
	profile = {
		treeGroupStatus = {treewidth = 200, groups={[2]=true}},
		
		DataModuleEnabled = false,
		MonitorModuleEnabled = false,
		
		TrackMarked = false,
		TrackMark = "[auc]",
		TrackMaxRecord = 20,
		TrackNumRows = 26,
		SyncCompetitors = false,
	},
}

function TSMCT:OnInitialize()
	for moduleName, module in pairs(TSMCT.modules) do
		TSMCT[moduleName] = module
	end

	TSMCT.db = LibStub:GetLibrary("AceDB-3.0"):New(addonName.."DB", savedDBDefaults, true)
	
		-- TSM1.0 support
	if not TSMAPI.NewModule then
		-- TSM1.x support

		TSMAPI:RegisterReleasedModule(addonName, TSMCT.Version, GetAddOnMetadata(addonName, "Author"), GetAddOnMetadata(addonName, "Notes"))
		TSMAPI:RegisterSlashCommand('ctrack', function(...) TSMCT.TrackingEnable(not TSMCT.db.profile.DataModuleEnabled); end, L["SlashCommandHelp"])
		TSMAPI:RegisterIcon(L["TSMModuleIconText"],"Interface\\Icons\\Ability_Priest_Silence",function(...) TSMCT.Config:Load(...) end, addonName,"module")
	else
		-- register with TSM (2.0)
		TSMCT:RegisterModule()
	end
end


-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSMCT:RegisterModule()
	TSMCT.icons = {
		{
			side="module",
			desc=L["TSMModuleIconText"],
			slashCommand = "ctrack",
			callback="Config:Load",
			icon="Interface\\Icons\\Ability_Priest_Silence"
		},
	}
	
	TSMAPI:NewModule(TSMCT)
end


function TSMCT:OnEnable()
	TSMCT.db.factionrealm.loginTime = time()
	TSMCT:Printf(L["VersionText"],TSMCT.Version)
	
	if TSMCT.db.profile.DataModuleEnabled then 
		TSMCT:EnableModule("Data")
		
		if TSMCT.db.profile.MonitorModuleEnabled then
			TSMCT:EnableModule("Monitor")
		end
	end
	
	TSMCT:RegisterEvent("PLAYER_LOGOUT")
end

function TSMCT:OnDisable()
	TSMCT:DisableModule("Monitor")
	TSMCT:DisableModule("Data")
	
	TSMCT.db.factionrealm.logoutTime = time()
end

function TSMCT:PLAYER_LOGOUT()
	TSMCT:Disable()
end

function TSMCT.GetFormattedTime(rTime, timeFormat)
	if not rTime then 
		return "?"
	end
	if timeFormat == "ago" then
		return format("%s", SecondsToTime(time()-rTime) or "?")
	elseif timeFormat == "fromnow" then
		return format("%s", SecondsToTime(rTime-time()) or "?")
	elseif timeFormat == "period" then
		return format("%s", SecondsToTime(rTime) or "?")
	elseif timeFormat == "usdate" then
		return date("%m/%d/%y %H:%M", rTime)
	elseif timeFormat == "eudate" then
		return date("%d/%m/%y %H:%M", rTime)
	elseif timeFormat == "aidate" then
		return date("%m/%d %H:%M", rTime)
	end
	
	return "What?"
end

function TSMCT.TrackingEnable(enable) 
	TSMCT.MonitoringEnable(enable) 
	
	TSMCT.db.profile.DataModuleEnabled = enable
	if enable then 
		TSMCT:EnableModule("Data")
	else
		TSMCT:DisableModule("Data")
	end
end

function TSMCT.MonitoringEnable(enable) 
	TSMCT.db.profile.MonitorModuleEnabled = enable
	
	if enable then 
		TSMCT:EnableModule("Monitor")
	else
		TSMCT:DisableModule("Monitor")
	end
end