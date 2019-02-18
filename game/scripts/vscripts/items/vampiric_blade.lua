
LinkLuaModifier("modifier_item_vampiric_blade", "items/vampiric_blade.lua", LUA_MODIFIER_MOTION_NONE)



item_vampiric_blade = class({})


function item_vampiric_blade:GetIntrinsicModifierName()
    return "modifier_item_vampiric_blade"
end



item_vampiric_blade_2 = class(item_vampiric_blade)



modifier_item_vampiric_blade = class({})


function modifier_item_vampiric_blade:IsHidden()
    return true
end


function modifier_item_vampiric_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


if IsServer() then
    function modifier_item_vampiric_blade:GetValueRangedBased(if_not_ranged, if_ranged)
        local ability = self:GetAbility()
        if self:GetParent():IsRangedAttacker() then
            return ability:GetSpecialValueFor(if_ranged)
        end
        return ability:GetSpecialValueFor(if_not_ranged)
    end


    function modifier_item_vampiric_blade:GetModifierPreAttack_BonusDamage()
        return self:GetValueRangedBased("damage_bonus", "damage_bonus_ranged")
    end


    function modifier_item_vampiric_blade:OnAttackLanded(keys)
        local attacker = keys.attacker
        local target = keys.target

        if attacker == self:GetParent() and attacker ~= target then
            local heal = self:GetValueRangedBased("heal", "heal_ranged")
            attacker:Heal(heal, self:GetAbility())
            ParticleManager:CreateParticle("particles/custom/feaststeal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
        end
    end
end
