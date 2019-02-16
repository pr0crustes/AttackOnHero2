require("lib/my")


LinkLuaModifier("modifier_custom_rotational_flames", "abilities/bosses/custom_rotational_flames.lua", LUA_MODIFIER_MOTION_NONE)



custom_rotational_flames = class({})



if IsServer() then
	function custom_rotational_flames:GetIntrinsicModifierName()
		return "modifier_custom_rotational_flames"
	end


	function custom_rotational_flames:OnProjectileHit(target)
		local caster = self:GetCaster()
		if target then
			local hp_damage_max = self:GetSpecialValueFor("hp_damage_max")
			local hp_damage_min = self:GetSpecialValueFor("hp_damage_min")

			local range = self:GetSpecialValueFor("range")

			local hp_damage = (caster:GetRangeToUnit(target) / range) * hp_damage_max
			hp_damage = clamp_value(hp_damage, hp_damage_min, hp_damage_max)

			local damage = target:GetHealth() * hp_damage * 0.01

			ApplyDamage({
				attacker = self:GetCaster(),
				victim = target,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self
			})

			target:EmitSound("Hero_Rubick.SpellSteal.Target")
		end
    end
end



modifier_custom_rotational_flames = class({})



function modifier_custom_rotational_flames:IsHidden()
    return true
end


if IsServer() then
	function modifier_custom_rotational_flames:SetIntervalThink()
		local parent = self:GetParent()

		local parent_hp_pct = parent:GetHealthPercent()

		local interval = (parent_hp_pct / self.use_at_hp) * self.interval_max

		local claped = clamp_value(interval, self.interval_min, self.interval_max)

		self:StartIntervalThink(claped)
	end


    function modifier_custom_rotational_flames:OnCreated()
		local ability = self:GetAbility()

		self.use_at_hp = ability:GetSpecialValueFor("use_at_hp")
		self.range = ability:GetSpecialValueFor("range")
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.projectile_duration = self.range / self.velocity
		self.interval_max = ability:GetSpecialValueFor("interval_max")
		self.interval_min = ability:GetSpecialValueFor("interval_min")

		self.rotate = ability:GetSpecialValueFor("rotate")
		self.last_rotate = self.rotate

        self:SetIntervalThink()
    end


    function modifier_custom_rotational_flames:OnIntervalThink()
        local ability = self:GetAbility()
		local parent = self:GetParent()
		
		if parent:IsAlive() and parent:GetHealthPercent() <= self.use_at_hp and not parent:HasModifier("modifier_juggernaut_omnislash") then

			local parent_pos = parent:GetAbsOrigin()

			local line_pos = parent_pos + parent:GetForwardVector() * self.range

			local launch_line = RotatePosition(parent_pos, QAngle(0, self.last_rotate, 0), line_pos)

			self.last_rotate = self.last_rotate + self.rotate

			self:Shoot(launch_line)
		end
		self:SetIntervalThink()
	end
	

	function modifier_custom_rotational_flames:Shoot(line_pos)
		local parent = self:GetParent()
		local parent_pos = parent:GetAbsOrigin()

		local velocity = (line_pos - parent_pos):Normalized() * self.velocity

		ProjectileManager:CreateLinearProjectile({
			Ability = self:GetAbility(),
			EffectName = "particles/custom/rotational_fire.vpcf",
			vSpawnOrigin = parent_pos,
			fDistance = self.range,
			fStartRadius = 200,
			fEndRadius = 200,
			Source = parent,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = false,
			vVelocity = velocity,
			bProvidesVision = false,
			fExpireTime = GameRules:GetGameTime() + self.projectile_duration - 0.1,
		})
	end
end

