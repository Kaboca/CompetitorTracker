local addonName, TSMCT = ...

local Private = {}
local Data = TSMCT:NewModule("Data", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local competitors, deletedCompetitors, configDB

function Data:OnEnable()
	TSMCT:Print(L["DataEnabled"])
	
	competitors=TSMCT.db.factionrealm.competitors
	deletedCompetitors = TSMCT.db.factionrealm.deleted
	configDB  = TSMCT.db.profile
	
	TSMAPI:CreateTimeDelay("CompTrackerDataUpdate", 15, Data.Update, 15)	
end

function Data:OnDisable()
	TSMAPI:CancelFrame("CompTrackerDataUpdate")
	if Data.UpdateHandle then
		Data:UnregisterBucket(Data.UpdateHandle)
	end

	TSMCT:Print(L["DataDisabled"])
end

function Data.Update()
	local friendList, noteList, count = {}, {}, 0
	
    for i=1,GetNumFriends() do
	    local name, _, _, _, _, _, friendNote = GetFriendInfo(i)
		
		if name then
			friendList[name] = i
			noteList[name] = friendNote
			--TSMCT:Printf("Checking>%s",name)
			count=count+1
		else
			TSMCT:Print(L["DataFriendListWait"])
			ShowFriends()
			return false
		end
	end
	TSMCT:Printf(L["DataFriendCount"],count)
	TSMAPI:CancelFrame("CompTrackerDataUpdate")
	
	if TSMCT.db.profile.SyncCompetitors then
		for name,v in pairs(friendList) do
			if deletedCompetitors[name] then
				TSMCT:Printf(L["DataRemove"], name)
				RemoveFriend(name)
			else
				if competitors[name] and competitors[name].friendNote then
					if not noteList[name] or noteList[name] ~= competitors[name].friendNote then
						TSMCT:Printf(L["DataSetNote"],competitors[name].friendNote, name)
						SetFriendNotes(name, competitors[name].friendNote)
					end
				end
			end
		end
		
		for name, v in pairs(competitors) do
			if not friendList[name] and not v.RemoveTime then
				TSMCT:Printf(L["DataAddFriend"], name)
				AddFriend(name)
			end
		end
	end
	
	Data:BucketEventHandler()
	
	Data.UpdateHandle = Data:RegisterBucketEvent("FRIENDLIST_UPDATE", 5, "BucketEventHandler")
	return true
end

function Data:BucketEventHandler()
	TSMCT:Print(L["DataChecking"])

	for _, v in pairs(competitors) do
		v.inFriendList = false
    end
	
    for i=1,GetNumFriends() do
	    local name, level, class, location, connected, status, friendNote = GetFriendInfo(i)
		
		if name then
			if connected then connected=true else connected=false end

			--TSMCT:Print(name)
			local competitor = competitors[name]

			if competitor then
				competitor.inFriendList = true
				competitor.RemoveTime = nil
				
				if competitor.connected ~= connected then
					competitor.previous=time()-competitor.modified
					local record = {}
					record.connected=competitor.connected
					record.modified=competitor.modified
					record.location=competitor.location
					table.insert(competitor.records, record)
					if #competitor.records > configDB.TrackMaxRecord then
						local removed = table.remove(competitor.records, 1)
						TSMCT:Printf(L["DataRemovedRecord"], competitor.name, TSMCT.GetFormattedTime(removed.modified,"aidate"))
					end
					
					competitor.connected=connected
					competitor.modified=time()
				end	
				if connected then
					competitor.level=level
					competitor.class=class
					competitor.location=location
					if friendNote and (not competitor.friendNote or competitor.friendNote ~= friendNote) then
						competitor.friendNote = friendNote
					end
				end
			else
				if not configDB.TrackMarked or 
					( configDB.TrackMarked and friendNote and configDB.TrackMark and string.find(friendNote,configDB.TrackMark) ) then
					
					if deletedCompetitors[name] then
						deletedCompetitors[name] = nil
						TSMCT:Printf(L["DataRemoveFromDeleted"],name)
					else
						TSMCT:Printf(L["DataRegister"],name)
					end
					
					competitor = { records={} }
				
					competitor.name=name
					competitor.level=level
					competitor.class=class
					competitor.location=location
					competitor.status=status
					competitor.friendNote=friendNote
					competitor.connected=connected
					competitor.modified=time()
					competitor.inFriendList = true
				
					competitors[name]=competitor
				end
			end
		end
	end
	
	for k, v in pairs(competitors) do
		if not v.inFriendList then
			if not v.RemoveTime then
				v.RemoveTime = time() + 120 
				TSMCT:Printf(L["DataWillBeDeleted"],k, TSMCT.GetFormattedTime(v.RemoveTime, "fromnow"))
			elseif v.RemoveTime < time() then
				Data.DeleteCompetitorData(k)
				deletedCompetitors[k] = true
			end
		end
    end
end

function Data.DeleteCompetitorData(name)
	wipe(competitors[name])
	competitors[name] = nil
	TSMCT:Printf(L["DataDelete"],name)
end