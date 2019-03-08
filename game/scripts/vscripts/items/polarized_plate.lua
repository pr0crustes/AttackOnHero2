

item_polarized_plate = class({})


function item_polarized_plate:GetIntrinsicModifierName()
    return "modifier_item_polarized_plate"
end



LinkLuaModifier("modifier_item_polarized_plate", "items/polarized_plate.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_polarized_plate = class({})


function modifier_item_polarized_plate:IsHidden()
    return true
end


function modifier_item_polarized_plate:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_polarized_plate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end


function modifier_item_polarized_plate:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end


function modifier_item_polarized_plate:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end


function modifier_item_polarized_plate:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end


function modifier_item_polarized_plate:OnTakeDamage(keys)
    if IsServer() then
        local unit = keys.unit
        local attacker = keys.attacker

        if unit == self:GetParent() and unit ~= attacker then
            local damage = keys.original_damage
            local ability = self:GetAbility()

            if damage and damage > 0 and ability then
                local damage_to_mana = ability:GetSpecialValueFor("damage_to_mana")
                unit:GiveMana(damage * damage_to_mana * 0.01)
            end
        end
    end
end
