

local function swap_effect(hero1, hero2)
    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero1)
    ParticleManager:SetParticleControlEnt(fx, 1, hero2, PATTACH_ABSORIGIN_FOLLOW, nil, hero2:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(fx)
    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hero1)
end


local function teleport_illusions_to_caster(caster)
    local caster_pos = caster:GetAbsOrigin()

    local units = Entities:FindAllByName(caster:GetName())
    for i, unit in ipairs(units) do
        if unit:IsAlive() and unit:IsIllusion() then
            swap_effect(unit, caster)
            unit:SetOrigin(caster_pos)
            FindClearSpaceForUnit(unit, caster_pos, true)
        end
    end
end


local function swap(caster, target)
    local vPos1 = caster:GetOrigin()
    local vPos2 = target:GetOrigin()

    caster:SetOrigin(vPos2)
    target:SetOrigin(vPos1)

    FindClearSpaceForUnit(caster, vPos2, true)
    FindClearSpaceForUnit(target, vPos1, true)

    swap_effect(caster, target)
end


function cast_naga_siren_custom_puppet(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    if target == caster then
        teleport_illusions_to_caster(caster)
        return
    end

    if not (target:IsIllusion() and target:GetName() == caster:GetName()) then  -- target must be an illusion.
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        ability:EndCooldown()
        return
    end

    swap(caster, target)
end
