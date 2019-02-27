

rattletrap_custom_hookshot = class({})


function rattletrap_custom_hookshot:GetIntrinsicModifierName()
    return "modifier_rattletrap_custom_hookshot"
end


function rattletrap_custom_hookshot:OnSpellStart()

end


if IsServer() then
    function rattletrap_custom_hookshot:GetCooldown(iLevel)
        return self.BaseClass.GetCooldown(self, iLevel) + talent_value(self:GetCaster(), "rattletrap_custom_bonus_unique_2")
    end


    function rattletrap_custom_hookshot:OnSpellStart()
        self:CastOnTarget(self:GetCursorTarget())
    end


    function rattletrap_custom_hookshot:CastOnTarget(target)
        if self:ShouldCast(target) then
            local caster = self:GetCaster()

            caster:SetCursorCastTarget(target)
            caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_hookshot_dash", {})

            self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
        end
    end


    function rattletrap_custom_hookshot:ShouldCast(target)
        local caster = self:GetCaster()

        local distance = CalcDistanceBetweenEntityOBB(caster, target)

        return not (
            caster:IsIllusion()
            or distance < self:GetSpecialValueFor("min_distance")
            or distance > self:GetSpecialValueFor("range")
        )
    end
end



LinkLuaModifier("modifier_rattletrap_custom_hookshot", "abilities/heroes/rattletrap_custom_hookshot.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_hookshot = class({})


function modifier_rattletrap_custom_hookshot:IsHidden()
    return true
end


if IsServer() then
    function modifier_rattletrap_custom_hookshot:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ORDER,
        }
    end


    function modifier_rattletrap_custom_hookshot:OnOrder(keys)
        if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
            local attacker = keys.unit
            local ability = self:GetAbility()

            if attacker == self:GetParent() and ability:GetAutoCastState() and ability:IsCooldownReady() then
                local target = keys.target

                ability:CastOnTarget(target)
            end
        end
    end
end



LinkLuaModifier("modifier_rattletrap_custom_hookshot_dash", "abilities/heroes/rattletrap_custom_hookshot.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

modifier_rattletrap_custom_hookshot_dash = class({})


function modifier_rattletrap_custom_hookshot_dash:IsHidden()
    return true
end


if IsServer() then
    function modifier_rattletrap_custom_hookshot_dash:OnCreated()
        print("OnCreated")
        self.target = self:GetAbility():GetCursorTarget()

        local ability = self:GetAbility()
        self.speed = ability:GetSpecialValueFor("speed")
        self.stop_distance = ability:GetSpecialValueFor("stop_distance")

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
            return
        end

        local parent = self:GetParent()

        parent:EmitSound("Hero_Rattletrap.Hookshot.Fire")

        self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN, parent)
        ParticleManager:SetParticleControlEnt(self.effect, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.effect, 1, self.target:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.effect, 2, Vector(10000, 0, 0))
        ParticleManager:SetParticleControl(self.effect, 3, Vector(10, 0, 0))
    end


    function modifier_rattletrap_custom_hookshot_dash:OnDestroy()
        local parent = self:GetParent()
        parent:RemoveHorizontalMotionController(self)
        ResolveNPCPositions(parent:GetAbsOrigin(), self.stop_distance)

        ParticleManager:DestroyParticle(self.effect, false)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end


    function modifier_rattletrap_custom_hookshot_dash:GetPriority()
        return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
    end


    function modifier_rattletrap_custom_hookshot_dash:CheckState()
        return {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }
    end


    function modifier_rattletrap_custom_hookshot_dash:UpdateHorizontalMotion(parent, deltaTime)
        if not self.target or not self.target:IsAlive() then
            self:Destroy()
        end

        local parent_pos = parent:GetAbsOrigin()
        local target_pos = self.target:GetAbsOrigin()

        local direction = (target_pos - parent_pos):Normalized()
        local distance_to_target = (target_pos - parent_pos):Length2D()

        if distance_to_target <= self.stop_distance then
            parent:EmitSound("Hero_Rattletrap.Hookshot.Impact")
            self:Destroy()
        end

        local distance = math.min(self.speed * deltaTime, distance_to_target)
        local new_pos = parent_pos + (distance * direction)

        parent:SetAbsOrigin(new_pos)
    end


    function modifier_rattletrap_custom_hookshot_dash:OnHorizontalMotionInterrupted()
        self:Destroy()
    end
end
