require("lib/my")
require("lib/refresh")


local exclude_abilities = {
}


local exclude_items = {
    -- Default
    item_aeon_disk = true,
    item_arcane_boots = true,
    item_black_king_bar = true,
    item_custom_refresher = true,
    item_guardian_greaves = true,
    item_hand_of_midas = true,
    item_helm_of_the_dominator = true,
    item_meteor_hammer = true,
    item_necronomicon = true,
    item_necronomicon_2 = true,
    item_necronomicon_3 = true,
    item_pipe = true,
    item_sphere = true,

    -- Added
    item_abyssal_blade = true,
    item_bloodthorn = true,
    item_cyclone = true,
    item_ethereal_blade = true,
    item_nullifier = true,
    item_orchid = true,
    item_rod_of_atos = true,
    item_sheepstick = true,
    item_silver_edge = true,

    -- New
    item_health_bag = true,
}



tinker_rearm_fix = class({})


local particle = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
local sound = "Hero_Tinker.Rearm"


function tinker_rearm_fix:IsStealable()
	return false
end


function tinker_rearm_fix:GetChannelTime()
    if IsServer() then
        local caster = self:GetCaster()
        local channel = self:GetSpecialValueFor("channel_tooltip")

        local talent_value = talent_value(caster, "tinker_custom_bonus_unique_2")
        if talent_value ~= 0 then
            channel = channel + talent_value

            CustomNetTables:SetTableValue("heroes", "tinker_rearm_channel", {
                channel = channel
            })
        end

        return channel
    else
        local tinker_rearm_channel = CustomNetTables:GetTableValue("heroes", "tinker_rearm_channel")

        if tinker_rearm_channel then
            return tinker_rearm_channel.channel
        end

        return self:GetSpecialValueFor("channel_tooltip")
    end
end


function tinker_rearm_fix:OnSpellStart()
    local caster = self:GetCaster()

    caster:EmitSound(sound)
    self.fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(self.fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetOrigin(), true)
end


function tinker_rearm_fix:GetChannelAnimation()
    return ACT_DOTA_TINKER_REARM1
end


function tinker_rearm_fix:OnChannelFinish(interrupted)
    local caster = self:GetCaster()

    ParticleManager:DestroyParticle(self.fx, false)
    ParticleManager:ReleaseParticleIndex(self.fx)
    self.fx = nil

    caster:StopSound(sound)

    if not interrupted then
        self:RefreshCooldowns()
    end
end


function tinker_rearm_fix:RefreshCooldowns()
    local caster = self:GetCaster()

    refresh_abilities(caster, exclude_abilities)
    refresh_items(caster, exclude_items)
end

