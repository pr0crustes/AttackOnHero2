require("lib/my")
require("lib/timers")


riki_custom_trick_hit = class({})


function riki_custom_trick_hit:GetIntrinsicModifierName()
    return "modifier_riki_custom_trick_hit_autocast"
end


function riki_custom_trick_hit:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_riki_custom_trick_hit") then
        caster:RemoveModifierByName("modifier_riki_custom_trick_hit")
    end

    local modifier = caster:AddNewModifier(caster, self, "modifier_riki_custom_trick_hit", {})

    local bonus_agi = caster:GetAgility() * self:GetSpecialValueFor("bonus_agi_pct") * 0.01
    modifier:SetStackCount(bonus_agi)
end



LinkLuaModifier("modifier_riki_custom_trick_hit_autocast", "abilities/heroes/riki_custom_trick_hit.lua", LUA_MODIFIER_MOTION_NONE)

modifier_riki_custom_trick_hit_autocast = class({})


function modifier_riki_custom_trick_hit_autocast:IsHidden()
    return true
end


if IsServer() then
    function modifier_riki_custom_trick_hit_autocast:OnCreated(keys)
        self:StartIntervalThink(0.1)
    end


    function modifier_riki_custom_trick_hit_autocast:OnIntervalThink()
		local ability = self:GetAbility()
        local parent = self:GetParent()

        if parent:IsAlive()
            and ability:GetAutoCastState()
            and not parent:HasModifier("modifier_riki_custom_trick_hit")
            and parent:GetMana() >= ability:GetManaCost(ability:GetLevel() - 1)
            and not parent:IsChanneling()
            and not parent:IsInvisible()
            and not (parent:GetCurrentActiveAbility() and parent:GetCurrentActiveAbility():IsInAbilityPhase()) then

            parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
		end
    end
end




LinkLuaModifier("modifier_riki_custom_trick_hit", "abilities/heroes/riki_custom_trick_hit.lua", LUA_MODIFIER_MOTION_NONE)

modifier_riki_custom_trick_hit = class({})


function modifier_riki_custom_trick_hit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_riki_custom_trick_hit:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end


function modifier_riki_custom_trick_hit:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then 
        self:Destroy()
    end
end
