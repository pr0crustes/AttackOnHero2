require("lib/popup")



wisp_custom_fundamental_heal = class({})


if IsServer() then
    function wisp_custom_fundamental_heal:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
    
        local heal = self:GetSpecialValueFor("base_heal")
    
        if target:HasModifier("modifier_wisp_custom_fundamental_heal") then
            heal = heal * self:GetSpecialValueFor("multiplier")
            target:RemoveModifierByName("modifier_wisp_custom_fundamental_heal")
        end

        target:AddNewModifier(caster, self, "modifier_wisp_custom_fundamental_heal", {
            duration = self:GetSpecialValueFor("duration")
        })
    
        caster:EmitSound("Hero_Wisp.Relocate")
    
        target:Heal(heal, caster)

        create_popup({
            target = target,
            value = heal,
            color = Vector(0, 230, 0),
            type = "heal"
        })
    end
end



LinkLuaModifier("modifier_wisp_custom_fundamental_heal", "abilities/heroes/wisp_custom_fundamental_heal.lua", LUA_MODIFIER_MOTION_NONE)

modifier_wisp_custom_fundamental_heal = class({})


if IsServer() then
    function modifier_wisp_custom_fundamental_heal:OnCreated()
        local parent = self:GetParent()

        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.particle, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector(0, 1, 0))


        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end


    function modifier_wisp_custom_fundamental_heal:OnDestroy()
        ParticleManager:DestroyParticle(self.particle, false)
    end
end