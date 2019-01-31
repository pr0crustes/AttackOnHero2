require("lib/my")
require("lib/timers")


LinkLuaModifier("modifier_riki_custom_trick_hit", "abilities/heroes/riki_custom_trick_hit.lua", LUA_MODIFIER_MOTION_NONE)



riki_custom_trick_hit = class({})


function riki_custom_trick_hit:GetIntrinsicModifierName()
    return "modifier_riki_custom_trick_hit"
end



modifier_riki_custom_trick_hit = class({})


function modifier_riki_custom_trick_hit:IsHidden()
    return true
end


function modifier_riki_custom_trick_hit:IsPurgable()
    return false
end


function modifier_riki_custom_trick_hit:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end


function modifier_riki_custom_trick_hit:OnAttackLanded(keys)
    local ability = self:GetAbility()
    local attacker = keys.attacker
    local attack_damage = keys.original_damage
    local target = keys.target

    if attacker ~= self:GetParent() then 
        return 
    end

    local magic_percentage = ability:GetSpecialValueFor("percentage")

    local damage = attack_damage * magic_percentage * 0.01

    Timers:CreateTimer(
        0.1,
        function()
            ApplyDamage({
                victim = target,
                attacker = attacker,
                ability = ability,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage = damage,
                damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            })
            return nil
        end
    )
end
