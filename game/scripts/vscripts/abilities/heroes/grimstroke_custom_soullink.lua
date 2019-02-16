require("lib/my")
require("lib/timers")



function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier
    local used_ability = keys.event_ability

    if ability and not ability:IsItem() and ability:GetCaster() == caster then
        increase_modifier(caster, caster, ability, modifier)
    end
end


function cast_grimstroke_custom_soullink(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local modifier = keys.modifier

    if caster:HasModifier(modifier) then

        local stack_count = caster:GetModifierStackCount(modifier, caster)

        target:EmitSound("Hero_Grimstroke.SoulChain.Cast")

        if caster:IsOpposingTeam(target:GetTeam()) then
            local damage = ability:GetSpecialValueFor("damage")
            ApplyDamage({
                ability = ability,
                attacker = caster,
                damage = damage * stack_count,
                damage_type = ability:GetAbilityDamageType(),
                victim = target
            })
        else
            local heal = ability:GetSpecialValueFor("heal")
            target:Heal(heal * stack_count, caster)
        end

        caster:RemoveModifierByName(modifier)
    else
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        ability:EndCooldown()
    end
end
