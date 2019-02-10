
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)



gyrocopter_custom_rocket_barrage = class({})


function gyrocopter_custom_rocket_barrage:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    caster:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
    caster:AddNewModifier(caster, self, "modifier_gyrocopter_custom_rocket_barrage", {duration = duration})
end


function gyrocopter_custom_rocket_barrage:OnProjectileHit(target)
    local caster = self:GetCaster()
    if target and caster and not caster:IsIllusion() then
        ApplyDamage({
            attacker = caster,
            victim = target,
            damage = self:GetSpecialValueFor("rocket_damage"),
            damage_type = self:GetAbilityDamageType(),
            ability = self
        })

        target:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Impact")
    end
end



modifier_gyrocopter_custom_rocket_barrage = class({})


function modifier_gyrocopter_custom_rocket_barrage:GetTexture()
    return "gyrocopter_rocket_barrage"
end


function modifier_gyrocopter_custom_rocket_barrage:GetEffectName()
    return "particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic_hit.vpcf"
end


if IsServer() then
    function modifier_gyrocopter_custom_rocket_barrage:OnCreated()
        local ability = self:GetAbility()

        self.radius = ability:GetSpecialValueFor("radius")
        self.interval = 1 / self:GetParent():GetAttacksPerSecond()

        self:StartIntervalThink(self.interval)
    end


    function modifier_gyrocopter_custom_rocket_barrage:OnIntervalThink()
        local parent = self:GetParent()

        local units = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        
        for _, unit in ipairs(units) do
            if unit then
                self:LaunchRocket(unit)

                if not parent:HasModifier("modifier_gyrocopter_flak_cannon") then
                    break
                end
            end
        end
    end


    function modifier_gyrocopter_custom_rocket_barrage:LaunchRocket(target)
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")

        ProjectileManager:CreateTrackingProjectile({
            Ability = ability,
            Target = target,
            Source = parent,
            EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic.vpcf",
            iMoveSpeed = 1000,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 5.0,
        })
    end
end
