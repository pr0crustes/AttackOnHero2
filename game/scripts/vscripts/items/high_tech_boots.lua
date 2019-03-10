


item_high_tech_boots = class({})


function item_high_tech_boots:GetIntrinsicModifierName()
    return "modifier_item_high_tech_boots"
end



LinkLuaModifier("modifier_item_high_tech_boots", "items/high_tech_boots.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_high_tech_boots = class({})


function modifier_item_high_tech_boots:IsHidden()
    return true
end


function modifier_item_high_tech_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_high_tech_boots:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
end


function modifier_item_high_tech_boots:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end


function modifier_item_high_tech_boots:GetModifierMoveSpeed_AbsoluteMax()
    return 10000
end


function modifier_item_high_tech_boots:GetModifierMoveSpeed_Limit()
    return 10000
end


if IsServer() then
    function modifier_item_high_tech_boots:OnCreated(keys)
        local parent = self:GetParent()

        parent:AddNewModifier(parent, nil, "modifier_bloodseeker_thirst", {})
    end


    function modifier_item_high_tech_boots:OnDestroy()
        self:GetParent():RemoveModifierByName("modifier_bloodseeker_thirst")
    end
end
