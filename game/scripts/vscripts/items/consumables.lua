require("lib/my")



function item_consumable_used(keys)
    EmitSoundOn("Item.MoonShard.Consume", keys.caster)
    consumable_used(keys.caster, keys.ability, keys.modifier)
end
