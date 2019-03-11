


visage_custom_spirit_teleport = class({})


if IsServer() then
    function visage_custom_spirit_teleport:CastFilterResultTarget(target)
        if self:GetCaster() == target then
            return UF_FAIL_CUSTOM
        end
        return UF_SUCCESS
    end


    function visage_custom_spirit_teleport:GetCustomCastErrorTarget(target)
        if self:GetCaster() == target then
            return "#dota_hud_error_cant_cast_on_self"
        end
        return ""
    end


    function visage_custom_spirit_teleport:OnSpellStart()
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


    function visage_custom_spirit_teleport:OnProjectileHit(target, position)
        local caster = self:GetCaster()
        local caster_pos = caster:GetAbsOrigin()
        local target_pos = target:GetAbsOrigin()

        ProjectileManager:ProjectileDodge(caster)

        caster:EmitSound("Hero_QueenOfPain.Blink_in")

        local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle1, 0, caster_pos)
        ParticleManager:SetParticleControl(particle1, 1, target_pos)
        ParticleManager:ReleaseParticleIndex(particle1)

        local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle2, 0, target_pos)
        ParticleManager:SetParticleControlForward(particle2, 0, (target_pos - caster_pos):Normalized())
        ParticleManager:ReleaseParticleIndex(particle2)

        local pos = target_pos + RandomVector(100)
        caster:SetOrigin(pos)
        FindClearSpaceForUnit(caster, pos, true)

        target:Heal(self:GetSpecialValueFor("heal"), caster)
    end
end
