

huskar_custom_life_trade = class({})


function huskar_custom_life_trade:OnToggle()
    local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_huskar_custom_life_trade")
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_huskar_custom_life_trade", {})
    end
end


function huskar_custom_life_trade:OnUpgrade()
    if self:GetToggleState() then
        self:ToggleAbility()
	end
end



LinkLuaModifier("modifier_huskar_custom_life_trade", "abilities/heroes/huskar_custom_life_trade.lua", LUA_MODIFIER_MOTION_NONE)


modifier_huskar_custom_life_trade = class({})


function modifier_huskar_custom_life_trade:IsHidden()
	return true
end


if IsServer() then
	function modifier_huskar_custom_life_trade:OnCreated()
		local parent = self:GetParent()

		if not parent then
			self:Destroy()
		end

		local ability = self:GetAbility()

		self.damage_pct = ability:GetSpecialValueFor("damage_pct") * 0.01
		self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
		self.interval = ability:GetSpecialValueFor("interval")
		self.tick_interval = ability:GetSpecialValueFor("tick_interval")
		self.model_multiplier = ability:GetSpecialValueFor("model_multiplier")

		self.tick_per_seconds = self.interval / self.tick_interval

		self.damage_pct_tick = self.damage_pct / self.tick_per_seconds

		self:StartIntervalThink(self.tick_interval)
	end


	function modifier_huskar_custom_life_trade:OnIntervalThink()
		local parent = self:GetParent()

		if parent then
			local health_loss = (parent:GetMaxHealth() * self.damage_pct_tick) + (parent:GetHealthRegen() / self.tick_per_seconds)
			local new_health = math.max(parent:GetHealth() - health_loss, 1)
			
			parent:SetHealth(new_health)
		end
	end


	function modifier_huskar_custom_life_trade:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MODEL_SCALE,
		}
	end


	function modifier_huskar_custom_life_trade:GetModifierAttackSpeedBonus_Constant()
		return self.bonus_attack_speed
	end


	function modifier_huskar_custom_life_trade:GetModifierModelScale()
		return self.model_multiplier
	end
end
