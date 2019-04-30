require("lib/my")


earth_spirit_custom_earth_walking = class({})


function earth_spirit_custom_earth_walking:GetIntrinsicModifierName()
    return "modifier_earth_spirit_custom_earth_walking"
end


function earth_spirit_custom_earth_walking:AddEarthPoint()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_earth_spirit_custom_str_buff", {
        duration = self:GetSpecialValueFor("duration") + talent_value(caster, "earth_spirit_custom_bonus_unique_1")
    })
end


if IsServer() then
	function earth_spirit_custom_earth_walking:OnUpgrade()
		local modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
		if modifier then
			modifier:UpdatePercentage()
		end
	end
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_walking", "abilities/heroes/earth_spirit_custom_earth_walking.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_walking = class({})


function modifier_earth_spirit_custom_earth_walking:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_UNIT_MOVED,
	}
end


function modifier_earth_spirit_custom_earth_walking:OnTooltip()
	return self:GetStackCount()
end


if IsServer() then
	function modifier_earth_spirit_custom_earth_walking:OnCreated()
		self.distance = 0
	end

	function modifier_earth_spirit_custom_earth_walking:OnUnitMoved()
		local parent = self:GetParent()
        local position = parent:GetAbsOrigin()

		if self.position then
			local distance = math.min((self.position - position):Length2D(), 1000)
			if distance > 0 then
				self.distance = self.distance + distance
				self:UpdatePercentage()
			end
        end

		self.position = position
	end


	function modifier_earth_spirit_custom_earth_walking:UpdatePercentage()
		local ability = self:GetAbility()
        local completed = self.distance / ability:GetSpecialValueFor("distance")

		if completed < 1 then
			self:SetStackCount(math.floor(completed * 100))
		else
			self.distance = 0
            self:SetStackCount(0)
            
            local spell = self:GetParent():FindAbilityByName("earth_spirit_custom_earth_walking")
            if spell then
                spell:AddEarthPoint()
            end
		end
	end
end



LinkLuaModifier("modifier_earth_spirit_custom_str_hud", "abilities/heroes/earth_spirit_custom_earth_walking.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_str_hud = class({})


function modifier_earth_spirit_custom_str_hud:IsBuff()
    return true
end


function modifier_earth_spirit_custom_str_hud:GetTexture()
    return "earth_spirit_stone_caller"
end


function modifier_earth_spirit_custom_str_hud:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end


function modifier_earth_spirit_custom_str_hud:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("str_bonus") * self:GetStackCount()
end



LinkLuaModifier("modifier_earth_spirit_custom_str_buff", "abilities/heroes/earth_spirit_custom_earth_walking.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_str_buff = class({})


function modifier_earth_spirit_custom_str_buff:IsHidden()
    return true
end


function modifier_earth_spirit_custom_str_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then
    function modifier_earth_spirit_custom_str_buff:OnCreated()
        local caster = self:GetCaster()
        if not caster:HasModifier("modifier_earth_spirit_custom_str_hud") then
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_earth_spirit_custom_str_hud", {})
        end
        caster:FindModifierByName("modifier_earth_spirit_custom_str_hud"):IncrementStackCount()
    end


    function modifier_earth_spirit_custom_str_buff:OnDestroy()
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_earth_spirit_custom_str_hud") then
            local modifier = caster:FindModifierByName("modifier_earth_spirit_custom_str_hud")

            if modifier:GetStackCount() > 1 then
                modifier:DecrementStackCount()
            else 
                modifier:Destroy()
            end
        end
    end
end
