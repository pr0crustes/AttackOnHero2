require("lib/my")


LinkLuaModifier("modifier_doom_custom_dash", "abilities/heroes/doom_custom_dash.lua", LUA_MODIFIER_MOTION_HORIZONTAL)


local foward_modifier = "modifier_doom_custom_dash"


function cast_doom_dash(keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target_points[1]

    local speed = ability:GetSpecialValueFor("dash_speed")
    local treeRadius = ability:GetSpecialValueFor("tree_radius")

    local distance = (caster:GetAbsOrigin() - target):Length2D() 

    caster:RemoveModifierByName(foward_modifier)
    caster:StartGesture(ACT_DOTA_RUN)

    local kv = {
        duration = distance / speed,
        distance = distance,
        tree_radius = treeRadius,
        speed = speed
    }

    ability:ApplyDataDrivenModifier(caster, caster, keys.modifier, {})
    caster:AddNewModifier(nil, nil, foward_modifier, kv)
end



modifier_doom_custom_dash = class({})


function modifier_doom_custom_dash:IsHidden()
	return true
end


function modifier_doom_custom_dash:IsPurgable()
	return false
end


function modifier_doom_custom_dash:GetPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end


function modifier_doom_custom_dash:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end



function modifier_doom_custom_dash:OnCreated(keys)
    local parent = self:GetParent()

    self.direction = parent:GetForwardVector()
    self.distance_left = keys.distance
    self.speed = keys.speed
    self.tree_radius = keys.tree_radius
    self.attacked_units = {}

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
        return
    end
end


function modifier_doom_custom_dash:OnDestroy()
    local parent = self:GetParent()

    parent:FadeGesture(ACT_DOTA_RUN)
    parent:RemoveHorizontalMotionController(self)
    ResolveNPCPositions(parent:GetAbsOrigin(), 128)
end


function modifier_doom_custom_dash:UpdateHorizontalMotion(parent, deltaTime)
    local parentPos = parent:GetAbsOrigin()

    local distance = math.min(self.speed * deltaTime, self.distance_left)
    local newPos = parentPos + (distance * self.direction)

    parent:SetAbsOrigin(newPos)

    self.distance_left = self.distance_left - distance

    GridNav:DestroyTreesAroundPoint(newPos, self.tree_radius, false)

    -- Damage around
    local units = FindUnitsInRadius(parent:GetTeam(), newPos, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        if not self.attacked_units[unit] then
            self.attacked_units[unit] = true
            parent:PerformAttack(unit, true, true, true, false, false, false, false)
        end
	end
end


function modifier_doom_custom_dash:OnHorizontalMotionInterrupted()
    self:Destroy()
end

