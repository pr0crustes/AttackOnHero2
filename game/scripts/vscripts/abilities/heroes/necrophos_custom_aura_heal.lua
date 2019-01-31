require("lib/my")



function cast_aura_heal(keys)
    local caster = keys.caster
    local ability = keys.ability

    local radius = ability_value(ability, "radius")
    local health_pct = ability_value(ability, "health_pct")

    local health = caster:GetHealth()

    local heal = health * health_pct * 0.01

    local newHealth = health - heal

    caster:SetHealth(newHealth)

	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        if unit ~= caster then
            unit:Heal(heal, ability)
        end
	end
end
