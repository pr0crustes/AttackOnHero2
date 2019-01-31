require("lib/my")


LinkLuaModifier("modifier_priimary_attribute", "modifiers/modifier_priimary_attribute.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atr_fix", "modifiers/modifier_atr_fix.lua", LUA_MODIFIER_MOTION_NONE)


-- Fixes the magic res str gives. Check if it is a hero before calling.
function fix_atr_for_hero(hero)

    local indicator_mod = "modifier_priimary_attribute"
	local fix_mod = "modifier_atr_fix"
	
    if not hero:HasModifier(indicator_mod) then
        hero:AddNewModifier(hero, nil, indicator_mod, {})
        hero:SetModifierStackCount(indicator_mod, hero, hero:GetPrimaryAttribute() + 1)
    end

    if not hero:HasModifier(fix_mod) then
        hero:AddNewModifier(hero, nil, fix_mod, {})
    end
end
