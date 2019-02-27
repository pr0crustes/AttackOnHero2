

function cast_shadow_heal(keys)
    local caster = keys.caster
    local ability = keys.ability

    local heal = caster:GetHealthRegen() * ability:GetSpecialValueFor("multiplier")

    caster:Heal(heal, ability)
end

