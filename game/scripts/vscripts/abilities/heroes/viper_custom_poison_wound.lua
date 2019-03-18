require("lib/my")


LinkLuaModifier("modifier_viper_custom_poison_wound", "abilities/heroes/viper_custom_poison_wound.lua", LUA_MODIFIER_MOTION_NONE)


function cast_poison_wound(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local duration = ability:GetSpecialValueFor("duration")

    target:AddNewModifier(caster, ability, "modifier_viper_custom_poison_wound", {duration = duration})

    caster:PerformAttack(target, true, true, true, false, true, false, false)
end



modifier_viper_custom_poison_wound = class({})


function modifier_viper_custom_poison_wound:GetTexture()
    return "viper_nethertoxin"
end


if IsServer() then
    function modifier_viper_custom_poison_wound:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end


    function modifier_viper_custom_poison_wound:OnCreated(keys)
        self.total_damage = 0.0
    end


    function modifier_viper_custom_poison_wound:OnDestroy()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local damage = self.total_damage * ability:GetSpecialValueFor("damage_percentage") * 0.01
    
        ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })
    end


    function modifier_viper_custom_poison_wound:OnTakeDamage(keys)
        self.total_damage = self.total_damage + keys.damage
    end
end
