
LinkLuaModifier("modifier_enchantress_custom_nature_mastery_think", "abilities/heroes/enchantress_custom_nature_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_enchantress_custom_nature_mastery_range", "abilities/heroes/enchantress_custom_nature_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_enchantress_custom_nature_mastery_attack_speed", "abilities/heroes/enchantress_custom_nature_mastery.lua", LUA_MODIFIER_MOTION_NONE)



enchantress_custom_nature_mastery = class({})


function enchantress_custom_nature_mastery:IsStealable()
    return false
end


function enchantress_custom_nature_mastery:GetIntrinsicModifierName()
    return "modifier_enchantress_custom_nature_mastery_think"
end


function enchantress_custom_nature_mastery:OnToggle()
    local modifier = self:GetCaster():FindModifierByName("modifier_enchantress_custom_nature_mastery_think")

    if modifier then
        modifier:Think()
    end
end



modifier_enchantress_custom_nature_mastery_think = class({})


function modifier_enchantress_custom_nature_mastery_think:IsHidden()
    return true
end


function modifier_enchantress_custom_nature_mastery_think:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end


if IsServer() then
    function modifier_enchantress_custom_nature_mastery_think:OnCreated(table)
        self:StartIntervalThink(1.0)
    end


    function modifier_enchantress_custom_nature_mastery_think:OnIntervalThink()
        self:Think()
    end


    function modifier_enchantress_custom_nature_mastery_think:Think()
        if self:GetAbility():GetToggleState() then
            self:ReplaceModifiers("modifier_enchantress_custom_nature_mastery_attack_speed", "modifier_enchantress_custom_nature_mastery_range")
        else
            self:ReplaceModifiers("modifier_enchantress_custom_nature_mastery_range", "modifier_enchantress_custom_nature_mastery_attack_speed")
        end
    end


    function modifier_enchantress_custom_nature_mastery_think:ReplaceModifiers(mod1, mod2)
        local parent = self:GetParent()
        if parent:HasModifier(mod1) then
            parent:RemoveModifierByName(mod1)
        end

        if not parent:HasModifier(mod2) then
            parent:AddNewModifier(parent, self:GetAbility(), mod2, {})
        end
    end
end




modifier_enchantress_custom_nature_mastery_range = class({})


function modifier_enchantress_custom_nature_mastery_range:IsHidden()
    return true
end


function modifier_enchantress_custom_nature_mastery_range:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end


function modifier_enchantress_custom_nature_mastery_range:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end


function modifier_enchantress_custom_nature_mastery_range:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range")
end



modifier_enchantress_custom_nature_mastery_attack_speed = class({})


function modifier_enchantress_custom_nature_mastery_attack_speed:IsHidden()
    return true
end


function modifier_enchantress_custom_nature_mastery_attack_speed:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end


function modifier_enchantress_custom_nature_mastery_attack_speed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end


function modifier_enchantress_custom_nature_mastery_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
