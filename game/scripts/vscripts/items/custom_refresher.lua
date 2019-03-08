require("lib/my")
require("lib/refresh")


item_custom_refresher = class({})


function item_custom_refresher:OnSpellStart()
    local caster = self:GetCaster()

    local min_cooldown = self:GetSpecialValueFor("min_cooldown")
    local max_cooldown = self:GetSpecialValueFor("max_cooldown")

    if not caster:IsTempestDouble() then

        caster:EmitSound("DOTA_Item.Refresher.Activate")

        local fx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)

        refresh_abilities(caster, {})
        refresh_items(caster, {})

        local cooldowns = get_all_cooldowns(caster)

        table.sort(cooldowns)

        local highest_cd = cooldowns[#cooldowns]

        local refresher_cd = clamp_value(highest_cd, min_cooldown, max_cooldown)

        self:StartCooldown(refresher_cd)
    end
end


function item_custom_refresher:GetIntrinsicModifierName()
    return "modifier_item_custom_refresher"
end



LinkLuaModifier("modifier_item_custom_refresher", "items/custom_refresher.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_custom_refresher = class({})


function modifier_item_custom_refresher:IsHidden()
    return true
end


function modifier_item_custom_refresher:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_refresher:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end


function modifier_item_custom_refresher:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end


function modifier_item_custom_refresher:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
