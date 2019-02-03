require("lib/my")



local soul_stack_modifier = "modifier_nevermore_custom_necromastery_stack"
local requiem_name = "nevermore_custom_requiem"



function on_upgrade(keys)
    local caster = keys.caster
    local ability = keys.ability

    if not caster:HasModifier(soul_stack_modifier) then
        ability:ApplyDataDrivenModifier(caster, caster, soul_stack_modifier, {})
        caster:SetModifierStackCount(soul_stack_modifier, caster, 1)
    end
end


function on_attack_landed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local max_souls = ability_value(ability, value_if_scepter(caster, "necromastery_max_souls_scepter", "necromastery_max_souls"))

    local talent = caster:FindAbilityByName("nevermore_custom_bonus_unique_1")
    if talent and talent:GetLevel() > 0 then
        max_souls = max_souls + talent:GetSpecialValueFor("value")
    end

    local new_souls = caster:GetModifierStackCount(soul_stack_modifier, caster) + 1

    if new_souls <= max_souls then
        caster:SetModifierStackCount(soul_stack_modifier, caster, new_souls)

        ProjectileManager:CreateTrackingProjectile({
            Target = caster,
            Source = target,
            Ability = ability,
            EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
            bDodgeable = false,
            bProvidesVision = false,
            iMoveSpeed = 1500,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        })
    end
end



function on_death(keys)
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.unit

    if caster == unit then

        local release = ability_value(ability, "necromastery_soul_release")

        if caster:HasModifier(soul_stack_modifier) then
            local stack_count = caster:GetModifierStackCount(soul_stack_modifier, caster)

            local new_stack_count = math.ceil(stack_count * release)

            caster:SetModifierStackCount(soul_stack_modifier, caster, new_stack_count)
        end

        if caster:HasAbility(requiem_name) then
            local requiem = caster:FindAbilityByName(requiem_name)
            if requiem and requiem:GetLevel() >= 1 then
                requiem:OnSpellStart()
            end
        end
    end
end


