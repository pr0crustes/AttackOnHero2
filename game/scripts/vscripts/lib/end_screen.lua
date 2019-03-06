require("lib/playertables")
require("lib/data")


--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]


AllPlayersInterval = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}



function end_screen_get_data(isWinner)
    local time = GameRules:GetDOTATime(false, true)
    local matchID = tostring(GameRules:GetMatchID())

    local data = {
        version = "2.1.2",
        matchID = matchID,
        mapName = GetMapName(),
        players = {},
        isWinner = isWinner,
        duration = math.floor(time),
        flags = {}
    }

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local playerInfo = {
                steamid = tostring(PlayerResource:GetSteamID(playerID)),

                damageTaken = player_data_get_value(playerID, "damageTaken"),
                bossDamage = player_data_get_value(playerID, "bossDamage"),
                heroHealing = PlayerResource:GetHealing(playerID),
                deaths = PlayerResource:GetDeaths(playerID),
                heroName = "",

                str = 0,
                agi = 0,
                int = 0,

                level = 0,
                items = {}
            }

            local hero = PlayerResource:GetSelectedHeroEntity(playerID)

            if IsValidEntity(hero) then
                playerInfo.heroName = hero:GetName()

                playerInfo.level = hero:GetLevel()
                playerInfo.str = hero:GetStrength()
                playerInfo.agi = hero:GetAgility()
                playerInfo.int = hero:GetIntellect()

                for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        playerInfo.items[item_slot] = item:GetAbilityName()
                    end
                end
            end

            playerInfo.netWorth = PlayerResource:GetGold(playerID)
            for slot, item in pairs(playerInfo.items) do
                playerInfo.netWorth = GetItemCost(item)
            end

            data.players[playerID] = playerInfo
        end
    end
    return data
end


local has_send_data = false


function end_screen_setup(isWinner)
	local status, nextCall = xpcall(
        function()
            if not has_send_data then
                has_send_data = true

                local data = end_screen_get_data(isWinner)
                PlayerTables:CreateTable("stats_game_result", data, AllPlayersInterval)
            end
        end,

        function(msg)
            return msg..'\n'..debug.traceback()..'\n'
        end
    )
    if not status then
		PlayerTables:CreateTable("stats_game_result", {error = nextCall}, AllPlayersInterval)
	end
end
