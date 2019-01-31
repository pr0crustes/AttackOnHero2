require("lib/my")
require("lib/timers")



function cast_clinkz_custom_multiattack(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local attack_count = ability_value(ability, "attack_count")
    local interval = ability_value(ability, "interval")

    local attacks = 0

	Timers:CreateTimer(
		function()
            if target:IsAlive() and attacks < attack_count then
                attacks = attacks + 1

                caster:PerformAttack(target, true, true, true, false, true, false, false)

                return interval
			end
			return nil
		end
	)
end

