require("lib/my")


local modifier = "modifier_pudge_custom_flesh_heap_stack"


function cast_flesh_heap(keys)
    local caster = keys.caster
    local ability = keys.ability

    local duration = ability_value(ability, "duration")
    local multiplier = ability_value(ability, "multiplier")

    local bonus_int = caster:GetStrength() * multiplier

    ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
    caster:SetModifierStackCount(modifier, caster, bonus_int)

    caster:EmitSound("Hero_Pudge.Dismember.Cast.Arcana")
end
