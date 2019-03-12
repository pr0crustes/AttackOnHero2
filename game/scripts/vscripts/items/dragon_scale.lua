

item_dragon_scale = class({})

function item_dragon_scale:GetIntrinsicModifierName()
    return "modifier_item_dragon_scale"
end



LinkLuaModifier("modifier_item_dragon_scale", "items/dragon_scale.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_dragon_scale = class({})


function modifier_item_dragon_scale:IsHidden()
    return true
end


function modifier_item_dragon_scale:IsAura()
    return true
end


function modifier_item_dragon_scale:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end


function modifier_item_dragon_scale:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end


function modifier_item_dragon_scale:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_item_dragon_scale:GetModifierAura()
    return "modifier_item_dragon_scale_aura_buff"
end


function modifier_item_dragon_scale:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_dragon_scale:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end


function modifier_item_dragon_scale:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end


function modifier_item_dragon_scale:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end



LinkLuaModifier("modifier_item_dragon_scale_aura_buff", "items/dragon_scale.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_dragon_scale_aura_buff = class({})


function modifier_item_dragon_scale_aura_buff:GetTexture()
    return "item_ForaMon/dragon_scale"
end


function modifier_item_dragon_scale_aura_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end


function modifier_item_dragon_scale_aura_buff:GetModifierHealthBonus()
    local ability = self:GetAbility()
    if ability then
        return ability:GetSpecialValueFor("aura_bonus_health")
    end
end


function modifier_item_dragon_scale_aura_buff:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    if ability then
        return ability:GetSpecialValueFor("aura_bonus_strength")
    end
end
