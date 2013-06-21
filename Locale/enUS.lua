local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_CompetitorTracker", "enUS", true)
if not L then return end
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@

-- <<Tracker.lua>> --
L["ResetDB"]="Configuration files incompatable, resetting"
L["DBInit"]="Initial Database created"
L["SlashCommandHelp"] = "Enables/Disables the Competitor Tracker module"

-- << Config.lua >> --
L["TreeOptions"] = "Options"
L["TreeCompetitors"] = "Competitors"

L["OptTabOptions"] = "Options"
L["OptTabProfiles"] = "Profiles"

L["OptDataModuleEnabledLabel"] = "Track Competitors"
L["OptDataModuleEnabledInfo"] = "If you enable this option, the data module record all login/logout activity in the background."

L["OptMonitorModuleEnabledLabel"] = "Competitor Monitor Enabled"
L["OptMonitorModuleEnabledInfo"] = "If you enable this option, you can monitor the activity of competitors in a window."

L["OptTrackMakedLabel"] = "Track only with mark"
L["OptTrackMakedInfo"] = "Track competitor only if marked in the friend note field."

L["OptTrackMakLabel"] = "Track Mark"
L["OptTrackMakInfo"] = "Track competitor only if marked with this in the friend note field."
L["OptTrackMakDisabledInfo"] = "First, enable the track only with mark checkbox!"

L["OptSyncLabel"] ="Syncronize Competitors"
L["OptSyncInfo"] = "If you add or remove someone from your friends list and relog to an alt, that person will be added/removed from the alts friends list as well. Also, any entries on that alts list which isn't in the global list, will be added to the other characters whenever you log them in."

L["OptTrackMaxRecordLabel"] = "Max saved record"
L["OptTrackMaxRecordInfo"] = "Max record saved for each comptetitor."

-- Profile Section -- 
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

-- Deleted Competitor List
L["DeletedTab"] = "Deleted"
L["DeletedTitle"] = "Deleted Competitor List Options"
L["DeletedInfo"] = "Here you can remove competitor from the deleted list. Therefore, the competitor will not be deleted -removed from your friend list - when you relog on an ALT and also Syncronize Competitors option  is enabled."

-- Viwer Section --
L["VHeadTime"] = "Time"
L["VHeadPeriode"] = "Periode" 
L["VHeadLocation"] = "Location"

L["CName"] = "Name"
L["CClass"] = "Class"
L["CLevel"] = "Level"
L["CLocation"] = "Last location"
L["CStatus"] = "Last status"
L["CNote"] = "Note"

-- <<Monitor.lua>> --
L["MonitorTitle"]="Competitor Monitor"
L["MonitorEnabled"] = "Monitor module enabled."
L["MonitorDisabled"] = "Monitor module disabled."

L["MHeadName"] = "Name"
L["MHeadLocation"] = "Location"
L["MHeadBefore"] = "Before"
L["MHeadNow"] = "Now"

-- <<Data.lua>> --
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
