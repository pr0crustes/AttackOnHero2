require("lib/my")
require("abilities/other/modify_hud_modifier")



local function new_stack_count(caster, modifier, max)
    local stack_count = 0
    if caster:HasModifier(modifier) then
        stack_count = caster:GetModifierStackCount(modifier, caster)
    end

    local new_stack = stack_count + 1
    
    if new_stack > max then  -- clamp at max.
        new_stack = max
    end
    return new_stack
end



function on_attack_landed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier
    local max = keys.max
    local duration = keys.duration

    local stack_count = new_stack_count(caster, modifier, max)

    ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
    caster:SetModifierStackCount(modifier, caster, stack_count)
end



-- Items, toggles and autocast should not trigger Triumviratus.
function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier
    local max = keys.max
    local used_ability = keys.event_ability
    local duration = keys.duration


    if used_ability 
        and not used_ability:IsItem()
        and not ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_TOGGLE)
        and not ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_AUTOCAST) then

        local stack_count = new_stack_count(caster, modifier, max)
    
        ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
        caster:SetModifierStackCount(modifier, caster, stack_count)
    end
end
