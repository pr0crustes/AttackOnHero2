require("lib/timers")


rattletrap_custom_rocket_flare = class({})


function rattletrap_custom_rocket_flare:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end


if IsServer() then
    function rattletrap_custom_rocket_flare:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        
        caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Fire")

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
            iMoveSpeed = 2200,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 20.0,
        })
    end


    function rattletrap_custom_rocket_flare:OnProjectileHit(target, location)
        if target then
            local caster = self:GetCaster()
            caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")

            local damage = self:GetSpecialValueFor("damage") + (caster:GetStrength() * self:GetSpecialValueFor("damage_str") * 0.01)

            local total_damage_dealt = self:DealDamage(target:GetAbsOrigin(), damage)

            caster:Heal(total_damage_dealt * self:GetSpecialValueFor("heal") * 0.01, caster)
        end
    end


    function rattletrap_custom_rocket_flare:DealDamage(pos, damage)
        local caster = self:GetCaster()
        local total_damage_dealt = 0
        local units = FindUnitsInRadius(caster:GetTeam(), pos, nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, 0, false)
        for _, unit in ipairs(units) do
            if unit then
                local dealt_damage = ApplyDamage({
                    ability = self,
                    attacker = caster,
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    victim = unit
                })
                total_damage_dealt = total_damage_dealt + dealt_damage
            end
        end
        return total_damage_dealt
    end
end
