require("lib/my")
require("lib/timers")


function cast_last_cleave(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local base_damage = ability:GetSpecialValueFor("base_damage")
    local str_multiply = ability:GetSpecialValueFor("str_multiply")

    local caster_str = caster:GetStrength()

    local damage = base_damage + (caster_str * str_multiply)

    ApplyDamage({
        ability = ability,
        attacker = caster,
        damage = damage,
        damage_type = value_if_scepter(caster, DAMAGE_TYPE_PURE, ability:GetAbilityDamageType()),
        victim = target
    })

    Timers:CreateTimer(
        1, 
        function()
            if not target:IsAlive() then
                if ability:GetCooldownTimeRemaining() > 0 then
                    ability:EndCooldown()
                end
            end
            return nil
        end
    )
end

