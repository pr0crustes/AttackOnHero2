require("lib/playertables")
require("lib/data")


--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]


ALL_PLAYERS_INTERVAL = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}


function formated_number(number)
    local as_string = tostring(math.floor(number))
    if number < 1000 then
        return as_string
    end

    local len = as_string:len()
    local split_point = len - 3

    return as_string:sub(1, split_point) .. "." .. as_string:sub(split_point, len - 3) .. "K"
end



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

                damageTaken = formated_number(player_data_get_value(playerID, "damageTaken")),
                bossDamage = formated_number(player_data_get_value(playerID, "bossDamage")),
                heroHealing = formated_number(PlayerResource:GetHealing(playerID)),
                deaths = PlayerResource:GetDeaths(playerID),
                goldBags = player_data_get_value(playerID, "goldBagsCollected"),
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

            local net_worth = PlayerResource:GetGold(playerID)
            for slot, item in pairs(playerInfo.items) do
                net_worth = net_worth + GetItemCost(item)
            end
            playerInfo.netWorth = formated_number(net_worth)

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
                PlayerTables:CreateTable("stats_game_result", data, ALL_PLAYERS_INTERVAL)
            end
        end,

        function(msg)
            return msg..'\n'..debug.traceback()..'\n'
        end
    )
    if not status then
		PlayerTables:CreateTable("stats_game_result", {error = nextCall}, ALL_PLAYERS_INTERVAL)
	end
end
