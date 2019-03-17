

antimage_custom_mana_break = class({})


function antimage_custom_mana_break:GetIntrinsicModifierName()
    return "modifier_antimage_custom_mana_break"
end



LinkLuaModifier("modifier_antimage_custom_mana_break", "abilities/heroes/antimage_custom_mana_break.lua", LUA_MODIFIER_MOTION_NONE)

modifier_antimage_custom_mana_break = class({})


function modifier_antimage_custom_mana_break:IsHidden()
    return true
end


if IsServer() then
    function modifier_antimage_custom_mana_break:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end


    function modifier_antimage_custom_mana_break:OnAttackLanded(keys)
        local ability = self:GetAbility()
        local attacker = keys.attacker

        if attacker == self:GetParent() then
            local target = keys.target

            if attacker:PassivesDisabled() or target:IsAttackImmune() or target:GetMaxMana() == 0 then
                return nil
            end

            target:EmitSound("Hero_Antimage.ManaBreak")

            local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            local mana_per_hit = ability:GetSpecialValueFor("mana_per_hit")
            local mana_pct = ability:GetSpecialValueFor("mana_pct") * 0.01

            local target_mana = target:GetMana()
            local mana_loss = math.min(mana_per_hit + (mana_pct * target_mana), target_mana)

            target:ReduceMana(mana_loss)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, mana_loss, nil)

			ApplyDamage({
				ability = ability,
				attacker = attacker,
				damage = mana_loss * ability:GetSpecialValueFor("mana_burn_as_damage") * 0.01,
				damage_type = ability:GetAbilityDamageType(),
				victim = target
			})
        end
    end
end
