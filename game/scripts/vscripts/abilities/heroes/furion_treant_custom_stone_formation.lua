


furion_treant_custom_stone_formation = class({})


if IsServer() then
    function furion_treant_custom_stone_formation:OnToggle()
        local caster = self:GetCaster()
        caster:EmitSound("Visage_Familar.StoneForm.Cast")

        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, "modifier_furion_treant_custom_stone_formation", {})
        else
            caster:RemoveModifierByName("modifier_furion_treant_custom_stone_formation")
        end
    end
end



LinkLuaModifier("modifier_furion_treant_custom_stone_formation", "abilities/heroes/furion_treant_custom_stone_formation.lua", LUA_MODIFIER_MOTION_NONE)

modifier_furion_treant_custom_stone_formation = class({})


function modifier_furion_treant_custom_stone_formation:GetStatusEffectName()
    return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end


function modifier_furion_treant_custom_stone_formation:StatusEffectPriority()
    return 20
end


if IsServer() then
    function modifier_furion_treant_custom_stone_formation:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        }
    end


    function modifier_furion_treant_custom_stone_formation:GetModifierIncomingDamage_Percentage(keys)
        return -100
    end


    function modifier_furion_treant_custom_stone_formation:CheckState()
        return {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }
    end

end

