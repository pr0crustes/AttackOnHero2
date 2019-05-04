require("lib/my")


earth_spirit_custom_earth_essence = class({})


function earth_spirit_custom_earth_essence:GetIntrinsicModifierName()
    return "modifier_earth_spirit_custom_earth_essence"
end


if IsServer() then
    function earth_spirit_custom_earth_essence:OnSpellStart()
        local caster = self:GetCaster()
        local modifier_count = self:GetCount()

        local heal = caster:GetMaxHealth() * modifier_count * self:GetSpecialValueFor("hp_pct_heal") * 0.01
        caster:Heal(heal, caster)

        caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")

        ParticleManager:CreateParticle("particles/custom/treantheal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

        self:GetModifierHandle():SetStackCount(1)
    end


    function earth_spirit_custom_earth_essence:GetModifierHandle()
        return self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
    end


    function earth_spirit_custom_earth_essence:GetCount()
        local modifier = self:GetModifierHandle()
        if modifier then
            return modifier:GetStackCount()
        end
        return 0
    end
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_essence", "abilities/heroes/earth_spirit_custom_earth_essence.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_essence = class({})


function modifier_earth_spirit_custom_earth_essence:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end


function modifier_earth_spirit_custom_earth_essence:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("str_bonus")
end


if IsServer() then
    function modifier_earth_spirit_custom_earth_essence:OnStackCountChanged(count)
        self:GetParent():CalculateStatBonus()
    end


	function modifier_earth_spirit_custom_earth_essence:OnCreated()
        self.distance = 0

        self:SetStackCount(1)
        
        self:StartIntervalThink(0.1)
	end


    function modifier_earth_spirit_custom_earth_essence:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local position = parent:GetAbsOrigin()

        if self.position then
            local distance = math.min((self.position - position):Length2D(), 1000)
            if distance > 0 then
                self.distance = self.distance + distance

                local distance_value = ability:GetSpecialValueFor("distance")
                local max_stacks = ability:GetSpecialValueFor("max_stacks") + talent_value(parent, "earth_spirit_custom_bonus_unique_1")
                while self.distance >= distance_value do
                    self.distance = self.distance - distance_value

                    if self:GetStackCount() < max_stacks then
                        self:IncrementStackCount()
                    end
                end
            end
        end

        self.position = position
	end
end
