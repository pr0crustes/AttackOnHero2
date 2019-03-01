


bloodseeker_custom_rampage = class({})


if IsServer() then
    function bloodseeker_custom_rampage:OnSpellStart()
        local caster = self:GetCaster()

        caster:AddNewModifier(caster, self, "modifier_bloodseeker_custom_rampage", {
            duration = self:GetSpecialValueFor("duration")
        })
    end
end



LinkLuaModifier("modifier_bloodseeker_custom_rampage", "abilities/heroes/bloodseeker_custom_rampage.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bloodseeker_custom_rampage = class({})


function modifier_bloodseeker_custom_rampage:IsBuff()
    return true
end


function modifier_bloodseeker_custom_rampage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end


function modifier_bloodseeker_custom_rampage:GetModifierMoveSpeed_Absolute()
    return 550
end


function modifier_bloodseeker_custom_rampage:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("increased_damage")
end


if IsServer() then
    function modifier_bloodseeker_custom_rampage:OnAttackLanded(keys)
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local attack_damage = keys.damage
        local target = keys.target
    
        if attacker == self:GetParent() then
            local increased_damage = ability:GetSpecialValueFor("increased_damage")
            local damage_taken = ability:GetSpecialValueFor("damage_taken")

            local damage_multiplier = damage_taken / (100 + increased_damage)
            local damage = attack_damage * damage_multiplier
        
            ApplyDamage({
                victim = attacker,
                attacker = attacker,
                ability = ability,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage = damage,
                damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            })
        end
    end
end
