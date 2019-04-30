

earth_spirit_custom_earth_disjoint = class({})


function earth_spirit_custom_earth_disjoint:IsStealable()
    return false
end


function earth_spirit_custom_earth_disjoint:GetIntrinsicModifierName()
    return "modifier_earth_spirit_custom_earth_disjoint"
end


function earth_spirit_custom_earth_disjoint:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_earth_spirit_custom_earth_disjoint_active", {
        duration = self:GetSpecialValueFor("duration")
    })

    caster:EmitSound("Hero_EarthSpirit.RollingBoulder.Cast")
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_disjoint_active", "abilities/heroes/earth_spirit_custom_earth_disjoint.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_disjoint_active = class({})


function modifier_earth_spirit_custom_earth_disjoint_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end


function modifier_earth_spirit_custom_earth_disjoint_active:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_disjoint", "abilities/heroes/earth_spirit_custom_earth_disjoint.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_disjoint = class({})


function modifier_earth_spirit_custom_earth_disjoint:IsHidden()
    return true
end


function modifier_earth_spirit_custom_earth_disjoint:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end


function modifier_earth_spirit_custom_earth_disjoint:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
end


function modifier_earth_spirit_custom_earth_disjoint:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end


function modifier_earth_spirit_custom_earth_disjoint:GetModifierMoveSpeed_AbsoluteMax()
    return 10000
end


function modifier_earth_spirit_custom_earth_disjoint:GetModifierMoveSpeed_Limit()
    return 10000
end


if IsServer() then
    function modifier_earth_spirit_custom_earth_disjoint:OnCreated(keys)
        local parent = self:GetParent()
        parent:AddNewModifier(parent, self:GetAbility(), "modifier_bloodseeker_thirst", {})
    end


    function modifier_earth_spirit_custom_earth_disjoint:OnDestroy()
        self:GetParent():RemoveModifierByName("modifier_bloodseeker_thirst")
    end
end
