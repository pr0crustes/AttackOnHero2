require("lib/my")
require("lib/timers")



function cast_aura_heal(keys)
    local caster = keys.caster
    local ability = keys.ability

    local radius = ability:GetSpecialValueFor("radius")
    local health_pct = ability:GetSpecialValueFor("health_pct")

    local health = caster:GetHealth()

    local heal = health * health_pct * 0.01

    local newHealth = health - heal

    caster:SetHealth(newHealth)

    caster:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")

	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        if unit ~= caster then

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)

            Timers:CreateTimer(
                1.5,
                function()
                    if unit:IsAlive() then
                        unit:EmitSound("Hero_Necrolyte.ReapersScythe.Target")
                        unit:Heal(heal, ability)
                    end
                end
            )
        end
	end
end
