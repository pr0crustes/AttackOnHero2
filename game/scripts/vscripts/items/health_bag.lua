require("lib/my")


LinkLuaModifier("modifier_health_bag", "items/health_bag.lua", LUA_MODIFIER_MOTION_NONE)



function health_bag_cast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local duration = ability_value(ability, "duration")

    target:AddNewModifier(caster, ability, "modifier_health_bag", {duration = duration})
end



modifier_health_bag = class({})


function modifier_health_bag:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_heal.vpcf"
end


function modifier_health_bag:GetTexture()
    return "item_health_bag"
end


function modifier_health_bag:OnCreated()
    local ability = self:GetAbility()
    local think_interval = ability_value(ability, "heal_interval")

    self:StartIntervalThink(think_interval)
end


function modifier_health_bag:OnIntervalThink()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    local base_heal = ability_value(ability, "base_heal")
    local heal_pct = ability_value(ability, "heal_pct")

    local heal_amount = base_heal + (parent:GetMaxHealth() * heal_pct * 0.01)
    parent:Heal(heal_amount, ability)
end
