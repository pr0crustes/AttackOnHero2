
LinkLuaModifier("modifier_puck_custom_dream_strike", "abilities/heroes/puck_custom_dream_strike.lua", LUA_MODIFIER_MOTION_NONE)


function cast_puck_custom_dream_strike(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local duration = ability:GetSpecialValueFor("duration")
    local tick_interval = ability:GetSpecialValueFor("tick_interval")

    local int_multiplier = ability:GetSpecialValueFor("int_multiplier")
    local damage = caster:GetIntellect() * int_multiplier

    target:AddNewModifier(caster, ability, "modifier_puck_custom_dream_strike", {
        duration = duration,
        tick_interval = tick_interval,
        tick_damage = damage / (duration / tick_interval)
    })
end



modifier_puck_custom_dream_strike = class({})


function modifier_puck_custom_dream_strike:IsHidden()
    return true
end


if IsServer() then
    function modifier_puck_custom_dream_strike:OnCreated(keys)
        self.tick_damage = keys.tick_damage
        self.tick_interval = keys.tick_interval

        self:StartIntervalThink(self.tick_interval)

        self:GetParent():EmitSound("Hero_Puck.Dream_Coil")
    end


    function modifier_puck_custom_dream_strike:OnIntervalThink()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        ApplyDamage({
            ability = ability,
            attacker = self:GetCaster(),
            damage = self.tick_damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })
    
        parent:EmitSound("Hero_Puck.Dream_Coil_Snap")
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end
