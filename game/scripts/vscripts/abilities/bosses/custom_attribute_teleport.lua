require("lib/my")



custom_attribute_teleport = class({})


if IsServer() then
    function custom_attribute_teleport:OnSpellStart()
        print("OnSpellStart")
        local random_target = random_from_table(self:GetValidTargets())

        if random_target then
            print("random_target")
            local caster = self:GetCaster()

            local new_pos = random_target:GetAbsOrigin() + RandomVector(300)

            caster:SetAbsOrigin(new_pos)

            FindClearSpaceForUnit(caster, new_pos, true)

            caster:SetAggroTarget(random_target)
        end
    end


    function custom_attribute_teleport:GetValidTargets()
        local valid_targets = {}

        local caster = self:GetCaster()

        local current_attribute = self:GetCurrentAttribute()

        print("Current attribute is " .. current_attribute)
        
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
        for _, unit in ipairs(units) do
            print("UNIT")
            if unit:IsRealHero() and unit:IsAlive() and unit:GetPrimaryAttribute() == current_attribute then
                print("FOUND ONE")
                table.insert(valid_targets, unit)
            end
        end

        return valid_targets
    end

    
    function custom_attribute_teleport:GetCurrentAttribute()
        local caster = self:GetCaster()

        if caster:HasModifier("modifier_custom_attribute_focus_red") then
            return 0
        end

        if caster:HasModifier("modifier_custom_attribute_focus_green") then
            return 1
        end

        if caster:HasModifier("modifier_custom_attribute_focus_blue") then
            return 2
        end

        return -1
    end
end





