

item_broken_bow = class({})


function item_broken_bow:GetIntrinsicModifierName()
    return "modifier_item_broken_bow"
end



LinkLuaModifier("modifier_item_broken_bow", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow = class({})


if IsServer() then
    function modifier_item_broken_bow:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_broken_bow_tinker", {})
        end
    end
end


function modifier_item_broken_bow:IsHidden()
    return true
end


function modifier_item_broken_bow:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_broken_bow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end


function modifier_item_broken_bow:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end


function modifier_item_broken_bow:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end


function modifier_item_broken_bow:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_broken_bow:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movement_speed_bonus")
end



LinkLuaModifier("modifier_item_broken_bow_tinker", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_tinker = class({})


function modifier_item_broken_bow_tinker:IsHidden()
    return true
end


function modifier_item_broken_bow_tinker:RemoveOnDeath()
    return false
end


if IsServer() then
    function modifier_item_broken_bow_tinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end


    function modifier_item_broken_bow_tinker:OnAttackLanded(keys)
        local attacker = keys.attacker
        if attacker == self:GetParent() and attacker:IsRangedAttacker() then
            if not attacker:HasModifier("modifier_item_broken_bow") then
                self:Destroy()
                return nil
            end

            local count_modifier = attacker:FindModifierByName("modifier_item_broken_bow_count")
            if count_modifier then
                count_modifier:IncrementStackCount()
            else
                count_modifier = attacker:AddNewModifier(attacker, self, "modifier_item_broken_bow_count", {})
                count_modifier:SetStackCount(0)
            end

            local stack_count = count_modifier:GetStackCount()

            local attacks_needed = self:GetAbility():GetSpecialValueFor("attacks_needed")
            
            if stack_count > attacks_needed then
                attacker:PerformAttack(keys.target, true, true, true, true, true, false, false) 

                count_modifier:Destroy()
            end
        end
    end
end



LinkLuaModifier("modifier_item_broken_bow_count", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_count = class({})


function modifier_item_broken_bow_count:GetTexture()
    return "item_ForaMon/broken_bow"
end
