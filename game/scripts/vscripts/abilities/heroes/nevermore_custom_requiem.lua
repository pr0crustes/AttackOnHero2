require("lib/my")
require("lib/timers")



local SOUL_STACK_MODIFIER = "modifier_nevermore_custom_necromastery_stack"


nevermore_custom_requiem = class({})


if IsServer() then
	function nevermore_custom_requiem:RequiemLineEffect(position, velocity, duration)
		local caster = self:GetCaster()
		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(effect, 0, position)
		ParticleManager:SetParticleControl(effect, 1, velocity)
		ParticleManager:SetParticleControl(effect, 2, Vector(0, duration, 0))
		ParticleManager:ReleaseParticleIndex(effect)
	end


	function nevermore_custom_requiem:LaunchRequiemLine(start_pos, travel_distance, start_radius, end_radius, velocity, travel_time, isScepter)
		ProjectileManager:CreateLinearProjectile({
			Ability = self,
			EffectName = nil,
			vSpawnOrigin = start_pos,
			fDistance = travel_distance,
			fStartRadius = start_radius,
			fEndRadius = end_radius,
			Source = self:GetCaster(),
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = false,
			vVelocity = velocity,
			bProvidesVision = false,
			ExtraData = {is_scepter = isScepter}
		})
	
		self:RequiemLineEffect(start_pos, velocity, travel_time)
	end


	function nevermore_custom_requiem:CreateRequiemLine(end_pos)
		local lines_end_width = self:GetSpecialValueFor("lines_end_width")
		local lines_starting_width = self:GetSpecialValueFor("lines_starting_width")
		local lines_travel_speed = self:GetSpecialValueFor("lines_travel_speed")
		local travel_distance = self:GetSpecialValueFor("travel_distance")
		
		local travel_time = travel_distance / lines_travel_speed
		
		local caster = self:GetCaster()
		local caster_pos = caster:GetAbsOrigin()
	
		local velocity = (end_pos - caster_pos):Normalized() * lines_travel_speed

		self:LaunchRequiemLine(caster_pos, travel_distance, lines_starting_width, lines_end_width, velocity, travel_time, false)
	
		if caster:IsAlive() and caster:HasScepter() then
			Timers:CreateTimer(
				travel_time,
				function()
					local back_velocity = (caster_pos - end_pos):Normalized() * lines_travel_speed

					self:LaunchRequiemLine(end_pos, travel_distance, lines_end_width, lines_starting_width, back_velocity, travel_time, true)
				end
			)
		end
	end


	function nevermore_custom_requiem:OnSpellStart()
		local souls_per_line = self:GetSpecialValueFor("souls_per_line")
		local travel_distance = self:GetSpecialValueFor("travel_distance")
	
		local caster = self:GetCaster()

		caster:EmitSound("Hero_Nevermore.RequiemOfSouls")

		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(effect)

		if caster:HasModifier(SOUL_STACK_MODIFIER) then
			local stacks = caster:GetModifierStackCount(SOUL_STACK_MODIFIER, caster)
			local line_count = math.floor(stacks / souls_per_line)
			
			local caster_pos = caster:GetAbsOrigin()
			local line_pos = caster_pos + caster:GetForwardVector() * travel_distance
	
			self:CreateRequiemLine(line_pos)
	
			local rotation_rate = 360 / line_count  -- spaced around all circle.
			for i = 1, line_count - 1 do
				line_pos = RotatePosition(caster_pos, QAngle(0, rotation_rate, 0), line_pos)
	
				self:CreateRequiemLine(line_pos)
			end
		end
	end


	function nevermore_custom_requiem:OnProjectileHit_ExtraData(target, location, extra)
		if target then
			local caster = self:GetCaster()
			local damage = self:GetSpecialValueFor("damage")
			local is_scepter = extra.is_scepter and extra.is_scepter ~= 0

			if is_scepter then
				damage = damage * self:GetSpecialValueFor("damage_pct_scepter") * 0.01
			end

			ApplyDamage({
				ability = self,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				victim = target
			})
		end
	end
end
