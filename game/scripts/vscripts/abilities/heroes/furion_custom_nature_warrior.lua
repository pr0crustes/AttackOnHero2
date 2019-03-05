require("lib/illusion")


furion_custom_nature_warrior = class({})


if IsServer() then
    function furion_custom_nature_warrior:OnSpellStart()
        self.target_pos = self:GetCursorPosition()

        self.duration = self:GetSpecialValueFor("duration")
        self.health_multiplier = self:GetSpecialValueFor("health_multiplier")
        self.armor_multiplier = self:GetSpecialValueFor("armor_multiplier")
        self.magic_resistance = self:GetSpecialValueFor("magic_resistance")

        self:CreateTreant()
    end


    function furion_custom_nature_warrior:CreateTreant()
        local caster = self:GetCaster()

        local spawn_pos = self.target_pos + RandomVector(250)
    
        CreateUnitByNameAsync(
            "npc_dota_custom_nature_warrior",
            spawn_pos,
            true,
            caster,
            nil,
            caster:GetTeamNumber(),
            function(treant)
                treant:SetControllableByPlayer(caster:GetPlayerID(), true)

                local treant_hp = caster:GetMaxHealth() * self.health_multiplier
                treant:SetBaseMaxHealth(treant_hp)
                treant:SetMaxHealth(treant_hp)
                treant:SetHealth(treant_hp)

                local treant_damage = caster:GetAverageTrueAttackDamage(caster)
                treant:SetBaseDamageMin(treant_damage)
                treant:SetBaseDamageMax(treant_damage)
        
                treant:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue() * self.armor_multiplier)
        
                treant:SetBaseMagicalResistanceValue(self.magic_resistance)
            
                treant:AddNewModifier(treant, self, "modifier_kill", { duration = self.duration })
            
                FindClearSpaceForUnit(treant, spawn_pos, true)
            
                caster:EmitSound("Hero_Furion.WrathOfNature_Cast")

                self:TreantLevelSpells(treant)
            end
        )
    end


    function furion_custom_nature_warrior:TreantLevelSpells(treant)
        local level = self:GetLevel()

        if level >= 2 then
            local teleport = treant:FindAbilityByName("furion_treant_custom_teleport")
            if teleport then
                teleport:SetLevel(teleport:GetMaxLevel())
            end
        end

        if level >= 3 then
            local stone = treant:FindAbilityByName("furion_treant_custom_stone_formation")
            if stone then
                stone:SetLevel(stone:GetMaxLevel())
            end
        end
    end
end
