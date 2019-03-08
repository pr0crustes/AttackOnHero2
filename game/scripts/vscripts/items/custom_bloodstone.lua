


item_custom_bloodstone = class({})

function item_custom_bloodstone:GetIntrinsicModifierName()
    return "modifier_item_custom_bloodstone"
end



item_dark_bloodstone = class(item_custom_bloodstone)


function item_dark_bloodstone:GetManaCost(iLevel)
    local caster = self:GetCaster()
    if caster then
        return caster:GetMaxMana() * self:GetSpecialValueFor("max_mana_cost") * 0.01
    end
end


if IsServer() then
    function item_dark_bloodstone:OnSpellStart()
        local caster = self:GetCaster()
        caster:Heal(caster:GetMaxMana() * self:GetSpecialValueFor("max_mana_cost") * 0.01, caster)

        caster:EmitSound("DOTA_Item.Bloodstone.Cast")

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect, 1, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect, 2, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect)
    end
end



LinkLuaModifier("modifier_item_custom_bloodstone", "items/custom_bloodstone.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_custom_bloodstone = class({})


function modifier_item_custom_bloodstone:IsHidden()
    return true
end


function modifier_item_custom_bloodstone:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_bloodstone:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end


function modifier_item_custom_bloodstone:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end


function modifier_item_custom_bloodstone:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end


function modifier_item_custom_bloodstone:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end


function modifier_item_custom_bloodstone:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end
