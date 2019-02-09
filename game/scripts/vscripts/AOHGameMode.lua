--[[
From
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability
	
	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]
require("AOHGameRound")
require("AOHSpawner")
require("lib/my")
require("lib/atr_fix")
require("lib/callbacks")
require("lib/timers")
require("lib/ai")
require("lib/chat_handler")
require("items/ice_staff")




if AOHGameMode == nil then
	AOHGameMode = class({})
end



function AOHGameMode:InitGameMode()
	self._nRoundNumber = 1
	self._currentRound = nil
	self._entAncient = Entities:FindByName(nil, "dota_goodguys_fort")

	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)

	self:_ReadGameConfiguration()
	GameRules:SetTimeOfDay(0.75)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(40.0)
	GameRules:SetPreGameTime(15.0)
	GameRules:SetPostGameTime(30.0)
	GameRules:SetTreeRegrowTime(30.0)
	GameRules:SetHeroMinimapIconScale(1.2)
	GameRules:SetCreepMinimapIconScale(1.2)
	GameRules:SetRuneMinimapIconScale(1.2)
	GameRules:SetGoldPerTick(1.2)
	GameRules:SetGoldTickTime(0.5)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible(false)

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameMode, 'OnEntitySpawned'), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameMode, 'OnEntityKilled'), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AOHGameMode, "OnGameRulesStateChange"), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(ChatHandler, "OnPlayerChat"), ChatHandler)

	GameRules:GetGameModeEntity():SetThink("OnThink", self, 0.25)

	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(AOHGameMode, "OnExecuteOrder"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)
end


function AOHGameMode:OnExecuteOrder(keys)
    local order = keys.order_type
  
	if order == DOTA_UNIT_ORDER_GLYPH then
		Timers:CreateTimer(
			1.0,
			function()
				GlyphStartCallback:_CallCallbacks(self._currentRound)
		  	end
		)
    end
  
    return true
end


function AOHGameMode:OnDamageDealt(damageTable)
    local attacker_index = damageTable.entindex_attacker_const

    if attacker_index then
		local attacker = EntIndexToHScript(attacker_index)
		
		if attacker then
			if attacker:HasItemInInventory("item_ice_staff") then
				damageTable = ice_staff_calculate_crit(damageTable)
			end
		end
    end

	
	return true
end


-- Read and assign configurable keyvalues if applicable
function AOHGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues("scripts/config/aoh2_config.txt") or {}

	self._flPrepTimeBetweenRounds = tonumber(kv.PrepTimeBetweenRounds or 0)
	self._flItemExpireTime = tonumber(kv.ItemExpireTime or 10.0)

	self:_ReadRandomSpawnsConfiguration(kv["RandomSpawns"])
	self:_ReadLootItemDropsConfiguration(kv["ItemDrops"])
	self:_ReadRoundConfigurations(kv["Rounds"])
end


-- Verify spawners if random is set
function AOHGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
		return nil
	end
	return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end


-- Verify valid spawns are defined and build a table with them from the keyvalues file
function AOHGameMode:_ReadRandomSpawnsConfiguration(kvSpawns)
	self._vRandomSpawnsList = {}
	if type(kvSpawns) ~= "table" then
		return
	end
	for _,sp in pairs(kvSpawns) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert(self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		})
	end
end


-- If random drops are defined read in that data
function AOHGameMode:_ReadLootItemDropsConfiguration(kvLootDrops)
	self._vLootItemDropsList = {}
	if type(kvLootDrops) ~= "table" then
		return
	end
	for _, lootItem in pairs(kvLootDrops) do
		table.insert(self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber(lootItem.Chance or 0)
		})
	end
end


-- Set number of rounds without requiring index in text file
function AOHGameMode:_ReadRoundConfigurations(kv)
	self._vRounds = {}
	while true do
		local roundNumber = #self._vRounds + 1
		local roundData = kv[tostring(roundNumber)]
		if roundData == nil then
			break
		end
		table.insert(self._vRounds, AOHRoundFromConfiguration(roundData, self, roundNumber))
	end

	--debug_start_at_round(self._vRounds, 32)
end


-- When game state changes set state in script
function AOHGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:_RevealShop()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	end
end


-- Evaluate the state of the game
function AOHGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		self:_ThinkLootExpiry()

		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End()
				self._currentRound = nil

				self:_RefreshPlayers()

				self._nRoundNumber = self._nRoundNumber + 1
				if self._nRoundNumber <= #self._vRounds then
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
				end
			end
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			return false
		end


	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end


function AOHGameMode:_RevealShop()
	local shopPos = Entities:FindByName(nil, "the_shop"):GetAbsOrigin()
	AddFOWViewer(2, shopPos, 2000, 10000, true)
end


function AOHGameMode:_RefreshPlayers()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero(nPlayerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				if not hero:IsAlive() then
					hero:RespawnUnit()
				end
				hero:SetHealth(hero:GetMaxHealth())
				hero:SetMana(hero:GetMaxMana())
				hero:SetBaseMagicalResistanceValue(25)
			end
		end
	end
end


function AOHGameMode:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end


	local bAllPlayersDead = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
			if not PlayerResource:HasSelectedHero(nPlayerID) then
				bAllPlayersDead = false
			else
				local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				if hero and hero:IsAlive() then
					bAllPlayersDead = false
				end
			end
		end
	end

	if bAllPlayersDead or not self._entAncient or self._entAncient:GetHealth() <= 0 then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		--GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
	end
end


function AOHGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_RemoveImmediate(self._entPrepTimeQuest)
			self._entPrepTimeQuest = nil
		end

		GameRules.GLOBAL_roundNumber = self._nRoundNumber  -- Set a global.
		self._currentRound = self._vRounds[self._nRoundNumber]
		self._currentRound:Begin()
		RoundStartCallback:_CallCallbacks(self._currentRound)
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous("quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" })
		self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber)
		local round = self._vRounds[self._nRoundNumber]
		round:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime())
end


function AOHGameMode:_ThinkLootExpiry()
	if self._flItemExpireTime <= 0.0 then
		return
	end

	local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

	for _,item in pairs(Entities:FindAllByClassname("dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem:GetAbilityName() == "item_bag_of_gold" or item.Holdout_IsLootDrop then
			self:_ProcessItemForLootExpiry(item, flCutoffTime)
		end
	end
end


function AOHGameMode:_ProcessItemForLootExpiry(item, flCutoffTime)
	if item:IsNull() then
		return false
	end
	if item:GetCreationTime() >= flCutoffTime then
		return true
	end

	local containedItem = item:GetContainedItem()
	if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold" then
		if self._currentRound and self._currentRound.OnGoldBagExpired then
			self._currentRound:OnGoldBagExpired()
		end
	end

	local nFXIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item)
	ParticleManager:SetParticleControl(nFXIndex, 0, item:GetOrigin())
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(35, 35, 25))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
	local inventoryItem = item:GetContainedItem()
	if inventoryItem then
		UTIL_RemoveImmediate(inventoryItem)
	end
	UTIL_RemoveImmediate(item)
	return false
end


function AOHGameMode:OnEntitySpawned(event)
	-- Fix for str magic res and more.
	local unit = EntIndexToHScript(event.entindex)

	if unit and unit:IsHero() then
		fix_atr_for_hero(unit)
	end
end


function AOHGameMode:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if killedUnit and killedUnit:IsRealHero() then
		local newItem = CreateItem("item_tombstone", killedUnit, killedUnit)
		newItem:SetPurchaseTime(0)
		newItem:SetPurchaser(killedUnit)
		local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
		tombstone:SetContainedItem(newItem)
		tombstone:SetAngles(0, RandomFloat(0, 360), 0)
		FindClearSpaceForUnit(tombstone, killedUnit:GetAbsOrigin(), true)	
	end
end


function AOHGameMode:CheckForLootItemDrop(killedUnit)
	for _, itemDropInfo in pairs(self._vLootItemDropsList) do
		if RollPercentage(itemDropInfo.nChance) then
			local newItem = CreateItem(itemDropInfo.szItemName, nil, nil)
			newItem:SetPurchaseTime(0)
			if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
				item:SetStacksWithOtherOwners(true)
			end
			local drop = CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), newItem)
			drop.Holdout_IsLootDrop = true
		end
	end
end
