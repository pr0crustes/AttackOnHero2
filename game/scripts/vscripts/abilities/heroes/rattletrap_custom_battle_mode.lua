


rattletrap_custom_battle_mode = class({})


function rattletrap_custom_battle_mode:OnToggle()
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Rattletrap.Power_Cogs")

    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_battle_mode", {})
    else
        caster:RemoveModifierByName("modifier_rattletrap_custom_battle_mode")
    end
end



LinkLuaModifier("modifier_rattletrap_custom_battle_mode", "abilities/heroes/rattletrap_custom_battle_mode.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_battle_mode = class({})


function modifier_rattletrap_custom_battle_mode:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_rattletrap_custom_battle_mode:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end


function modifier_rattletrap_custom_battle_mode:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_magic_res")
end


function modifier_rattletrap_custom_battle_mode:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end


function modifier_rattletrap_custom_battle_mode:GetModifierModelScale()
    return 50
end
