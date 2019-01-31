require("lib/my")


function cast_energy_missile(keys)
	local ability = keys.ability
	local caster = keys.caster

	local projectile_velocity = ability_value(ability, "velocity")


	local projectileTable = {
		Ability = ability,
		EffectName = "particles/neutral_fx/satyr_hellcaller.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = ability:GetCastRange(),
		fStartRadius = 180,			
		fEndRadius = 200,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * projectile_velocity,
		bProvidesVision = true,
		iVisionRadius = 200,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	
	ProjectileManager:CreateLinearProjectile(projectileTable)
end


function on_hit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local base_damage = ability_value(ability, "base_damage")
	local int_mult = ability_value(ability, "int_mult")

	local talent = caster:FindAbilityByName("tinker_custom_bonus_unique_1")
	if talent and talent:GetLevel() > 0 then
		int_mult = int_mult + int_mult
	end

	local damage = base_damage + (int_mult * caster:GetIntellect())

	ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
	})
end



