require("lib/my")


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


function modifier_atr_fix:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end


function modifier_atr_fix:GetModifierMagicalResistanceBonus()
    local parent = self:GetParent()
    local parent_str = parent:GetStrength()

    local mr_per_str = 0.08
    local factor = 0.5
    
    local mr_reduction = parent_str * mr_per_str * factor * -1  -- -1 so it is negative.
    return mr_reduction
end

