

visage_custom_imperfect_shield = class({})


function visage_custom_imperfect_shield:OnSpellStart()
    local target = self:GetCursorTarget()

    target:AddNewModifier(self:GetCaster(), self, "modifier_visage_custom_imperfect_shield", {
        duration = self:GetSpecialValueFor("duration")
    })
end



LinkLuaModifier("modifier_visage_custom_imperfect_shield", "abilities/heroes/visage_custom_imperfect_shield.lua", LUA_MODIFIER_MOTION_NONE)


modifier_visage_custom_imperfect_shield = class({})


if IsServer() then
    function modifier_visage_custom_imperfect_shield:OnCreated(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:EmitSound("Hero_Abaddon.AphoticShield.Cast")

        local shield_size = 100
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.particle, 1, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 2, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 4, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size, 0, 0))
        ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    end


    function modifier_visage_custom_imperfect_shield:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")

        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end


    function modifier_visage_custom_imperfect_shield:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        }
    end

    
    function modifier_visage_custom_imperfect_shield:GetModifierTotal_ConstantBlock(keys)
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()

        if not caster:IsAlive() or not parent:IsAlive() then
            self:Destroy()
            return
        end

        local damage = keys.damage

        local block_damage = damage * ability:GetSpecialValueFor("damage_transfer") * 0.01

        if caster:GetMana() >= block_damage then
            caster:SpendMana(block_damage, ability)
            return block_damage
        else
            self:Destroy()
            return 0
        end
    end
end
