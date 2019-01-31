require("AOHSpawner")
require("lib/my")
require("lib/notifications")



if AOHGameRound == nil then
	AOHGameRound = class({})
end


function AOHRoundFromConfiguration(roundData, gamemode, roundNumber)
	local round = AOHGameRound()
	round:ReadConfiguration(roundData, gamemode, roundNumber)
	return round
end



function AOHGameRound:ReadConfiguration(kv, gameMode, roundNumber)
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber

	self._sTitle = kv.Title or ""
	self._nMaxGold = tonumber(kv.MaxGold or 0)
	self._nBagCount = tonumber(kv.BagCount or 0)
	self._nBagVariance = tonumber(kv.BagVariance or 0)
	self._nFixedXP = tonumber(kv.FixedXP or 0)

	self._vSpawners = {}
	for k, v in pairs(kv) do
		if type(v) == "table" and v.NPCName then
			local spawner = AOHSpawner()
			spawner:ReadConfiguration(k, v, self)
			self._vSpawners[ k ] = spawner
		end
	end

	for _, spawner in pairs(self._vSpawners) do
		spawner:PostLoad(self._vSpawners)
	end
end


function AOHGameRound:Precache()
	for _, spawner in pairs(self._vSpawners) do
		spawner:Precache()
	end
end


function AOHGameRound:Begin()

	local title = "Round " .. self._nRoundNumber .. ": " .. self._sTitle
	Notifications:TopToAll({text=title, duration=6})

	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameRound, "OnNPCSpawned"), self),
		ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameRound, "OnEntityKilled"), self),
	}

	self._vPlayerStats = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		self._vPlayerStats[ nPlayerID ] = {
			nCreepsKilled = 0,
			nGoldBagsCollected = 0,
			nPriorRoundDeaths = PlayerResource:GetDeaths(nPlayerID),
			nPlayersResurrected = 0
		}
	end

	self._nGoldRemainingInRound = self._nMaxGold
	self._nGoldBagsRemaining = self._nBagCount
	self._nGoldBagsExpired = 0
	self._nCoreUnitsTotal = 0
	for _, spawner in pairs(self._vSpawners) do
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
	end
	self._nCoreUnitsKilled = 0
	
end


function AOHGameRound:End()
	for _, eID in pairs(self._vEventHandles) do
		StopListeningToGameEvent(eID)
	end
	self._vEventHandles = {}

	for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if not unit:IsTower() then
			UTIL_RemoveImmediate(unit)
		end
	end

	for _,spawner in pairs(self._vSpawners) do
		spawner:End()
	end
end


function AOHGameRound:Think()
	for _, spawner in pairs(self._vSpawners) do
		spawner:Think()
	end
end


function AOHGameRound:ChooseRandomSpawnInfo()
	return self._gameMode:ChooseRandomSpawnInfo()
end


function AOHGameRound:IsFinished()
	for _, spawner in pairs(self._vSpawners) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end
	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining == 0 then
		return true
	end

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		debug_print(string.format("%d enemies remaining in the round...", #self._vEnemiesRemaining))
	end
	return false
end


function AOHGameRound:GetXPPerCoreUnit()
	if self._nCoreUnitsTotal == 0 then
		return 0
	else
		return math.floor(self._nFixedXP / self._nCoreUnitsTotal)
	end
end


function AOHGameRound:OnNPCSpawned(event)
	local spawnedUnit = EntIndexToHScript(event.entindex)
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:GetUnitName() == "" then
		return
	end

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		spawnedUnit:SetMustReachEachGoalEntity(true)
		table.insert(self._vEnemiesRemaining, spawnedUnit)
		spawnedUnit:SetDeathXP(0)
		spawnedUnit.unitName = spawnedUnit:GetUnitName()
	end
end


function AOHGameRound:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if not killedUnit then
		return
	end

	for i, unit in pairs(self._vEnemiesRemaining) do
		if killedUnit == unit then
			table.remove(self._vEnemiesRemaining, i)
			break
		end
	end	
	if killedUnit.Holdout_IsCore then
		self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
		self:_CheckForGoldBagDrop(killedUnit)
		self._gameMode:CheckForLootItemDrop(killedUnit)
	end

	local attackerUnit = EntIndexToHScript(event.entindex_attacker or -1)
	if attackerUnit then
		local playerID = attackerUnit:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ playerID ]
		if playerStats then
			playerStats.nCreepsKilled = playerStats.nCreepsKilled + 1
		end
	end
end


function AOHGameRound:OnHoldoutReviveComplete(event)
	local castingHero = EntIndexToHScript(event.caster)
	if castingHero then
		local nPlayerID = castingHero:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ nPlayerID ]
		if playerStats then
			playerStats.nPlayersResurrected = playerStats.nPlayersResurrected + 1
		end
	end
end


function AOHGameRound:OnItemPickedUp(event)
	if event.itemname == "item_bag_of_gold" then
		local playerStats = self._vPlayerStats[ event.PlayerID ]
		if playerStats then
			playerStats.nGoldBagsCollected = playerStats.nGoldBagsCollected + 1
		end
	end
end


function AOHGameRound:_CheckForGoldBagDrop(killedUnit)
	if self._nGoldRemainingInRound <= 0 then
		return
	end

	local nGoldToDrop = 0
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	if nCoreUnitsRemaining <= 0 then
		nGoldToDrop = self._nGoldRemainingInRound
	else
		local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
		if RandomFloat(0, 1) <= flCurrentDropChance then
			if self._nGoldBagsRemaining <= 1 then
				nGoldToDrop = self._nGoldRemainingInRound
			else
				nGoldToDrop = math.floor(self._nGoldRemainingInRound / self._nGoldBagsRemaining)
				nCurrentGoldDrop = math.max(1, RandomInt(nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance ))
			end
		end
	end
	
	nGoldToDrop = math.min(nGoldToDrop, self._nGoldRemainingInRound)
	if nGoldToDrop <= 0 then
		return
	end
	self._nGoldRemainingInRound = math.max(0, self._nGoldRemainingInRound - nGoldToDrop)
	self._nGoldBagsRemaining = math.max(0, self._nGoldBagsRemaining - 1)

	local newItem = CreateItem("item_bag_of_gold", nil, nil)
	newItem:SetPurchaseTime(0)
	newItem:SetCurrentCharges(nGoldToDrop)
	local drop = CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), newItem)
	local dropTarget = killedUnit:GetAbsOrigin() + RandomVector(RandomFloat(50, 350))
	newItem:LaunchLoot(true, 300, 0.75, dropTarget)
end
