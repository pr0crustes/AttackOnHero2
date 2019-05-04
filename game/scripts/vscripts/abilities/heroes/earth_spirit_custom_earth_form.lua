

earth_spirit_custom_earth_form = class({})


function earth_spirit_custom_earth_form:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_earth_spirit_custom_earth_form", {
        duration = self:GetSpecialValueFor("duration")
    })

    caster:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Cast")
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_form", "abilities/heroes/earth_spirit_custom_earth_form.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_form = class({})


function modifier_earth_spirit_custom_earth_form:GetEffectName()
    return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
end


function modifier_earth_spirit_custom_earth_form:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_earth_spirit_custom_earth_form:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("str_bonus")
end


function modifier_earth_spirit_custom_earth_form:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("health_regen")
end


function modifier_earth_spirit_custom_earth_form:GetModifierModelScale()
    return self:GetAbility():GetSpecialValueFor("model_scale")
end
