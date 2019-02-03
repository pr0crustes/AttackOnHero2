require("lib/my")



function cast_shadow_heal(keys)
    local caster = keys.caster
    local ability = keys.ability

    local duration = ability:GetSpecialValueFor("duration")

    local heal = caster:GetHealthRegen() * duration

    caster:Heal(heal, ability)

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_custom_shadow_heal_negation", {duration = duration})
end

