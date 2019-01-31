require("lib/my")



function on_interval_think(keys)
	local ability = keys.ability
	local caster = keys.caster


	local damage_pct = ability_value(ability, "damage_pct")

	local health_loss = caster:GetMaxHealth() * damage_pct * 0.01
	health_loss = health_loss + caster:GetHealthRegen()   -- so that it negates regen.

	local new_health = caster:GetHealth() - health_loss
	new_health = math.max(new_health, 1)    -- so it never sets to 0.
	
	caster:SetHealth(new_health)
end
