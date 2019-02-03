require("lib/my")
require("lib/refresh")



function refresh(keys)
    local caster = keys.caster
    local ability = keys.ability

    local min_cooldown = ability:GetSpecialValueFor("min_cooldown")
    local max_cooldown = ability:GetSpecialValueFor("max_cooldown")

    if not caster:IsTempestDouble() then

        caster:EmitSound("DOTA_Item.Refresher.Activate")

        local fx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

        refresh_abilities(caster, {})
        refresh_items(caster, {})

        local cooldowns = get_all_cooldowns(caster)

        table.sort(cooldowns)

        local highest_cd = cooldowns[#cooldowns]

        local refresher_cd = clamp_value(highest_cd, min_cooldown, max_cooldown)

        ability:StartCooldown(refresher_cd)
    end
end

