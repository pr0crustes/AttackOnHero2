require("lib/my")


local modifier = "modifier_silencer_custom_read_book_stack"


function cast_read_book(keys)
    local caster = keys.caster
    local ability = keys.ability

    local duration = ability:GetSpecialValueFor("duration")
    local multiplier = ability:GetSpecialValueFor("multiplier")

    local bonus_int = caster:GetIntellect() * multiplier

    ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
    caster:SetModifierStackCount(modifier, caster, bonus_int)

    caster:EmitSound("Hero_Silencer.GlobalSilence.Cast")
end
