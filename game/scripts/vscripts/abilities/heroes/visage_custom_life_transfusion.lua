

visage_custom_life_transfusion = class({})


if IsServer() then
    function visage_custom_life_transfusion:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "modifier_visage_custom_life_transfusion", {})
    end


    function visage_custom_life_transfusion:OnChannelFinish(interrupted)
        local caster = self:GetCaster()
        caster:RemoveModifierByName("modifier_visage_custom_life_transfusion")
    end
end



LinkLuaModifier("modifier_visage_custom_life_transfusion", "abilities/heroes/visage_custom_life_transfusion.lua", LUA_MODIFIER_MOTION_NONE)

modifier_visage_custom_life_transfusion = class({})


if IsServer() then
    function modifier_visage_custom_life_transfusion:OnCreated(keys)
        local ability = self:GetAbility()

        self.life_per_sec = ability:GetSpecialValueFor("base_life") + self:GetParent():GetHealthRegen()

        self.ticks_per_sec = ability:GetSpecialValueFor("ticks_per_sec")
        self.tick_life = self.life_per_sec / self.ticks_per_sec

        self:StartIntervalThink(1 / self.ticks_per_sec)
    end


    function modifier_visage_custom_life_transfusion:OnIntervalThink()
        local parent = self:GetParent()

        if parent:GetMana() < self.tick_life then
            parent:Interrupt()
            parent:InterruptChannel()
            return
        end

        parent:SpendMana(self.tick_life, self:GetAbility())

        parent:Heal(self.tick_life, parent)

        local particle = ParticleManager:CreateParticle("particles/custom/treantheal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end
