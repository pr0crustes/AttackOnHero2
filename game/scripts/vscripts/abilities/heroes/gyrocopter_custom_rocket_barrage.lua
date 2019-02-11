
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage_mana", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)



gyrocopter_custom_rocket_barrage = class({})


function gyrocopter_custom_rocket_barrage:OnToggle()
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Gyrocopter.Rocket_Barrage")

    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_gyrocopter_custom_rocket_barrage", {})
        caster:AddNewModifier(caster, self, "modifier_gyrocopter_custom_rocket_barrage_mana", {})
    else
        caster:RemoveModifierByName("modifier_gyrocopter_custom_rocket_barrage")
        caster:RemoveModifierByName("modifier_gyrocopter_custom_rocket_barrage_mana")
    end
end


if IsServer() then
    function gyrocopter_custom_rocket_barrage:OnProjectileHit(target)
        local caster = self:GetCaster()
        if target and caster and not caster:IsIllusion() then

            local damage = self:GetSpecialValueFor("rocket_damage")

            local talent = caster:FindAbilityByName("gyrocopter_custom_bonus_unique_1")
            if talent and talent:GetLevel() > 0 then
                damage = damage + talent:GetSpecialValueFor("value")
            end

            ApplyDamage({
                attacker = caster,
                victim = target,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })

            target:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Impact")
        end
    end
end


modifier_gyrocopter_custom_rocket_barrage_mana = class({})


function modifier_gyrocopter_custom_rocket_barrage_mana:IsHidden()
    return true
end


if IsServer() then
    function modifier_gyrocopter_custom_rocket_barrage_mana:OnCreated()
        local ability = self:GetAbility()

        self.mana_cost = ability:GetManaCost(-1)
        
        self:StartIntervalThink(1.0)
    end


    function modifier_gyrocopter_custom_rocket_barrage_mana:OnIntervalThink()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        if parent:GetMana() >= self.mana_cost then
            parent:SpendMana(self.mana_cost, ability)
        else
            ability:ToggleAbility()
        end
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
    function modifier_gyrocopter_custom_rocket_barrage:SetIntervalThink()
        self:StartIntervalThink(1 / self:GetParent():GetAttacksPerSecond())
    end

    function modifier_gyrocopter_custom_rocket_barrage:OnCreated()
        local ability = self:GetAbility()

        self.radius = ability:GetSpecialValueFor("radius")
        
        self:SetIntervalThink()
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
        self:SetIntervalThink()
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
