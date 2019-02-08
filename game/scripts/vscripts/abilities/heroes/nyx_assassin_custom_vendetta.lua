

LinkLuaModifier("modifier_nyx_assassin_custom_vendetta", "abilities/heroes/nyx_assassin_custom_vendetta.lua", LUA_MODIFIER_MOTION_NONE)


modifier_nyx_assassin_custom_vendetta = class({})


function modifier_nyx_assassin_custom_vendetta:GetTexture()
    return "nyx_assassin_vendetta"
end


function modifier_nyx_assassin_custom_vendetta:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end


function modifier_nyx_assassin_custom_vendetta:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end


function modifier_nyx_assassin_custom_vendetta:GetModifierInvisibilityLevel()
    return 1
end


function modifier_nyx_assassin_custom_vendetta:OnAttackLanded(keys)
    local attacker = keys.attacker
    if attacker == self:GetParent() then 
        self:Destroy() 
    end
end


function modifier_nyx_assassin_custom_vendetta:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movement_speed")
end


if IsServer() then
    function modifier_nyx_assassin_custom_vendetta:OnCreated(table)
        local ability = self:GetAbility()

        if not ability then
            self:Destroy()
            return nil
        end

        self.crit_increase = table.crit

        self.current_crit = self.crit_increase

        self.interval = ability:GetSpecialValueFor("interval")
        self:StartIntervalThink(self.interval)
    end


    function modifier_nyx_assassin_custom_vendetta:OnIntervalThink()
        print("Current " .. self.current_crit)
        self.current_crit = self.current_crit + self.crit_increase
    end

    function modifier_nyx_assassin_custom_vendetta:GetModifierPreAttack_CriticalStrike()
        return self.current_crit
    end
end



function cast_nyx_assassin_custom_vendetta(keys)
    local caster = keys.caster
    local ability = keys.ability
    
    local duration = ability:GetSpecialValueFor("duration")
    local crit_increase = ability:GetSpecialValueFor("crit_increase")

    local talent = caster:FindAbilityByName("nyx_assassin_custom_bonus_unique_1")
    if talent and talent:GetLevel() > 0 then
        crit_increase = crit_increase + talent:GetSpecialValueFor("value")
    end

    caster:AddNewModifier(caster, ability, "modifier_nyx_assassin_custom_vendetta", {
        duration = duration,
        crit = crit_increase
    })
end

