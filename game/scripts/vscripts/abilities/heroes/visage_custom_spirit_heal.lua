


visage_custom_spirit_heal = class({})


if IsServer() then
    function visage_custom_spirit_heal:CastFilterResultTarget(target)
        if self:GetCaster() == target then
            return UF_FAIL_CUSTOM
        end
        return UF_SUCCESS
    end


    function visage_custom_spirit_heal:GetCustomCastErrorTarget(target)
        if self:GetCaster() == target then
            return "#dota_hud_error_cant_cast_on_self"
        end
        return ""
    end


    function visage_custom_spirit_heal:OnSpellStart()
        local target = self:GetCursorTarget()
        local caster = self:GetCaster()

        caster:EmitSound("Hero_Visage.SoulAssumption.Cast")

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/units/heroes/hero_visage/visage_familiar_base_attack.vpcf",
            iMoveSpeed = 1500,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 6,
        })
    end


    function visage_custom_spirit_heal:OnProjectileHit(target, position)
        local caster = self:GetCaster()

        target:EmitSound("Hero_Visage.SoulAssumption.Target")

        target:Heal(self:GetSpecialValueFor("heal"), caster)
    end
end
