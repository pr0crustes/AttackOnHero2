require("lib/my")


modifier_priimary_attribute = class({})


function modifier_priimary_attribute:IsHidden()
    return true
end


function modifier_priimary_attribute:IsPurgable()
    return false
end
