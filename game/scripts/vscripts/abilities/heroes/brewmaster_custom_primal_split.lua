require("lib/my")
require("lib/illusion")


LinkLuaModifier("modifier_brewmaster_custom_primal_split", "abilities/heroes/brewmaster_custom_primal_split.lua", LUA_MODIFIER_MOTION_NONE)


local modifier_split = "modifier_brewmaster_custom_primal_split"

local spirit_earth = "npc_dota_brewmaster_earth_3"
local spirit_storm = "npc_dota_brewmaster_storm_3"
local spirit_fire = "npc_dota_brewmaster_fire_3"


if IsServer() then
    function max_abilities(illusion)
        for slot = 0, 15 do
            local ability = illusion:GetAbilityByIndex(slot)
            if ability ~= nil then
                ability:SetLevel(ability:GetMaxLevel())
            end
        end
    end


    function create_spirit(caster, ability, unit_name)
        local spawnPos = caster:GetAbsOrigin() + RandomVector(250)

        local illusion = CreateUnitByName(unit_name, spawnPos, true, caster, nil, caster:GetTeamNumber())
        illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
        illusion:SetMaxHealth(caster:GetMaxHealth())
        illusion:SetHealth(caster:GetHealth())

        max_abilities(illusion)
        disable_inventory(illusion)

        local duration = ability:GetSpecialValueFor("duration")

        illusion:AddNewModifier(illusion, ability, modifier_split, {duration = duration})
        illusion:AddNewModifier(illusion, ability, "modifier_arc_warden_tempest_double", {})

        FindClearSpaceForUnit(illusion, spawnPos, true)

        caster:EmitSound("Hero_Brewmaster.PrimalSplit.Spawn")
    end


    function spawn_spirit_after_delay(caster, ability, unit_name, delay)
        Timers(
            delay,
            function()
                create_spirit(caster, ability, unit_name)
            end
        )
    end


    function cast_brewmaster_custom_primal_split(keys)
        local ability = keys.ability
        local caster = keys.caster
        local target = keys.target

        caster:EmitSound("Hero_Brewmaster.PrimalSplit.Cast")

        spawn_spirit_after_delay(caster, ability, spirit_earth, 0.1)
        spawn_spirit_after_delay(caster, ability, spirit_storm, 0.3)
        spawn_spirit_after_delay(caster, ability, spirit_fire, 0.5)
    end
end



modifier_brewmaster_custom_primal_split = class({})


function modifier_brewmaster_custom_primal_split:IsHidden()
    return true
end


if IsServer() then
    function modifier_brewmaster_custom_primal_split:OnDestroy()
        local parent = self:GetParent()
        if parent and parent:IsAlive() then
            kill_illusion(parent)
        end
        self:GetCaster():EmitSound("Hero_Brewmaster.PrimalSplit.Return")
    end


    function modifier_brewmaster_custom_primal_split:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_MIN_HEALTH,
        }
    end


    function modifier_brewmaster_custom_primal_split:OnTakeDamage(keys)
        local unit = keys.unit

        if unit == self:GetParent() and unit:GetHealth() <= 1 then
            kill_illusion(unit)
        end
    end


    function modifier_brewmaster_custom_primal_split:GetMinHealth(keys)
        return 1
    end
end
