require("lib/my")



function cast_jinada(keys)
    local ability = keys.ability
    local caster = keys.caster

    if ability:GetCooldownTimeRemaining() > 0 then
        return
    end

    caster:EmitSound("Hero_BountyHunter.Jinada")

    local gold_amount = ability:GetSpecialValueFor("gold_bonus")

    PlayerResource:ModifyGold(caster:GetPlayerID(), gold_amount, false, DOTA_ModifyGold_Unspecified)

    local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

    ability:StartCooldown(cooldown)
end
