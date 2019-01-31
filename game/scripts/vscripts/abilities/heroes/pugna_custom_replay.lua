require("lib/my")
require("lib/timers")



function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability

    local cursor = used_ability:GetCursorPosition()

    local delay = ability_value(ability, "delay")

    if used_ability and used_ability:GetCaster() == caster and used_ability:GetAbilityType() ~= 1 then  -- not ultimate.
        Timers:CreateTimer(
            delay,
            function()
                if used_ability and caster:IsAlive() and ability:IsCooldownReady() then  -- test again, object may have been deleted.
                    if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
                        caster:SetCursorCastTarget(keys.target)
                    elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                        caster:SetCursorPosition(cursor)
                    else
                        caster:SetCursorTargetingNothing(true)
                    end

                    local mana_cost = used_ability:GetManaCost(used_ability:GetLevel() - 1)

                    if caster:GetMana() >= mana_cost then
                        caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)

                        used_ability:OnSpellStart()

                        caster:SpendMana(mana_cost, ability)

                        ability_start_true_cooldown(ability)
                    end
                end
            end
        )
    end
end

