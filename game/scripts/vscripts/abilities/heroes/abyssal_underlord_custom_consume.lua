

abyssal_underlord_custom_consume = class({})


if IsServer() then
    function abyssal_underlord_custom_consume:OnSpellStart()
        local target = self:GetCursorTarget()
        local caster = self:GetCaster()

        caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice.Start")

        target:AddNewModifier(caster, self, "modifier_abyssal_underlord_custom_consume", {})
    end
end



LinkLuaModifier("modifier_abyssal_underlord_custom_consume", "abilities/heroes/abyssal_underlord_custom_consume.lua", LUA_MODIFIER_MOTION_NONE)

modifier_abyssal_underlord_custom_consume = class({})


function modifier_abyssal_underlord_custom_consume:IsDebuff()
    return true
end


function modifier_abyssal_underlord_custom_consume:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf"
end


function modifier_abyssal_underlord_custom_consume:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then
    function modifier_abyssal_underlord_custom_consume:OnCreated(keys)
        self.start_pos = self:GetParent():GetAbsOrigin()

        local caster = self:GetCaster()
        self.stats_sum = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect()

        local ability = self:GetAbility()
        self.stats_multiplier = ability:GetSpecialValueFor("stats_multiplier")
        self.tick_interval = ability:GetSpecialValueFor("tick_interval")
        self.ticks = ability:GetSpecialValueFor("ticks")
        self.distance_break = ability:GetSpecialValueFor("distance_break")

        self.damage = self.stats_multiplier * self.stats_sum

        self.tick_count = 0

        self:StartIntervalThink(self.tick_interval)
    end


    function modifier_abyssal_underlord_custom_consume:OnIntervalThink()
        local parent = self:GetParent()

        if self.tick_count >= self.ticks or (parent:GetAbsOrigin() - self.start_pos):Length2D() > self.distance_break then
            self:Destroy()
            return
        end

        parent:EmitSound("Hero_AbyssalUnderlord.PitOfMalice")

        self.tick_count = self.tick_count + 1

        ApplyDamage({
            ability = self:GetAbility(),
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            victim = parent
        })
    end
end
