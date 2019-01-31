require("AOHGameMode")



function Precache(context)
	PrecacheItemByNameSync("item_tombstone", context)
	PrecacheItemByNameSync("item_bag_of_gold", context)
end


function Activate()
	GameRules.GameMode = AOHGameMode()
	GameRules.GameMode:InitGameMode()
end
