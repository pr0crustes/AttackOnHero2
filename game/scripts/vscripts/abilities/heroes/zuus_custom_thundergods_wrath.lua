require("lib/my")
require("lib/timers")



function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability

    local cursor = used_ability:GetCursorPosition()

    local casts = ability_value(ability, "casts")
    local interval = ability_value(ability, "interval")

    if 
        used_ability 
        and used_ability:GetCaster() == caster 
        and not used_ability:IsItem() 
        and used_ability:GetAbilityType() ~= 1
        and used_ability:GetName() ~= "zuus_cloud" then

        caster:RemoveModifierByName("zuus_custom_thundergods_wrath_buff")

        local count = 0
        Timers:CreateTimer(
            interval,
            function()
                if used_ability and caster:IsAlive() then  -- test again, object may have been deleted.
                    if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
                        caster:SetCursorCastTarget(keys.target)
                    elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                        caster:SetCursorPosition(cursor)
                    else
                        caster:SetCursorTargetingNothing(true)
                    end

                    caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                    used_ability:OnSpellStart()

                    count = count + 1
                    if casts > count then
                        return interval
                    end
                end
            end
        )
    end
end

