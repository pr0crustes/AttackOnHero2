require("lib/my")



function cast_terrorblade_custom_consume(keys)
    local caster = keys.caster
    local ability = keys.ability

    local heal_base = ability_value(ability, "heal_base") * 0.01
    local heal_bonus = ability_value(ability, "heal_bonus") * 0.01

    local max_health = caster:GetMaxHealth()

    local heal_amount = max_health * heal_base

    local heal_per_illusion = max_health * heal_bonus

    local ownedUnits = Entities:FindAllByName(caster:GetName())

    for i, unit in ipairs(ownedUnits) do
        if unit:IsAlive() and unit:IsIllusion() then
            heal_amount = heal_amount + heal_per_illusion
            unit:Kill(ability, caster)
        end
    end

    caster:Heal(heal_amount, ability)
end

