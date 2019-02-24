
modifier_enfeeble = "modifier_bane_custom_enfeeble"


bane_custom_brain_sap = class({})


if IsServer() then
    function bane_custom_brain_sap:DamageTypeForTarget(target)
        if target:HasModifier(modifier_enfeeble) then
            target:RemoveModifierByName(modifier_enfeeble)
            return DAMAGE_TYPE_PURE
        end
        return self:GetAbilityDamageType()
    end

    function bane_custom_brain_sap:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = self:GetSpecialValueFor("damage"),
            damage_type = self:DamageTypeForTarget(target),
            victim = target
        })

        caster:Heal(self:GetSpecialValueFor("heal"), caster)
        
        caster:EmitSound("Hero_Bane.BrainSap")
        target:EmitSound("Hero_Bane.BrainSap.Target")

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(effect, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(effect)
    end
end


function bane_custom_brain_sap:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end

