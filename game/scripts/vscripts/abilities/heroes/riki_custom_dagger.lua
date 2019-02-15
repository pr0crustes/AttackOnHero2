require("lib/my")
require("lib/timers")


LinkLuaModifier("modifier_riki_custom_dagger", "abilities/heroes/riki_custom_dagger.lua", LUA_MODIFIER_MOTION_NONE)



riki_custom_dagger = class({})


function riki_custom_dagger:GetIntrinsicModifierName()
    return "modifier_riki_custom_dagger"
end



modifier_riki_custom_dagger = class({})


function modifier_riki_custom_dagger:IsHidden()
    return true
end


function modifier_riki_custom_dagger:IsPurgable()
    return false
end


if IsServer() then
    function modifier_riki_custom_dagger:DeclareFunctions()
        local funcs = {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        }
        return funcs
    end


    function modifier_riki_custom_dagger:GetModifierPreAttack_BonusDamage(keys)
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local agi_multiplier = ability:GetSpecialValueFor("agi_multiplier")

        local talent = parent:FindAbilityByName("riki_custom_bonus_unique_1")

        if talent and talent:GetLevel() > 0 then
            agi_multiplier = agi_multiplier + talent:GetSpecialValueFor("value")
        end

        local damage = parent:GetAgility() * agi_multiplier

        return damage
    end
end
