require("lib/my")


function think_intelligence_supremacy(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local int_mult = ability_value(ability, "int_multiplier")

    local damage = caster:GetIntellect() * int_mult

    ApplyDamage({
        attacker = caster,
        victim = target,
        ability = ability,
        damage_type = ability:GetAbilityDamageType(),
        damage = damage
    })
end
