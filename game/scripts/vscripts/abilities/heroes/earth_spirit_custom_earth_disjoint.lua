

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


function modifier_earth_spirit_custom_earth_disjoint_active:GetEffectName()
    return "particles/generic_gameplay/rune_haste_owner.vpcf"
end


function modifier_earth_spirit_custom_earth_disjoint_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }
end


function modifier_earth_spirit_custom_earth_disjoint_active:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end


function modifier_earth_spirit_custom_earth_disjoint_active:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percentage")
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
