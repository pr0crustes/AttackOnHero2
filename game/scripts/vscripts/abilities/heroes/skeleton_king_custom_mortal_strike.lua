LinkLuaModifier("modifier_skeleton_king_custom_mortal_strike", "abilities/heroes/skeleton_king_custom_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE)



skeleton_king_custom_mortal_strike = class({})


function skeleton_king_custom_mortal_strike:GetIntrinsicModifierName()
    return "modifier_skeleton_king_custom_mortal_strike"
end



modifier_skeleton_king_custom_mortal_strike = class({})


function modifier_skeleton_king_custom_mortal_strike:IsHidden()
    return true
end


function modifier_skeleton_king_custom_mortal_strike:IsPurgable()
    return false
end


function modifier_skeleton_king_custom_mortal_strike:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }
    return funcs
end


function modifier_skeleton_king_custom_mortal_strike:GetModifierPreAttack_CriticalStrike()
    local ability = self:GetAbility()
    local crit_chance = ability:GetSpecialValueFor("crit_chance")
    if RollPercentage(crit_chance) then
        return ability:GetSpecialValueFor("crit_mult")
    end
end
