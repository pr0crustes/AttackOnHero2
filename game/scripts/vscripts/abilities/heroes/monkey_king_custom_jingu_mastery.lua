

local hud_modifier = "modifier_monkey_king_custom_jingu_mastery_hit"


monkey_king_custom_jingu_mastery = class({})


function monkey_king_custom_jingu_mastery:GetIntrinsicModifierName()
    return "modifier_monkey_king_custom_jingu_mastery_thinker"
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_thinker", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_thinker = class({})


function modifier_monkey_king_custom_jingu_mastery_thinker:IsHidden()
    return true
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end


    function modifier_monkey_king_custom_jingu_mastery_thinker:OnAttackLanded(keys)
        local attacker = keys.attacker
        
        if attacker == self:GetParent() then
            local ability = self:GetAbility()

            if not attacker:HasModifier(hud_modifier) then
                attacker:AddNewModifier(attacker, ability, hud_modifier, {})
            end

            local modifier_handler = attacker:FindModifierByName(hud_modifier)
            modifier_handler:IncrementStackCount()

            if modifier_handler:GetStackCount() >= ability:GetSpecialValueFor("attack_count") then
                modifier_handler:Destroy()

                attacker:AddNewModifier(attacker, ability, "modifier_monkey_king_custom_jingu_mastery_buff", {})
            end
        end
    end
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_hit", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_hit = class({})


function modifier_monkey_king_custom_jingu_mastery_hit:IsBuff()
    return true
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_hit:OnStackCountChanged(count)
        ParticleManager:SetParticleControl(self.effect, 1, Vector(0, count + 1, 0))
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnCreated(keys)
        local parent = self:GetParent()
        self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.effect, 0, parent:GetAbsOrigin())
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnDestroy()
        ParticleManager:DestroyParticle(self.effect, false)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_buff", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_buff = class({})


function modifier_monkey_king_custom_jingu_mastery_buff:IsBuff()
    return true
end


function modifier_monkey_king_custom_jingu_mastery_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_monkey_king_custom_jingu_mastery_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_buff:DisplayEffect(target)
        local heal_effect = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(heal_effect)

        local hit_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(hit_effect, 1, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(hit_effect)
    end


    function modifier_monkey_king_custom_jingu_mastery_buff:OnJinguHit(damage, target)
        local parent = self:GetParent()
        local ability = self:GetAbility()

        local lifesteal = ability:GetSpecialValueFor("lifesteal") * 0.01

        parent:Heal(damage * lifesteal, parent)

        self:DisplayEffect(target)

        self:Destroy()
    end


    function modifier_monkey_king_custom_jingu_mastery_buff:OnAttackLanded(keys)
        if keys.attacker == self:GetParent() then
            self:OnJinguHit(keys.damage, keys.target)
        end
    end
end
