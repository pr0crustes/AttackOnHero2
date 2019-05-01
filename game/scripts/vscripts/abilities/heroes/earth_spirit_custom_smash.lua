require("lib/timers")



earth_spirit_custom_smash = class({})


if IsServer() then
    function earth_spirit_custom_smash:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        local caster_pos = caster:GetAbsOrigin()
        local target_pos = target:GetAbsOrigin()

        local blink_pos = target_pos + RandomVector(100)

		caster:SetAbsOrigin(target_pos)
		Timers:CreateTimer(FrameTime(), function()
			FindClearSpaceForUnit(caster, blink_pos, true)
		end)

		caster:SetForwardVector((target_pos - caster_pos):Normalized())
        ProjectileManager:ProjectileDodge(caster)

        caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Cast")

        local base_damage = self:GetSpecialValueFor("base_damage")
        local str_damage = self:GetSpecialValueFor("str_as_damage") * 0.01 * caster:GetStrength()

        local damage = base_damage + str_damage

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            victim = target
        })

        ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

        caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
    end
end

