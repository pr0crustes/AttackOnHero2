

rattletrap_custom_hookshot = class({})


function rattletrap_custom_hookshot:GetIntrinsicModifierName()
    return "modifier_rattletrap_custom_hookshot"
end


function rattletrap_custom_hookshot:OnToggle()
end



LinkLuaModifier("modifier_rattletrap_custom_hookshot_cooldown", "abilities/heroes/rattletrap_custom_hookshot.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_hookshot_cooldown = class({})


function modifier_rattletrap_custom_hookshot_cooldown:IsDebuff()
    return true
end


function modifier_rattletrap_custom_hookshot_cooldown:RemoveOnDeath()
    return false
end



LinkLuaModifier("modifier_rattletrap_custom_hookshot", "abilities/heroes/rattletrap_custom_hookshot.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_hookshot = class({})


function modifier_rattletrap_custom_hookshot:IsHidden()
    return true
end


if IsServer() then
    function modifier_rattletrap_custom_hookshot:ShouldCast(target)
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local distance = CalcDistanceBetweenEntityOBB(parent, target)

        if parent:IsIllusion()
            or parent:HasModifier("modifier_rattletrap_custom_hookshot_cooldown")
            or distance < ability:GetSpecialValueFor("min_distance")
            or distance > ability:GetSpecialValueFor("range") then

            return false
        end

        return ability:GetToggleState()
    end


    function modifier_rattletrap_custom_hookshot:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ORDER,
        }
    end


    function modifier_rattletrap_custom_hookshot:OnOrder(keys)
        if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
            local attacker = keys.unit

            if attacker == self:GetParent() then
                local target = keys.target

                if self:ShouldCast(target) then
                    local ability = self:GetAbility()

                    attacker:EmitSound("Hero_Rattletrap.Hookshot.Fire")

                    attacker:SetCursorCastTarget(target)
                    attacker:AddNewModifier(attacker, ability, "modifier_rattletrap_custom_hookshot_dash", {})
                    attacker:AddNewModifier(attacker, ability, "modifier_rattletrap_custom_hookshot_cooldown", {
                        duration = ability:GetSpecialValueFor("cooldown") + talent_value(attacker, "rattletrap_custom_bonus_unique_2")
                    })
                end
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
        self.target = self:GetAbility():GetCursorTarget()

        local ability = self:GetAbility()
        self.speed = ability:GetSpecialValueFor("speed")
        self.stop_distance = ability:GetSpecialValueFor("stop_distance")

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
            return
        end
    end


    function modifier_rattletrap_custom_hookshot_dash:OnDestroy()
        local parent = self:GetParent()
        parent:RemoveHorizontalMotionController(self)
        ResolveNPCPositions(parent:GetAbsOrigin(), self.stop_distance)
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
