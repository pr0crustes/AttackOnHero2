

local function launch_tide(unit, ability, target)
    ProjectileManager:CreateTrackingProjectile({
        Ability = ability,
        Target = target,
        Source = unit,
        EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush.vpcf",
        iMoveSpeed = 2000,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        bDodgeable = false,
        flExpireTime = GameRules:GetGameTime() + 10.0,
    })
end



function cast_naga_siren_custom_tide(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local damage_percentage = ability:GetSpecialValueFor("damage_percentage") * 0.01

    caster:EmitSound("Hero_NagaSiren.RipTide.Precast")

    launch_tide(caster, ability, target)

    local units = Entities:FindAllByName(caster:GetName())
    for i, unit in ipairs(units) do
        if unit:IsAlive() and unit:IsIllusion() and unit:GetRangeToUnit(target) <= ability:GetCastRange() then
            launch_tide(unit, ability, target)
        end
    end
end



function on_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    
    local damage_percentage = ability:GetSpecialValueFor("damage_percentage")
    local damage = caster:GetAverageTrueAttackDamage(target) * damage_percentage * 0.01

    target:EmitSound("Hero_NagaSiren.Riptide.Cast")

    ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
    })
end
