require("lib/my")



function cast_flesh_heap(keys)
    local caster = keys.caster
    local ability = keys.ability
    local stack_modifier = keys.modifier

    local multiplier = ability:GetSpecialValueFor("multiplier")
    local duration = ability:GetSpecialValueFor("duration")

    local talent = caster:FindAbilityByName("pudge_custom_bonus_unique_pudge_1")
    if talent and talent:GetLevel() > 0 then
        duration = duration + talent:GetSpecialValueFor("value")
    end

    local bonus_str = caster:GetStrength() * multiplier

    ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {duration = duration})
    caster:SetModifierStackCount(stack_modifier, caster, bonus_str)

    caster:CalculateStatBonus()

    caster:EmitSound("Hero_Pudge.Dismember.Cast.Arcana")
end
