require("lib/my")
require("lib/timers")



function cast_furion_custom_nature_heal(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    
    if caster == target then  -- cant target yourself.
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        ability:EndCooldown()
        return
    end

    local interval = ability_value(ability, "interval")

	Timers:CreateTimer(
		function()
            if ability:IsChanneling() then
                local health_regen_amount = caster:GetHealthRegen() * interval * 2
                local mana_regen_amount = caster:GetManaRegen() * interval * 2
                
                if target:IsAlive() and caster:GetHealth() > health_regen_amount and caster:GetMana() > mana_regen_amount then

                    -- For visual
                    ProjectileManager:CreateTrackingProjectile({
                        Ability = ability,
                        Target = target,
                        Source = caster,
                        EffectName = "particles/units/heroes/hero_furion/furion_wrath_of_nature_trail.vpcf",
                        iMoveSpeed = caster:GetRangeToUnit(target) / interval,
                        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                        bDodgeable = false,
                        flExpireTime = GameRules:GetGameTime() + (interval * 3),
                    })

                    caster:EmitSound("Hero_Furion.WrathOfNature_Damage")
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
                    caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

                    caster:SetHealth(caster:GetHealth() - health_regen_amount)
                    caster:SpendMana(mana_regen_amount, ability)
                
                    target:SetHealth(target:GetHealth() + health_regen_amount)
                    target:SetMana(target:GetMana() + mana_regen_amount)
                    
                    return interval
                end
                caster:Interrupt()
                caster:InterruptChannel()
            end
			return nil
		end
    )

end
