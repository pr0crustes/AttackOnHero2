require("lib/my")


modifier_enfeeble = "modifier_bane_custom_enfeeble"


bane_custom_brain_sap = class({})


if IsServer() then
    function bane_custom_brain_sap:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        local damage = self:GetSpecialValueFor("damage") + talent_value(caster, "bane_custom_bonus_unique_1")
        local enfeeble_damage = self:GetSpecialValueFor("enfeeble_damage")

        while target:HasModifier(modifier_enfeeble) do
            damage = damage + enfeeble_damage
            target:RemoveModifierByName(modifier_enfeeble)
        end

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
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

