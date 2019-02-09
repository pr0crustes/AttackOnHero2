require("lib/my")
require("AOHGameMode")



local caster = nil

local health_base = nil
local health_per_round = nil

local armor_base = nil
local armor_per_round = nil


function on_created(keys)
	caster = keys.caster
	local ability = keys.ability

	health_base = ability:GetSpecialValueFor("health_base")
	health_per_round = ability:GetSpecialValueFor("health_per_round")

	armor_base = ability:GetSpecialValueFor("armor_base")
	armor_per_round = ability:GetSpecialValueFor("armor_per_round")

	RoundStartCallback:RegisterCallback(set_ancient_stats)
	GlyphStartCallback:RegisterCallback(on_glyph_used)
end


function calculate_health(round)
	return health_base + (health_per_round * round._nRoundNumber)
end



function calculate_armor(round)
	return armor_base + (armor_per_round * round._nRoundNumber)
end



function on_glyph_used(round)
	if caster:HasModifier("modifier_fountain_glyph") then
		Timers:CreateTimer(
			0.1,
			function()
				on_glyph_used(round)
		  	end
		)
	end

	set_ancient_health(round, false)
	set_ancient_armor(round)
end


function set_ancient_health(round, heal)
	local maxHealth = calculate_health(round)

	local health = maxHealth

	if not heal then
		health = maxHealth * caster:GetHealthPercent() * 0.01
	end

	caster:SetMaxHealth(maxHealth)
	caster:SetHealth(health)
end


function set_ancient_armor(round)
	local armor = calculate_armor(round)
	caster:SetPhysicalArmorBaseValue(armor)
end


function set_ancient_stats(round)
	if caster and caster:FindAbilityByName("ancient_increase_stats") then
		set_ancient_health(round, true)
		set_ancient_armor(round)
	end
end

