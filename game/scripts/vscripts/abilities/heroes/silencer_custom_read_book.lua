require("lib/my")


local modifier = "modifier_silencer_custom_read_book_stack"


function cast_read_book(keys)
    local caster = keys.caster
    local ability = keys.ability

    local duration = ability_value(ability, "duration")
    local multiplier = ability_value(ability, "multiplier")

    local bonus_int = caster:GetIntellect() * multiplier

    ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
    caster:SetModifierStackCount(modifier, caster, bonus_int)

    caster:EmitSound("Hero_Silencer.GlobalSilence.Cast")
end
