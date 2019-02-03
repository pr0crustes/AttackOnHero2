require("lib/my")



function ice_staff_calculate_crit(damageTable)
	local victim_index = damageTable.entindex_victim_const
    local attacker_index = damageTable.entindex_attacker_const
    local ability_index = damageTable.entindex_inflictor_const

    if victim_index and attacker_index and ability_index then
        local attacker = EntIndexToHScript(attacker_index)
        local victim = EntIndexToHScript(victim_index)
        local ability = EntIndexToHScript(ability_index)

        if attacker and victim and ability and victim ~= attacker and ability:GetAbilityDamageType() == DAMAGE_TYPE_MAGICAL then
            local item = find_item(attacker, "item_ice_staff")

            if item then
                local manacost_mult = ability_value(item, "manacost_mult")
                local ability_manacost = ability:GetManaCost(ability:GetLevel() - 1)
                local manacost = ability_manacost * manacost_mult * 0.01

                if attacker:GetMana() >= manacost then
                    local crit_chance = ability_value(item, "crit_chance")

                    if RollPercentage(crit_chance) then
                        local crit_damage_mult = ability_value(item, "crit_damage_mult")

                        damageTable.damage = damageTable.damage * crit_damage_mult * 0.01

                        attacker:SpendMana(manacost, item)

                        ParticleManager:CreateParticle("particles/custom/spellcrit.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
                    end
                end
            end
        end
    end

    return damageTable
end


