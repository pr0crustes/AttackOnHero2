require("lib/timers")


treant_custom_ultimate_sacrifice = class({})


function treant_custom_ultimate_sacrifice:IsStealable()
    return false
end


function treant_custom_ultimate_sacrifice:OnChannelThink(interval)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
end


if IsServer() then
    function treant_custom_ultimate_sacrifice:OnChannelFinish(interrupted)
        if not interrupted then
            self:RessurectAll()
            self:DestroyTrees()
            self:Suicide(0.05)

            local caster = self:GetCaster()
            caster:EmitSound("Hero_Treant.Overgrowth.Cast")
            caster:EmitSound("Hero_Treant.Overgrowth.Target")
        end
    end


    function treant_custom_ultimate_sacrifice:RessurectAll()
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:HasSelectedHero(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if not hero:IsAlive() then
                    hero:RespawnUnit()
                    hero:SetHealth(hero:GetMaxHealth())
                    hero:SetMana(hero:GetMaxMana())
                    hero:SetBaseMagicalResistanceValue(25)
                end
            end
        end
    end


    function treant_custom_ultimate_sacrifice:Suicide(delay)
        Timers:CreateTimer(
            delay, 
            function()
                local caster = self:GetCaster()
                if caster:IsAlive() then
                    caster:ForceKill(false)
                end
            end
        )
    end


    function treant_custom_ultimate_sacrifice:DestroyTrees()
        GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 3900, false)
    end
end
