require("lib/timers")
require("lib/my")


function cast_death_skull(keys)
	local ability = keys.ability
	local caster = keys.caster

	local projectile_width = ability_value(ability, "width") 
	local projectile_velocity = ability_value(ability, "velocity")
	local interval = ability_value(ability, "interval")

	if caster:HasScepter() then
		local aps = 1 / caster:GetAttacksPerSecond()
		interval = math.min(interval, aps)
	end

	local projectileTable = {
		Ability = ability,
		EffectName = "particles/custom/death_attacker_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = ability:GetCastRange(),
		fStartRadius = projectile_width,			
		fEndRadius = projectile_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = caster:GetForwardVector() * projectile_velocity,
		bProvidesVision = true,
		iVisionRadius = 200,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	
	Timers:CreateTimer(
		function()
			if ability:IsChanneling() then
				ProjectileManager:CreateLinearProjectile(projectileTable)

				local talent = caster:FindAbilityByName("witch_doctor_custom_bonus_unique_1")

				if talent and talent:GetLevel() > 0 then
					Timers:CreateTimer(
						0.1,
						function()
							ProjectileManager:CreateLinearProjectile(projectileTable)
							return nil
						end
					)
				end

				caster:EmitSound("Hero_WitchDoctor_Ward.Attack")
				return interval
			end
			return nil
		end
	)
end


function on_hit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = ability_value(ability, "damage")

	ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
	})
end



