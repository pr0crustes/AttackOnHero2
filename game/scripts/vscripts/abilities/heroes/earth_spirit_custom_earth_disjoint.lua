

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
