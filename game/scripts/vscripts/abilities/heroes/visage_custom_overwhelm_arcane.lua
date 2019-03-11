

visage_custom_overwhelm_arcane = class({})


function visage_custom_overwhelm_arcane:GetIntrinsicModifierName()
    return "modifier_visage_custom_overwhelm_arcane"
end



LinkLuaModifier("modifier_visage_custom_overwhelm_arcane", "abilities/heroes/visage_custom_overwhelm_arcane.lua", LUA_MODIFIER_MOTION_NONE)

modifier_visage_custom_overwhelm_arcane = class({})

function modifier_visage_custom_overwhelm_arcane:IsHidden()
    return true
end


if IsServer() then
    function modifier_visage_custom_overwhelm_arcane:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end


    function modifier_visage_custom_overwhelm_arcane:OnAttackLanded(keys)
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
    
        if attacker == self:GetParent() and attacker:IsOpposingTeam(target:GetTeam()) then 
            local int_multiplier = ability:GetSpecialValueFor("int_multiplier")
            local damage_as_mana = ability:GetSpecialValueFor("damage_as_mana")
        
            local damage = attacker:GetIntellect() * int_multiplier
        
            Timers:CreateTimer(
                0.1,
                function()
                    local damage_dealt = ApplyDamage({
                        victim = target,
                        attacker = attacker,
                        ability = ability,
                        damage_type = ability:GetAbilityDamageType(),
                        damage = damage,
                    })

                    if damage_dealt and damage_dealt > 0 then
                        attacker:GiveMana(damage_dealt * damage_as_mana * 0.01)

                        local particle = ParticleManager:CreateParticle("particles/custom/manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
                        ParticleManager:ReleaseParticleIndex(particle)
                    end
                    return nil
                end
            )
        end
    end
end
