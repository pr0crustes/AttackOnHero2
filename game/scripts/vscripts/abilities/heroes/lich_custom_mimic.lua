require("lib/my")
require("lib/timers")
require("lib/illusion")



lich_custom_mimic = class({})


function lich_custom_mimic:IsStealable()
    return false
end


function lich_custom_mimic:GetIntrinsicModifierName()
    return "modifier_lich_custom_mimic"
end


if IsServer() then
    function lich_custom_mimic:OnSpellStart()
        local caster = self:GetCaster()
        local spawn_pos = caster:GetAbsOrigin() + RandomVector(100)

        if self.clone and self.clone:IsAlive() then
            self.clone:Kill(self, caster)
            UTIL_Remove(self.clone)
        end

        CreateUnitByNameAsync(
            caster:GetUnitName(),
            spawn_pos,
            true,
            caster,
            nil,
            caster:GetTeamNumber(),
            function(clone)
                self.clone = clone

                copy_level(caster, clone)
                disable_inventory(clone)

                clone:EmitSound("Hero_Lich.SinisterGaze.Cast")

                clone:SetModelScale(0.5)

                clone:AddNewModifier(clone, self, "modifier_lich_custom_mimic_unit", {})
            end
        )
    end
end



LinkLuaModifier("modifier_lich_custom_mimic", "abilities/heroes/lich_custom_mimic.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lich_custom_mimic = class({})


function modifier_lich_custom_mimic:IsHidden()
    return true
end


if IsServer() then
    function modifier_lich_custom_mimic:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
    end


    function modifier_lich_custom_mimic:OnAbilityFullyCast(keys)
        local unit = keys.unit
        local ability = self:GetAbility()
        local used_ability = keys.ability

        if unit == self:GetCaster() and used_ability ~= ability and not used_ability:IsItem() then
            local clone = ability.clone

            if clone then
                if CalcDistanceBetweenEntityOBB(clone, unit) > ability:GetSpecialValueFor("max_distance") then
                    return nil
                end

                local used_ability_name = used_ability:GetName()
                local unit_ability = clone:FindAbilityByName(used_ability_name)

                if not unit_ability then
                    unit_ability = clone:AddAbility(used_ability_name)
                    unit_ability:SetStolen(true)
                    unit_ability:SetHidden(true)
                end

                unit_ability:SetLevel(used_ability:GetLevel())

                if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
                    clone:SetCursorCastTarget(keys.target)
                elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                    clone:SetCursorPosition(used_ability:GetCursorPosition())
                else
                    clone:SetCursorTargetingNothing(true)
                end

                Timers:CreateTimer(
                    ability:GetSpecialValueFor("delay"),
                    function()
                        if clone
                            and not clone:IsNull()
                            and unit_ability
                            and not unit_ability:IsNull() then

                            unit_ability:OnSpellStart()

                            local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, clone)
                            ParticleManager:SetParticleControl(particle, 3, Vector(100, 0, 0))
                            ParticleManager:ReleaseParticleIndex(particle)
                        end
                    end
                )
            end
        end
    end
end



LinkLuaModifier("modifier_lich_custom_mimic_unit", "abilities/heroes/lich_custom_mimic.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lich_custom_mimic_unit = class({})


function modifier_lich_custom_mimic_unit:IsHidden()
    return true
end


function modifier_lich_custom_mimic_unit:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true
    }
end
