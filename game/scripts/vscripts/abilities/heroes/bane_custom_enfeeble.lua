require("lib/my")


bane_custom_enfeeble = class({})


if IsServer() then
    function bane_custom_enfeeble:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        caster:EmitSound("Hero_Bane.Enfeeble.Cast")

        target:AddNewModifier(caster, self, "modifier_bane_custom_enfeeble", {
            duration = self:GetSpecialValueFor("duration")
        })
    end


    function bane_custom_enfeeble:GetCooldown(iLevel)
        local talent_value = talent_value(self:GetCaster(), "bane_custom_bonus_unique_2")
        if talent_value > 0 then
            return talent_value
        end
        return self.BaseClass.GetCooldown(self, iLevel)
    end
end


LinkLuaModifier("modifier_bane_custom_enfeeble", "abilities/heroes/bane_custom_enfeeble.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bane_custom_enfeeble = class({})


function modifier_bane_custom_enfeeble:GetEffectName()
    return "particles/units/heroes/hero_bane/bane_enfeeble.vpcf"
end


function modifier_bane_custom_enfeeble:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


function modifier_bane_custom_enfeeble:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end


function modifier_bane_custom_enfeeble:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end
