require("lib/my")


LinkLuaModifier("modifier_rattletrap_custom_battery_assault", "abilities/heroes/rattletrap_custom_battery_assault.lua", LUA_MODIFIER_MOTION_NONE)


rattletrap_custom_battery_assault = class({})


function rattletrap_custom_battery_assault:OnSpellStart()
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Rattletrap.Battery_Assault")

    caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_battery_assault", {
        duration = self:GetSpecialValueFor("duration")
    })
end


if IsServer() then
    function rattletrap_custom_battery_assault:OnProjectileHit(target)
        local caster = self:GetCaster()
        if target and caster and not caster:IsIllusion() then
            local attack_as_damage = self:GetSpecialValueFor("attack_as_damage") * 0.01

            local attack_damage = caster:GetAverageTrueAttackDamage(target)

            local damage = attack_damage * attack_as_damage

            ApplyDamage({
                attacker = caster,
                victim = target,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })

            target:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
        end
    end
end



modifier_rattletrap_custom_battery_assault = class({})


if IsServer() then
    function modifier_rattletrap_custom_battery_assault:OnDestroy()
        self:GetParent():StopSound("Hero_Rattletrap.Battery_Assault")
    end


    function modifier_rattletrap_custom_battery_assault:OnCreated()
        local ability = self:GetAbility()

        self.radius = ability:GetSpecialValueFor("radius")
        self.interval = ability:GetSpecialValueFor("interval") + talent_value(self:GetCaster(), "rattletrap_custom_bonus_unique_1")
        
        self:StartIntervalThink(self.interval)
    end


    function modifier_rattletrap_custom_battery_assault:OnIntervalThink()
        local parent = self:GetParent()

        local units = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        
        for _, unit in ipairs(units) do
            if unit then
                self:LaunchRocket(unit)
                break
            end
        end

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end


    function modifier_rattletrap_custom_battery_assault:LaunchRocket(target)
        local parent = self:GetParent()

        parent:EmitSound("Hero_Rattletrap.Battery_Assault_Launch")

        ProjectileManager:CreateTrackingProjectile({
            Ability = self:GetAbility(),
            Target = target,
            Source = parent,
            EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf",
            iMoveSpeed = 1000,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 5.0,
        })
    end
end
