require("lib/my")


local modifier_hud = "modifier_storm_spirit_custom_overload_hud"
local modifier_duration = "modifier_storm_spirit_custom_overload_duration"


function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability


    if used_ability and caster:IsAlive() and not used_ability:IsItem() then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_duration, {})
    end
end


function target_effects(target)
    target:EmitSound("Hero_StormSpirit.Overload")
    ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
end


function on_attack_landed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    if caster:HasModifier(modifier_hud) and caster:IsAlive() and target:IsAlive() then
        
        local damage_per_stack = ability_value(ability, "damage")
        local radius = ability_value(ability, "radius")

        local stack_count = caster:GetModifierStackCount(modifier_hud, caster)
        
        local damage = damage_per_stack * stack_count

        target_effects(target)


        local units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

        for _, unit in ipairs(units) do
            ApplyDamage({
                victim = unit,
                attacker = caster,
                damage = damage,
                damage_type = ability:GetAbilityDamageType(),
                ability = ability,
            })
        end

        while caster:HasModifier(modifier_duration) do
            caster:RemoveModifierByName(modifier_duration)
        end
    end
end
