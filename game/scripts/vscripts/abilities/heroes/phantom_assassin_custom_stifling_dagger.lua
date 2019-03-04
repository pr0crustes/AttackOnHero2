require("lib/my")


phantom_assassin_custom_stifling_dagger = class({})


if IsServer() then
    function phantom_assassin_custom_stifling_dagger:GetCooldown(iLevel)
        local talent_value = talent_value(self:GetCaster(), "phantom_assassin_custom_bonus_unique_1")
        if talent_value > 0 then
            return talent_value
        end
        return self.BaseClass.GetCooldown(self, iLevel)
    end


    function phantom_assassin_custom_stifling_dagger:OnSpellStart()	
        self.duration = self:GetSpecialValueFor("duration")
        self.dagger_speed = self:GetSpecialValueFor("dagger_speed")
        self.dagger_offset = self:GetSpecialValueFor("dagger_offset")
        self.dagger_count = self:GetSpecialValueFor("dagger_count")
        self.dagger_rate = self:GetSpecialValueFor("dagger_rate")
        self.dagger_range = self:GetSpecialValueFor("dagger_range")

        self.target_location = self:GetCursorPosition()
        self.accumulated_time = 0.0
        self.direction = self.target_location - self:GetCaster():GetOrigin() 
        self.daggers_thrown = 0

        local direction = self.target_location  - self:GetCaster():GetOrigin()
        direction.z = 0.0
        direction = direction:Normalized()
        
        self:ThrowDagger(direction)
    end


    function phantom_assassin_custom_stifling_dagger:OnChannelThink(flInterval)
        self.accumulated_time = self.accumulated_time + flInterval 
        if self.accumulated_time >= self.dagger_rate then
            self.accumulated_time = self.accumulated_time - self.dagger_rate

            local offset = RandomVector(self.dagger_offset)
            offset.z = 0.0
            
            local direction = (self.target_location + offset) - self:GetCaster():GetOrigin()
            direction.z = 0.0
            direction = direction:Normalized()

            self:ThrowDagger(direction)
        end
    end


    function phantom_assassin_custom_stifling_dagger:OnProjectileHit(target, pos)
        if target ~= nil and (not target:IsInvulnerable()) then
            local caster = self:GetCaster()

            caster:AddNewModifier(caster, self, "modifier_phantom_assassin_stiflingdagger_caster", {})
            caster:PerformAttack(target, false, true, true, true, true, false, true)
            caster:RemoveModifierByName("modifier_phantom_assassin_stiflingdagger_caster")

            target:AddNewModifier(caster, self, "modifier_phantom_assassin_stiflingdagger", { duration = self.duration })
            EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", target)
        end

        return true
    end


    function phantom_assassin_custom_stifling_dagger:ThrowDagger(direction)
        local caster = self:GetCaster()

        ProjectileManager:CreateLinearProjectile({
            EffectName = "particles/custom/phantom_assassin_linear_dagger.vpcf",
            Ability = self,
            vSpawnOrigin = caster:GetOrigin(), 
            fStartRadius = 50.0,
            fEndRadius = 50.0,
            vVelocity = direction * self.dagger_speed,
            fDistance = self.dagger_range,
            Source = caster,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        })

        EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast", caster)

        self.daggers_thrown = self.daggers_thrown + 1
        if self.daggers_thrown >= self.dagger_count then
            self:EndChannel(false)
        else
            caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.33)
        end
    end
end
