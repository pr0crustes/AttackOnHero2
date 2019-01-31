require("lib/my")


local mr_per_str_lookup = {0.1000, 0.0800, 0.0800}


modifier_atr_fix = class({})


function modifier_atr_fix:IsHidden()
    return true
end


function modifier_atr_fix:IsPurgable()
    return false
end


function modifier_atr_fix:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end


function modifier_atr_fix:GetModifierMagicalResistanceBonus()
    local parent = self:GetParent()
    local parent_str = parent:GetStrength()

    if parent:HasModifier("modifier_priimary_attribute") then

        local count = parent:GetModifierStackCount("modifier_priimary_attribute", parent)

        if count > 0 then

            local mr_per_str = mr_per_str_lookup[count]

            local mr_bonus = 0 - (parent_str * mr_per_str)
            
            return mr_bonus * 0.35
        end
    end
end

