

local function swap_effect(hero1, hero2)
    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero1)
    ParticleManager:SetParticleControlEnt(fx, 1, hero2, PATTACH_ABSORIGIN_FOLLOW, nil, hero2:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(fx)
    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hero1)
end


function cast_vengefulspirit_custom_nether_power(keys)
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    if target then
        swap_effect(caster, target)
        target:AddNewModifier(caster, ability, "modifier_vengefulspirit_custom_nether_power", {
            duration = ability:GetSpecialValueFor("duration")
        })
    end
end



LinkLuaModifier("modifier_vengefulspirit_custom_nether_power", "abilities/heroes/vengefulspirit_custom_nether_power.lua", LUA_MODIFIER_MOTION_NONE)

modifier_vengefulspirit_custom_nether_power = class({})


function modifier_vengefulspirit_custom_nether_power:GetEffectName()
    return "particles/units/heroes/hero_arc_warden/arc_warden_tempest_buff.vpcf"
end


function modifier_vengefulspirit_custom_nether_power:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_vengefulspirit_custom_nether_power:GetModifierPreAttack_CriticalStrike()
    local ability = self:GetAbility()
    local crit_chance = ability:GetSpecialValueFor("crit_chance")
    if RollPercentage(crit_chance) then
        return ability:GetSpecialValueFor("crit_mult")
    end
end
