local origins = require "origins.origins"

local blazeborn = origins.new("origins:blazeborn")

blazeborn.sound = {
    obj = sounds["minecraft:entity.blaze.burn"],
}

function blazeborn.emissive()
    return player:isOnFire()
end

blazeborn:init()