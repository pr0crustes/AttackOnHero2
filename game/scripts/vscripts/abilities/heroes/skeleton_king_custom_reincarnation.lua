LinkLuaModifier("modifier_skeleton_king_custom_reincarnation", "abilities/heroes/skeleton_king_custom_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)



skeleton_king_custom_reincarnation = class({})


function skeleton_king_custom_reincarnation:GetIntrinsicModifierName()
    return "modifier_skeleton_king_custom_reincarnation"
end


if IsClient() then
    function skeleton_king_custom_reincarnation:GetManaCost()
        if self:GetLevel() > 0 then
            return self:GetCaster():GetMana()
        end
	end
end



modifier_skeleton_king_custom_reincarnation = class({})


function modifier_skeleton_king_custom_reincarnation:IsHidden()
    return true
end


function modifier_skeleton_king_custom_reincarnation:IsPurgable()
    return false
end


if IsServer() then
    function modifier_skeleton_king_custom_reincarnation:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_MIN_HEALTH,
        }
        return funcs
    end


    function modifier_skeleton_king_custom_reincarnation:OnTakeDamage(keys)
        local unit = keys.unit
        local ability = self:GetAbility()

        -- nested ifs so it is clear.
        if unit == self:GetParent() and not unit:IsIllusion() then
            if ability:IsCooldownReady() and unit:GetHealth() <= 1 then
                ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
                unit:SpendMana(unit:GetMana(), ability)
                unit:SetHealth(unit:GetMaxHealth())

                unit:EmitSound("Hero_SkeletonKing.Reincarnate")
                unit:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
                unit:EmitSound("Hero_SkeletonKing.Reincarnate.Ghost")
            end
        end
    end


    function modifier_skeleton_king_custom_reincarnation:GetMinHealth(keys)
        local parent = self:GetParent()
        if not parent:IsIllusion() then
            local ability = self:GetAbility()
            if ability:IsCooldownReady() then
                return 1
            end
        end
    end
end
