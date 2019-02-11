require("lib/my")
require("lib/popup")



-- this will run multiple times every second, keep it optimized.
function ice_staff_calculate_crit(damageTable)
    local attacker_index = damageTable.entindex_attacker_const
    
    if attacker_index then
        local attacker = EntIndexToHScript(attacker_index)

        if attacker and attacker:IsAlive() then
            local item = find_item(attacker, "item_ice_staff")

            if item then
                local ability_index = damageTable.entindex_inflictor_const

                if ability_index then
                    local ability = EntIndexToHScript(ability_index)

                    if ability and ability:GetAbilityDamageType() == DAMAGE_TYPE_MAGICAL and not ability:IsItem() then
                        local victim_index = damageTable.entindex_victim_const

                        if victim_index then
                            local victim = EntIndexToHScript(victim_index)

                            if victim and victim ~= attacker then

                                local crit_chance = item:GetSpecialValueFor("crit_chance")
                                local mana_cost = item:GetManaCost(-1)

                                if RollPercentage(crit_chance) and attacker:GetMana() >= mana_cost then

                                    local crit_damage_mult = item:GetSpecialValueFor("crit_damage_mult")
                                    damageTable.damage = damageTable.damage * crit_damage_mult * 0.01

                                    create_popup({
                                        target = victim,
                                        value = damageTable.damage,
                                        color = Vector(100, 149, 237),
                                        type = "crit",
                                        pos = 4
                                    })

                                    attacker:SpendMana(mana_cost, item)
                
                                    local fx1 = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_skywrath_mage_mystic_flare_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
                                    ParticleManager:ReleaseParticleIndex(fx1)
                                end 
                            end
                        end
                    end
                end
            end
        end
    end

    return damageTable
end


