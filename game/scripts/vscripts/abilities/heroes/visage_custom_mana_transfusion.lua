

visage_custom_mana_transfusion = class({})


if IsServer() then
    function visage_custom_mana_transfusion:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "modifier_visage_custom_mana_transfusion", {})
    end


    function visage_custom_mana_transfusion:OnChannelFinish(interrupted)
        local caster = self:GetCaster()
        caster:RemoveModifierByName("modifier_visage_custom_mana_transfusion")
    end
end



LinkLuaModifier("modifier_visage_custom_mana_transfusion", "abilities/heroes/visage_custom_mana_transfusion.lua", LUA_MODIFIER_MOTION_NONE)

modifier_visage_custom_mana_transfusion = class({})


if IsServer() then
    function modifier_visage_custom_mana_transfusion:OnCreated(keys)
        local ability = self:GetAbility()

        self.mana_per_sec = ability:GetSpecialValueFor("base_mana") + self:GetParent():GetManaRegen()

        self.ticks_per_sec = ability:GetSpecialValueFor("ticks_per_sec")
        self.tick_mana = self.mana_per_sec / self.ticks_per_sec

        self:StartIntervalThink(1 / self.ticks_per_sec)
    end


    function modifier_visage_custom_mana_transfusion:OnIntervalThink()
        local parent = self:GetParent()

        if parent:GetHealth() <= self.tick_mana then
            parent:Interrupt()
            parent:InterruptChannel()
            return
        end

        parent:ModifyHealth(parent:GetHealth() - self.tick_mana, self:GetAbility(), false, 0)

        parent:GiveMana(self.tick_mana)

        local particle = ParticleManager:CreateParticle("particles/custom/manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end
