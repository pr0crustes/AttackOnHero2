

life_stealer_custom_deny = class({})


function life_stealer_custom_deny:GetIntrinsicModifierName()
    return "modifier_life_stealer_custom_deny"
end



LinkLuaModifier("modifier_life_stealer_custom_deny", "abilities/heroes/life_stealer_custom_deny.lua", LUA_MODIFIER_MOTION_NONE)

modifier_life_stealer_custom_deny = class({})


function modifier_life_stealer_custom_deny:IsHidden()
    return true
end


if IsServer() then
    function modifier_life_stealer_custom_deny:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end


    function modifier_life_stealer_custom_deny:OnAttackLanded(keys)
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
    
        if attacker == self:GetParent() and attacker:IsOpposingTeam(target:GetTeam()) then
            local modiifer_name = "modifier_life_stealer_custom_deny_debuff"

            if not target:HasModifier(modiifer_name) then
                target:AddNewModifier(attacker, ability, modiifer_name, {})
            end

            target:FindModifierByName(modiifer_name):IncrementStackCount()
        end
    end
end



LinkLuaModifier("modifier_life_stealer_custom_deny_debuff", "abilities/heroes/life_stealer_custom_deny.lua", LUA_MODIFIER_MOTION_NONE)

modifier_life_stealer_custom_deny_debuff = class({})


function modifier_life_stealer_custom_deny_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end


function modifier_life_stealer_custom_deny_debuff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("regen_decrease") * self:GetStackCount()
end
