require("lib/my")
require("lib/timers")



local soul_stack_modifier = "modifier_nevermore_custom_necromastery_stack"


function requiem_line_effect(caster, velocity, duration)
	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect, 1, velocity)
	ParticleManager:SetParticleControl(effect, 2, Vector(0, duration, 0))
	ParticleManager:ReleaseParticleIndex(effect)
end


function create_requiem_line(caster, ability, end_position)
	local lines_end_width = ability:GetSpecialValueFor("lines_end_width")
	local lines_starting_width = ability:GetSpecialValueFor("lines_starting_width")
	local lines_travel_speed = ability:GetSpecialValueFor("lines_travel_speed")
    local travel_distance = ability:GetSpecialValueFor("travel_distance")
    
    local caster_pos = caster:GetAbsOrigin()

    local velocity = (end_position - caster_pos):Normalized() * lines_travel_speed

	ProjectileManager:CreateLinearProjectile({
        Ability = ability,
		EffectName = particle_lines,
		vSpawnOrigin = caster_pos,
		fDistance = travel_distance,
		fStartRadius = lines_starting_width,
		fEndRadius = lines_end_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit = false,
		vVelocity = velocity,
		bProvidesVision = false,
		ExtraData = {scepter_line = false}
	})

	requiem_line_effect(caster, velocity, (travel_distance / lines_travel_speed))
end



function cast_nevermore_custom_requiem(keys)
    local caster = keys.caster
    local ability = keys.ability

	local souls_per_line = ability:GetSpecialValueFor("souls_per_line")
    local travel_distance = ability:GetSpecialValueFor("travel_distance")


    if caster:HasModifier(soul_stack_modifier) then
        local stacks = caster:GetModifierStackCount(soul_stack_modifier, caster)
		local line_count = math.floor(stacks / souls_per_line)
		
		local caster_pos = caster:GetAbsOrigin()

        local line_pos = caster_pos + caster:GetForwardVector() * travel_distance

        create_requiem_line(caster, ability, line_pos)

        local rotation_rate = 360 / line_count  -- spaced around all circle.
        for i = 1, line_count - 1 do
            line_pos = RotatePosition(caster_pos, QAngle(0, rotation_rate, 0), line_pos)

            create_requiem_line(caster, ability, line_pos)
        end
    end
end

