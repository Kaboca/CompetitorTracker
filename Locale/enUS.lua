-- TradeSkillMaster_CompetitorTracker Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/competitortracker/localization/

local debug = false
--@debug@
debug = true
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_CompetitorTracker", "enUS", true, debug)
if not L then return end

-- <<Tracker.lua>> --
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="tracker")@
--@do-not-package@
L["TSMModuleIconText"] = "Competitor Tracker"
L["SlashCommandHelp"] = "Toggles Competitor Monitor module/window or Reset the window position: /TSM ctwindow reset"
L["VersionText"] = "Version:%s"
L["CTWindowReset"] = "Reset MonitorWindow position."
--@end-do-not-package@



-- <<Monitor.lua>> ---------------------------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="monitor")@
--@do-not-package@
L["MonitorTitle"]="Competitor Monitor"
L["MonitorEnabled"] = "Monitor module enabled."
L["MonitorDisabled"] = "Monitor module disabled."

L["MHeadName"] = "Name"
L["MHeadLocation"] = "Location"
L["MHeadNotes"] = "Notes"
L["MHeadBefore"] = "Before"
L["MHeadNow"] = "Now"
--@end-do-not-package@



-- <<Data.lua>> ------------------------------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="data")@
--@do-not-package@
L["DataEnabled"] = "Data module enabled."
L["DataDisabled"] = "Data module disabled."
L["DataFriendListWait"] = "Friend list not ready, will try again in 15 seconds."
L["DataFriendCount"] = "Local friend count:%d"
L["DataRegister"] = "[%s] competitor registered"
L["DataRemove"] = "Removing %s from friends list."
L["DataSetNote"] = "Setting note \"%s\" for %s."
L["DataAddFriend"] = "Adding %s to friends list."
L["DataChecking"] = "Checking friendlist..."
L["DataWillBeDeleted"] = "[%s] competitor data will be deleted after [%s] when the next friend list change event happens."
L["DataDelete"] = "[%s] competitor data deleted and added to the deleted competitors list."
L["DataRemoveFromDeleted"] = "[%s] competitor removed from the deleted competitors list, because manually added to the friends list."
L["DataRemovedRecord"] = "Removed record:%s, %s"
L["DataResetToOffline"] = "Competitor:%s has exceeded the configured maximum online time, therefore the current status will be offline for a while."
--@end-do-not-package@



-- << Config.lua >> --------------------------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="config")@
--@do-not-package@
L["TreeOptions"] = "Options"
L["TreeCompetitors"] = "Competitors"

L["OptTabOptions"] = "Options"
L["OptTabProfiles"] = "Profiles"

L["OptDataModuleEnabledLabel"] = "Track Competitors"
L["OptDataModuleEnabledInfo"] = "If you enable this option, the data module will record all login/logout activity in the background."

L["OptMonitorModuleEnabledLabel"] = "Competitor Monitor Enabled"
L["OptMonitorModuleEnabledInfo"] = "If you enable this option, you can monitor the activity of competitors in a window."

L["OptTrackMakedLabel"] = "Track only with mark"
L["OptTrackMakedInfo"] = "Track competitor only if marked in the friend note field."

L["OptTrackMakLabel"] = "Track Mark"
L["OptTrackMakInfo"] = "Track competitor only if marked with this in the friend note field."
L["OptTrackMakDisabledInfo"] = "First, enable the track only with mark checkbox!"

L["OptSyncLabel"] ="Syncronize Competitors"
L["OptSyncInfo"] = "If you add or remove someone from your friends list and relog to an alt, that person will be added/removed from the alt's friends list as well. Also, any entries on that alt's list which isn't in the global list, will be added to the other characters whenever you log them in."

L["OptTrackMaxRecordLabel"] = "Max saved record"
L["OptTrackMaxRecordInfo"] = "Max record saved for each comptetitor."

L["OptMonitorMaxRowsLabel"] = "Monitor Window Rows"
L["OptMonitorMaxRowsInfo"] = "Number of Monitor Window Rows (Requires Reload)."

L["OptTrackMaxRowsLabel"] = "History List Rows"
L["OptTrackMaxRowsInfo"] = "Number of rows displayed (Requires Reload)."

L["OptDefaultChatLabel"] = "Default Chat Window"
L["OptDefaultChatInfo"] = "Allows selection of which chat window to display messages"

L["OptChatLevelLabel"] = "Verbosity"
L["OptChatLevelInfo"] = "Only the lower level messages will be printed"

L["OptMaxConnectedTimeLabel"] = "Max Online Time (in hours)"
L["OptMaxConnectedTimeInfo"]  = "Set a cap on how long online status ( the 'Now' column in Competitor Monitor) can remain true before automatically being reset. Zero value means: endless "
--@end-do-not-package@


-- Profile Section -- 
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="config.profile")@
--@do-not-package@
L["ProfileDefault"] = "Default"
L["ProfileIntro"] = "You can change the active database profile, so you can have different settings for every character."
L["ProfileResetDesc"] = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."
L["ProfileReset"] = "Reset Profile"
L["ProfileChooseDesc"] = "You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."
L["ProfileNew"] = "New"
L["ProfileNewSub"] = "Create a new empty profile."
L["ProfileChoose"] = "Existing Profiles"
L["ProfileCopyDesc"] = "Copy the settings from one existing profile into the currently active profile."
L["ProfileCopy"] = "Copy From"
L["ProfileDelete"] = "Delete a Profile"
L["ProfileDeleteDesc"] = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."
L["Profiles"] = "Profiles"
L["ProfileCurrent"] = "Current Profile:"
L["ProfileAccept"] = "Accept"
L["ProfileCancel"] = "Cancel"
L["ProfileDeleteSure"] = "Are you sure you want to delete the selected profile?"
--@end-do-not-package@


-- Deleted Competitor List Section --
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="config.deleted")@
--@do-not-package@
L["DeletedTab"] = "Deleted"
L["DeletedTitle"] = "Deleted Competitor List Options"
L["DeletedInfo"] = "Here you can remove competitor from the deleted list. Therefore, the competitor will not be deleted -removed from your friend list - when you relog on an ALT and also Syncronize Competitors option  is enabled."
--@end-do-not-package@


-- Viwer Section --
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="viwer")@
--@do-not-package@
L["HistoryTabText"]="History"

L["VHeadTime"] = "Time"
L["VHeadPeriode"] = "Periode" 
L["VHeadLocation"] = "Location"

L["CName"] = "Name"
L["CClass"] = "Class"
L["CLevel"] = "Level"
L["CLocation"] = "Last location"
L["CStatus"] = "Last status"
L["CNote"] = "Note"
--@end-do-not-package@

-- Management Section --
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="management")@
--@do-not-package@
L["ManagementTabText"]="Management"

L["MHSTitle"]="History Settings"
L["MHClearBtnText"]="Clear History"
L["MHClearBtnInfo"]="Click this button to clear the competitor history."

L["MGSTitle"]="Goblin Settings"
L["MGDropdownLabel"]="Goblin"
L["MGDropdownInfo"]="This competitor/character will be the goblin character who list the items in the Auction House. Everyone knows that the goblins are the ultimate Auction House Traders. "

L["MGRemoveBtnText"]="Remove Goblin Selection"
L["MGRemoveBtnInfo"]="Click this button to remove/clear goblin selection for this competitor."

--@end-do-not-package@
