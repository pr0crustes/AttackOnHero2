require("lib/my")


function increate_hud_modifier(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier

    increase_modifier(caster, caster, ability, modifier)
end


function decrease_hud_modifier(keys)
    local caster = keys.caster
    local modifier = keys.modifier

    decrease_modifier(caster, caster, modifier)
end
