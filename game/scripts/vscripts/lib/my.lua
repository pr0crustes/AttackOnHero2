

function debug_print(a)
	--Say(nil, a, false)
	return
end


function debug_start_at_round(rounds, startAt)
	for i = 1, startAt - 1 do
		table.remove(rounds, 1)
	end
end


function value_if_scepter(caster, ifYes, ifNot)
	if caster:HasScepter() then
		return ifYes
	end
	return ifNot
end


function increase_modifier(caster, target, ability, modifier)
	if target:HasModifier(modifier) then
		local newCount = target:GetModifierStackCount(modifier, caster) + 1
        target:SetModifierStackCount(modifier, caster, newCount)
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		target:SetModifierStackCount(modifier, caster, 1)
    end
end


function decrease_modifier(caster, target, modifier)
	if target:HasModifier(modifier) then
		local count = target:GetModifierStackCount(modifier, caster)

		if count > 1 then
			target:SetModifierStackCount(modifier, caster, count - 1)
		else 
			target:RemoveModifierByName(modifier)
		end
	end
end


function increase_lua_modifier(caster, target, modifier)
	if target:HasModifier(modifier) then
		local newCount = target:GetModifierStackCount(modifier, caster) + 1
        target:SetModifierStackCount(modifier, caster, newCount)
	else
		target:AddNewModifier(caster, nil, modifier, {})
		target:SetModifierStackCount(modifier, caster, 1)
    end
end


function consumable_used(caster, item, modifier)
	increase_modifier(caster, caster, item, modifier)
    caster:RemoveItem(item)
end


function random_from_table(the_table)
	if #the_table < 1 then
		return nil
	end

	return the_table[RandomInt(1, #the_table)]
end


function kill_if_alive(unit)
	if unit:IsAlive() then
		unit:ForceKill(false)
	end
end


function clamp_value(value, min, max)
	return math.max(math.min(value, max), min)
end


function ability_start_true_cooldown(ability)
	ability:StartCooldown(ability_true_cooldown(ability))
end


function ability_true_cooldown(ability)
	local caster = ability:GetCaster()
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

	local cooldown_reduct = 0
	local cooldown_reduct_stack = 0
	for k, v in pairs(caster:FindAllModifiers()) do
		print("Modifier  " .. v:GetName())
		if v[GetModifierPercentageCooldown] then
		  	cooldown_reduct = math.max(cooldown_reduct, v:GetModifierPercentageCooldown())
		end
		if v[GetModifierPercentageCooldownStacking] then
		  	cooldown_reduct_stack = cooldown_reduct_stack + v:GetModifierPercentageCooldownStacking()
		end
	end

	value = cooldown * math.max(0.01,(1 - (cooldown_reduct + cooldown_reduct_stack)*0.01))

	print("ability_true_cooldown original is " .. cooldown .. " reduction is " .. (cooldown_reduct + cooldown_reduct_stack) .. " new cd is " .. value)

	return value
end


function ability_behavior_includes(ability, behavior)
	return bit.band(ability:GetBehavior(), behavior) == behavior
end


function find_item(caster, item_name)
    for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
        if item:GetName() == item_name then
            return item
        end
    end
    return nil
end


function refresh_players()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if not hero:IsAlive() then
				hero:RespawnUnit()
			end
			hero:SetHealth(hero:GetMaxHealth())
			hero:SetMana(hero:GetMaxMana())
			hero:SetBaseMagicalResistanceValue(25)
		end
	end
end
