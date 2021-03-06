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
require("lib/timers")
require("lib/ai")
require("lib/chat_handler")
require("items/arcane_staff")
require("lib/parsers")
require("lib/end_screen")
require("lib/data")




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
	GameRules:SetCustomGameSetupAutoLaunchDelay(3.0)
	GameRules:SetTimeOfDay(0.75)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(40.0)
	GameRules:SetPreGameTime(15.0)
	GameRules:SetStrategyTime(10.0)
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
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameMode, 'OnEntitySpawned'), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameMode, 'OnEntityKilled'), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AOHGameMode, "OnGameRulesStateChange"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(AOHGameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(AOHGameMode, 'OnHoldoutReviveComplete'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(ChatHandler, "OnPlayerChat"), ChatHandler)

	GameRules:GetGameModeEntity():SetThink("OnThink", self, 0.25)

	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)
end


function AOHGameMode:AtRoundStart()
	local cost = 250 * self._nRoundNumber

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:HasSelectedHero(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                PlayerResource:SetCustomBuybackCost(playerID, cost)
            end
        end
    end
end



function AOHGameMode:OnDamageDealt(damageTable)
	local attacker_index = damageTable.entindex_attacker_const

	if attacker_index then
		local attacker = EntIndexToHScript(attacker_index)

		if attacker then
			if attacker:HasItemInInventory("item_arcane_staff") then
				damageTable = arcane_staff_calculate_crit(damageTable)
			end

			local victim_index = damageTable.entindex_victim_const

			if victim_index then
				local victim = EntIndexToHScript(victim_index)
				if victim then
					if attacker.GetPlayerOwnerID then
						local attackerPlayerId = attacker:GetPlayerOwnerID()
						if attackerPlayerId and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
							player_data_modify_value(attackerPlayerId, "bossDamage", damageTable.damage)
						end
					end

					if attacker:IsCreature() and victim:IsRealHero() and victim.GetPlayerOwnerID then
						local victimPlayerId = victim:GetPlayerOwnerID()
						if victimPlayerId and victimPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
							player_data_modify_value(victimPlayerId, "damageTaken", damageTable.damage)
						end
					end
				end
			end
		end
	end

	return true
end


function AOHGameMode:OnItemPickedUp(keys)
	if keys.itemname == "item_bag_of_gold" then
		player_data_modify_value(keys.PlayerID, "goldBagsCollected", 1)
	end
end


function AOHGameMode:OnHoldoutReviveComplete(keys)
	local castingHero = EntIndexToHScript(keys.caster)
	if castingHero then
		local playerID = castingHero:GetPlayerOwnerID()
		player_data_modify_value(playerID, "saves", 1)
	end
end


-- Read and assign configurable keyvalues if applicable
function AOHGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues("scripts/config/aoh2_config.txt") or {}

	self._flPrepTimeBetweenRounds = tonumber(kv.PrepTimeBetweenRounds or 0)
	self._flItemExpireTime = tonumber(kv.ItemExpireTime or 10.0)

	self._vRandomSpawnsList = spawns_from_kv(kv["RandomSpawns"])
	self._vLootItemDropsList = items_from_kv(kv["ItemDrops"])
	self._vRounds = rounds_from_kv(kv["Rounds"], self)
end


-- Verify spawners if random is set
function AOHGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
		return nil
	end
	return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end


-- When game state changes set state in script
function AOHGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:_RevealShop()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	elseif nNewState == DOTA_GAMERULES_STATE_POST_GAME then
		GameRules:SetSafeToLeave(true)
		end_screen_setup(self._entAncient and self._entAncient:IsAlive())
	end
end


-- Evaluate the state of the game
function AOHGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		
		removed_expired_items(self._flItemExpireTime)

		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End()
				self._currentRound = nil

				refresh_players()

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


function AOHGameMode:_CheckForDefeat()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self._entAncient and self._entAncient:IsAlive() then
			if are_all_heroes_dead() then
				self._entAncient:ForceKill(false)
			end
		else
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end
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
		self:AtRoundStart()
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
		create_ressurection_tombstone(killedUnit)
	end
end


function AOHGameMode:CheckForLootItemDrop(killedUnit)
	for _, itemDropInfo in pairs(self._vLootItemDropsList) do
		if RollPercentage(itemDropInfo.nChance) then
			create_item_drop(itemDropInfo.szItemName, killedUnit:GetAbsOrigin())
		end
	end
end
