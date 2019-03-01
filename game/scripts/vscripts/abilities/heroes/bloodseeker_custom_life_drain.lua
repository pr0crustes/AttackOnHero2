

bloodseeker_custom_life_drain = class({})


function bloodseeker_custom_life_drain:GetIntrinsicModifierName()
    return "modifier_bloodseeker_custom_life_drain_aura"
end



LinkLuaModifier("modifier_bloodseeker_custom_life_drain_aura", "abilities/heroes/bloodseeker_custom_life_drain.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bloodseeker_custom_life_drain_aura = class({})


function modifier_bloodseeker_custom_life_drain_aura:IsHidden()
    return true
end


if IsServer() then
    function modifier_bloodseeker_custom_life_drain_aura:OnCreated(keys)
        local ability = self:GetAbility()
        self.radius = ability:GetSpecialValueFor("radius")
        self.target_type = ability:GetAbilityTargetType()
        self.target_team = ability:GetAbilityTargetTeam()
        self.target_flags = ability:GetAbilityTargetFlags()
    end


    function modifier_bloodseeker_custom_life_drain_aura:IsAura()
        return true
    end


    function modifier_bloodseeker_custom_life_drain_aura:GetAuraRadius()
        return self.radius
    end


    function modifier_bloodseeker_custom_life_drain_aura:GetAuraSearchTeam()
        return self.target_team
    end


    function modifier_bloodseeker_custom_life_drain_aura:GetAuraSearchType()
        return self.target_type
    end


    function modifier_bloodseeker_custom_life_drain_aura:GetAuraSearchFlags()
        return self.target_flags
    end


    function modifier_bloodseeker_custom_life_drain_aura:GetModifierAura()
        return "modifier_bloodseeker_custom_life_drain_debuff"
    end
end



LinkLuaModifier("modifier_bloodseeker_custom_life_drain_debuff", "abilities/heroes/bloodseeker_custom_life_drain.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bloodseeker_custom_life_drain_debuff = class({})


function modifier_bloodseeker_custom_life_drain_debuff:IsDebuff()
    return true
end


function modifier_bloodseeker_custom_life_drain_debuff:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end


if IsServer() then
    function modifier_bloodseeker_custom_life_drain_debuff:OnCreated(keys)
        local ability = self:GetAbility()

        self.ticks_per_sec = ability:GetSpecialValueFor("ticks_per_sec")
        self.attack_as_damage = (ability:GetSpecialValueFor("attack_as_damage") / self.ticks_per_sec) * 0.01

        self.tick_interval = 1 / self.ticks_per_sec

        self:StartIntervalThink(self.tick_interval)
    end


    function modifier_bloodseeker_custom_life_drain_debuff:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local damage = caster:GetAverageTrueAttackDamage(parent) * self.attack_as_damage

        local dealt_damage = ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })

        caster:Heal(dealt_damage * ability:GetSpecialValueFor("heal") * 0.01, caster)
    end
end
