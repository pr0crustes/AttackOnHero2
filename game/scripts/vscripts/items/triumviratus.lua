require("lib/my")
require("abilities/other/modify_hud_modifier")



-- Items, toggles and autocast should not trigger Triumviratus.
function on_ability_executed(keys)
    local caster = keys.caster
    local used_ability = keys.event_ability


    if used_ability 
        and not used_ability:IsItem()
        and not ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_TOGGLE)
        and not ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_AUTOCAST) then
        add_modifier_if_not_max(keys)
    end
end
