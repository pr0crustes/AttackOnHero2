require("lib/my")


earth_spirit_custom_earth_essence = class({})


function earth_spirit_custom_earth_essence:GetIntrinsicModifierName()
    return "modifier_earth_spirit_custom_earth_essence"
end


function earth_spirit_custom_earth_essence:AddEarthPoint()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_earth_spirit_custom_str_buff", {
        duration = self:GetSpecialValueFor("duration") + talent_value(caster, "earth_spirit_custom_bonus_unique_1")
    })
end


if IsServer() then
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


    function earth_spirit_custom_earth_essence:OnUpgrade()
        local modifier = self:GetModifierHandle()
        if modifier then
            modifier:UpdatePercentage()
        end
    end
end



LinkLuaModifier("modifier_earth_spirit_custom_earth_essence", "abilities/heroes/earth_spirit_custom_earth_essence.lua", LUA_MODIFIER_MOTION_NONE)

modifier_earth_spirit_custom_earth_essence = class({})


function modifier_earth_spirit_custom_earth_essence:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_UNIT_MOVED,
	}
end


function modifier_earth_spirit_custom_earth_essence:OnTooltip()
	return self:GetStackCount()
end


if IsServer() then
	function modifier_earth_spirit_custom_earth_essence:OnCreated()
		self.distance = 0
	end

	function modifier_earth_spirit_custom_earth_essence:OnUnitMoved()
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


	function modifier_earth_spirit_custom_earth_essence:UpdatePercentage()
		local ability = self:GetAbility()
        local completed = self.distance / ability:GetSpecialValueFor("distance")

		if completed < 1 then
			self:SetStackCount(math.floor(completed * 100))
		else
			self.distance = 0
            self:SetStackCount(0)
            
            local spell = self:GetParent():FindAbilityByName("earth_spirit_custom_earth_essence")
            if spell then
                spell:AddEarthPoint()
            end
		end
	end
end



LinkLuaModifier("modifier_earth_spirit_custom_str_hud", "abilities/heroes/earth_spirit_custom_earth_essence.lua", LUA_MODIFIER_MOTION_NONE)

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



LinkLuaModifier("modifier_earth_spirit_custom_str_buff", "abilities/heroes/earth_spirit_custom_earth_essence.lua", LUA_MODIFIER_MOTION_NONE)

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
