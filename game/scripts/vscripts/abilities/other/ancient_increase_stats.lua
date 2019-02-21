require("lib/my")
require("AOHGameMode")



local previous_round = 1


function on_created(keys)
	local caster = keys.caster
	local ability = keys.ability

	local health_base = ability:GetSpecialValueFor("health_base")
	local health_per_round = ability:GetSpecialValueFor("health_per_round")

	local armor_base = ability:GetSpecialValueFor("armor_base")
	local armor_per_round = ability:GetSpecialValueFor("armor_per_round")

	Timers:CreateTimer(
		function()
			if caster and not caster:IsNull() and caster:IsAlive() and caster:FindAbilityByName("ancient_increase_stats") then
				local round = GameRules.GLOBAL_roundNumber
				if round and round > 0 then

					-- Health
					local maxHealth = health_base + (health_per_round * round)
					local health = maxHealth
				
					if round == previous_round then   -- heal only when round changes.
						health = maxHealth * caster:GetHealthPercent() * 0.01
					end
				
					caster:SetMaxHealth(maxHealth)
					caster:SetHealth(health)
					--


					-- Armor
					local armor = armor_base + (armor_per_round * round)
					caster:SetPhysicalArmorBaseValue(armor)
					--

					previous_round = round
				end
			end
			return 1.0
		end
	)
end
