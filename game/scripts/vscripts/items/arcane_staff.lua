require("lib/my")
require("lib/popup")



item_arcane_staff = class({})


function item_arcane_staff:GetIntrinsicModifierName()
    return "modifier_item_arcane_staff"
end



LinkLuaModifier("modifier_item_arcane_staff", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_arcane_staff = class({})


function modifier_item_arcane_staff:IsHidden()
    return true
end


function modifier_item_arcane_staff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_arcane_staff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end


function modifier_item_arcane_staff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end


function modifier_item_arcane_staff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end



-- this will run multiple times every second, keep it optimized.
function arcane_staff_calculate_crit(damageTable)
    local attacker_index = damageTable.entindex_attacker_const
    
    if attacker_index then
        local attacker = EntIndexToHScript(attacker_index)

        if attacker and attacker:IsAlive() then
            local item = find_item(attacker, "item_arcane_staff")

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


