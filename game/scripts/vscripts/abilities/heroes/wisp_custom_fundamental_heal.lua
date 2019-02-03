require("lib/my")


local previous_hero = nil


function cast_wisp_custom_fundamental_heal(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local base_heal = ability:GetSpecialValueFor("base_heal")
    local multiplier = ability:GetSpecialValueFor("multiplier")

    local heal = base_heal

    if target == previous_hero then
        heal = heal * multiplier
    end

    previous_hero = target

    caster:EmitSound("Hero_Wisp.Relocate")

    target:Heal(heal, ability)
end
