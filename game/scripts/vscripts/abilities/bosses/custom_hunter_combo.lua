



function cast_custom_hunter_combo(keys)
    local caster = keys.caster
    local ability = keys.ability

    local shuriken = caster:FindAbilityByName("custom_shuriken_toss")
    local track = caster:FindAbilityByName("custom_track")

    if track and shuriken then
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    
        for _, unit in ipairs(units) do
            if unit:IsHero() then
                caster:SetCursorCastTarget(unit)
                track:OnSpellStart()

                unit:EmitSound("Hero_BountyHunter.Target")
            end
        end

        for _, unit in ipairs(units) do
            caster:SetCursorCastTarget(unit)
            shuriken:OnSpellStart()

            caster:EmitSound("Hero_BountyHunter.Shuriken")
        end
    end
end
