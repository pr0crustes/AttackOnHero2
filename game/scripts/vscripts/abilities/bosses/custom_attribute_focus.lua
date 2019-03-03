

custom_attribute_focus = class({})


if IsServer() then
    function custom_attribute_focus:OnUpgrade()
        if not self.has_setup then
            local caster = self:GetCaster()

            caster:AddNewModifier(caster, self, "modifier_custom_attribute_focus_red", {
                duration = self:GetSpecialValueFor("rotation_time")
            })

            self.has_setup = true
        end
    end
end



LinkLuaModifier("modifier_custom_attribute_focus_base", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_base = class({})


if IsServer() then
    function modifier_custom_attribute_focus_base:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:AddNewModifier(parent, ability, self.next_modifier, {
            duration = ability:GetSpecialValueFor("rotation_time")
        })
    end



    function modifier_custom_attribute_focus_base:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        }
    end

    
    function modifier_custom_attribute_focus_base:GetModifierIncomingDamage_Percentage()
        return self:GetAbility():GetSpecialValueFor("damage_reduction")
    end

    
    function modifier_custom_attribute_focus_base:OnTakeDamage(keys)
        local parent = self:GetParent()
        if keys.unit == parent then
            local attacker = keys.attacker
            if attacker and attacker:GetPrimaryAttribute() == self.attribute then
                print("IS ATTRIBUTE")
                ApplyDamage({
                    ability = keys.inflictor,
                    attacker = attacker,
                    damage = keys.damage,
                    damage_type = DAMAGE_TYPE_PURE,
                    victim = parent
                })
            end
        end
    end
end



LinkLuaModifier("modifier_custom_attribute_focus_red", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_red = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_red.attribute = 0
modifier_custom_attribute_focus_red.next_modifier = "modifier_custom_attribute_focus_green"



LinkLuaModifier("modifier_custom_attribute_focus_green", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_green = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_green.attribute = 1
modifier_custom_attribute_focus_green.next_modifier = "modifier_custom_attribute_focus_blue"



LinkLuaModifier("modifier_custom_attribute_focus_blue", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_blue = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_blue.attribute = 2
modifier_custom_attribute_focus_blue.next_modifier = "modifier_custom_attribute_focus_red"
