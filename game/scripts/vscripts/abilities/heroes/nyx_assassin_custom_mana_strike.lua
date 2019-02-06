

function cast_nyx_assassin_custom_mana_strike(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local mana_multiplier = ability:GetSpecialValueFor("mana_multiplier")

    local damage = caster:GetMana() * mana_multiplier

    ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
	})
end

