require("lib/my")
require("lib/timers")



--[[
    About time of the day:
    It is a float from 0 to 1,
    where from 0.25 up to 0.75 is day
    and from 0.0 to 0.25 and from 0.75 to 1.0 is night, so it wraps.
]]


function cast_keeper_of_the_light_custom_dawn(keys)
    local ability = keys.ability

    local duration = ability:GetSpecialValueFor("duration")

    local previous_time_of_day = GameRules:GetTimeOfDay()

    GameRules:SetTimeOfDay(0.30)

    Timers:CreateTimer(
        duration, 
        function()
            GameRules:SetTimeOfDay(previous_time_of_day)
        end
    )
end
