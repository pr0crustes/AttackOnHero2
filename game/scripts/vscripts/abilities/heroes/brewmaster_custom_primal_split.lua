require("lib/my")
require("lib/illusion")


LinkLuaModifier("modifier_brewmaster_custom_primal_split", "abilities/heroes/brewmaster_custom_primal_split.lua", LUA_MODIFIER_MOTION_NONE)


local spirit_earth = "npc_dota_brewmaster_earth_3"
local spirit_storm = "npc_dota_brewmaster_storm_3"
local spirit_fire = "npc_dota_brewmaster_fire_3"



brewmaster_custom_primal_split = class({})


function brewmaster_custom_primal_split:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end


if IsServer() then
    function brewmaster_custom_primal_split:OnSpellStart()
        local caster = self:GetCaster()

        caster:EmitSound("Hero_Brewmaster.PrimalSplit.Cast")

        self:CreateSpiritAsync(spirit_earth, 0.1)
        self:CreateSpiritAsync(spirit_storm, 0.3)
        self:CreateSpiritAsync(spirit_fire, 0.5)
    end


    function brewmaster_custom_primal_split:CreateSpiritAsync(name, delay)
        Timers(
            delay,
            function()
                self:CreateSpirit(name)
            end
        )
    end


    function brewmaster_custom_primal_split:LevelAbilities(unit)
        local caster = self:GetCaster()

        for slot = 0, 15 do
            local unitAbility = unit:GetAbilityByIndex(slot)
            if unitAbility then
                local level = self:GetLevel()
                
                local casterAbility = caster:FindAbilityByName(unitAbility:GetName())
                if casterAbility then  -- if not a summon spell, set the level to the same as the caster.
                    level = casterAbility:GetLevel()
                end

                unitAbility:SetLevel(level)
            end
        end
    end


    function brewmaster_custom_primal_split:CreateSpirit(name)
        local caster = self:GetCaster()

        local spawnPos = caster:GetAbsOrigin() + RandomVector(250)
    
        local illusion = CreateUnitByName(name, spawnPos, true, caster, nil, caster:GetTeamNumber())
        illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
        illusion:SetMaxHealth(caster:GetMaxHealth())
        illusion:SetHealth(caster:GetHealth())

        self:LevelAbilities(illusion)
        disable_inventory(illusion)
    
        local duration = self:GetSpecialValueFor("duration")
    
        illusion:AddNewModifier(illusion, self, "modifier_brewmaster_custom_primal_split", {duration = duration})
        illusion:AddNewModifier(illusion, self, "modifier_arc_warden_tempest_double", {})
    
        FindClearSpaceForUnit(illusion, spawnPos, true)
    
        caster:EmitSound("Hero_Brewmaster.PrimalSplit.Spawn")
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
