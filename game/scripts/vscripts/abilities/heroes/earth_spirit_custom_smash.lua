require("lib/timers")



earth_spirit_custom_smash = class({})


if IsServer() then
    function earth_spirit_custom_smash:GetEarthEssenceCount()
        local spell = self:GetCaster():FindAbilityByName("earth_spirit_custom_earth_essence")
        if spell then
            return spell:GetCount()
        end
        return 0
    end


    function earth_spirit_custom_smash:CalculateDamage()
        local base_damage = self:GetSpecialValueFor("base_damage")
        local str_damage = self:GetSpecialValueFor("str_as_damage") * 0.01 * self:GetCaster():GetStrength()

        local total = base_damage + str_damage

        local mult = self:GetEarthEssenceCount() * self:GetSpecialValueFor("earth_essence_mult") * 0.01

        return total * (mult + 1)
    end


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

        local damage = self:CalculateDamage()

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

