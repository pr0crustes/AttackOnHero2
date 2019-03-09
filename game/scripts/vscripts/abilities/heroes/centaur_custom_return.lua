

centaur_custom_return = class({})


function centaur_custom_return:GetIntrinsicModifierName()
    return "modifier_centaur_custom_return"
end



LinkLuaModifier("modifier_centaur_custom_return", "abilities/heroes/centaur_custom_return.lua", LUA_MODIFIER_MOTION_NONE)

modifier_centaur_custom_return = class({})


function modifier_centaur_custom_return:IsHidden()
    return true
end


if IsServer() then
    function modifier_centaur_custom_return:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE
        }
    end


    function modifier_centaur_custom_return:OnTakeDamage(keys)
        local unit = keys.unit
        local attacker = keys.attacker

        if unit == self:GetParent() and unit ~= attacker then
            local ability = self:GetAbility()

            local base_damage = ability:GetSpecialValueFor("base_damage")
            local str_bonus = ability:GetSpecialValueFor("str_bonus")

            local damage = base_damage + (unit:GetStrength() * str_bonus * 0.01)

			ApplyDamage({
				ability = ability,
				attacker = unit,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				victim = attacker
            })
            

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
end

