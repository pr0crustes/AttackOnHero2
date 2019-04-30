

earth_spirit_custom_earth_form = class({})


function earth_spirit_custom_earth_form:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_earth_spirit_custom_earth_form", {
        duration = self:GetSpecialValueFor("duration")
    })
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_form", "abilities/heroes/earth_spirit_custom_earth_form.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_form = class({})


function modifier_earth_spirit_custom_earth_form:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_earth_spirit_custom_earth_form:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("health_regen")
end


function modifier_earth_spirit_custom_earth_form:GetModifierModelScale()
    return self:GetAbility():GetSpecialValueFor("model_scale")
end


if IsServer() then
    function modifier_earth_spirit_custom_earth_form:OnCreated()
        self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("time_for_earth_point"))
    end


    function modifier_earth_spirit_custom_earth_form:OnIntervalThink()
        local spell = self:GetParent():FindAbilityByName("earth_spirit_custom_earth_walking")
        if spell and spell:GetLevel() > 0 then
            spell:AddEarthPoint()
        end
    end
end