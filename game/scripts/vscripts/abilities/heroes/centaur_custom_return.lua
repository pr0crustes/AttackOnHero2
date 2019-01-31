require("lib/my")


function on_attacked(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.attacker
    
    local base_damage = ability_value(ability, "base_damage")
    local str_bonus = ability_value(ability, "str_bonus") * 0.01

    local caster_str = caster:GetStrength()

    local damage = base_damage + (caster_str * str_bonus)

    ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
	})
end