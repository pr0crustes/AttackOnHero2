require("lib/timers")



function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability

    print("aaaaaaaaaa")

    if used_ability 
        and used_ability:GetCaster() == caster 
        and used_ability ~= ability 
        and used_ability:GetName() ~= "item_custom_refresher" then

        print("bbbbbbbb")
        Timers:CreateTimer(
            0.2, 
            function()
                if used_ability then
                    used_ability:EndCooldown()
                    used_ability:StartCooldown(1.0)
                end
            end
        )
    end
end
