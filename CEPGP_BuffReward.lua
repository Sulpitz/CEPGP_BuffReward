local addonName, addon = ...

local BuffEP = 8
local validBuffs = {"Rallying Cry of the Dragonslayer", "Spirit of Zandalar", "Warchief's Blessing", "Songflower Serenade", "Mol'dar's Moxie", "Fengus' Ferocity", "Slip'kik's Savvy"}
local DMTBuffs = {"Mol'dar's Moxie", "Fengus' Ferocity", "Slip'kik's Savvy"}

--local DMTBuffs = {"Divine Spirit", "Power Word: Fortitude"}
--local validBuffs = {"Inner Fire", "Divine Spirit", "Power Word: Fortitude", "Fear Ward", "Shadow Protection", "Rallying Cry of the Dragonslayer", "Mol'dar's Moxie", "Fengus' Ferocity", "Slip'kik's Savvy"}


local function fCEPGP_addEP(player, amount, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end

	CEPGP_sendChatMessage(amount .. " EP added to " .. player .. " (" .. msg .. ")", "RAID");
end

local function GetRaidBuffs()
	local raidMemberBuffs = {}
	local offline = {}

	for raidIndex = 1, GetNumGroupMembers() do
		local name, _, _, _, _, _, zone, online, _, _, _ = GetRaidRosterInfo(raidIndex)
		if online == true then
			raidMemberBuffs[name] = {}
			local playerBuffs = {}

			--build a list of valid Buffs
			for i=1,32 do				
				local playerBuff = UnitBuff("raid".. raidIndex ,i)

				if not playerBuff then break end
				
				for _, validBuff in pairs(validBuffs) do
					if validBuff == playerBuff then	
						table.insert(playerBuffs, validBuff)
						break
					end
				end
			end

			--remove Dire Maul Buffs
			local DMT = false

			for _, playerBuff in pairs(playerBuffs) do
				local dmt = false
				for _, DMBuff in pairs(DMTBuffs) do
					if playerBuff == DMBuff then						
						dmt = true
						DMT = true
						break
					end
				end
				if not dmt then table.insert(raidMemberBuffs[name], playerBuff) end
			end
			
			if DMT then
				table.insert(raidMemberBuffs[name], "DMT")
			end

		--build Offline Table
		else
			table.insert(offline, name)
		end
	end

	return raidMemberBuffs, offline
end

local function AssignRaidBuffEP()

	if not UnitInRaid("player") then
		message("You are not in a Raid Group")
		return
	end

	if not CanEditOfficerNote() then
		message("You don't have access to modify EP/GP")
		return
	end

	raidMemberBuffs, offline = GetRaidBuffs()

	--raidMemberBuffs{
	--	[name] = {"buff1", "buff2", "buff3"}
	--}
	
	print("--------------------------\n")
	for k, buffTable in pairs(raidMemberBuffs) do
		print(k, ":")
		for m, n in pairs(buffTable) do
			print("   " .. n)
		end
	end

	local offlineMessage = "Players offline: "
	for _, offlineName in pairs(offline) do
		offlineMessage = offlineMessage .. offlineName .. ", "
	end
	print(offlineMessage)

 	
	for player, playerBuffs in pairs(raidMemberBuffs) do
		local buffMessage = "WorldBuffs: "
		if #playerBuffs >= 2 then
			for _, buffName in pairs(playerBuffs) do
				buffMessage = buffMessage .. buffName .. " " 
			end
			
			if CEPGP_getIndex(player) then
				CEPGP_addEP(player, BuffEP, buffMessage)
			else
				print("CEPGP_BuffReward: " .. player .. "not in Roster")
			end
		end

	end
	CEPGP_sendChatMessage(offlineMessage, "RAID");
end

StaticPopupDialogs["EXAMPLE_HELLOWORLD"] = {
	text = "Distribute Buff EP now?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		AssignRaidBuffEP()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
  }


SLASH_CEPGPBR1 = '/cepbr'
SLASH_CEPGPBR2 = '/br'
function SlashCmdList.CEPGPBR(msg, editbox)   
	StaticPopup_Show ("EXAMPLE_HELLOWORLD")
end