local origins = require "origins.origins"

local enderian = origins.new("origins:enderian")

enderian.sound = {
    obj = sounds["minecraft:entity.enderman.ambient"]:volume(0.75),
}

enderian.emissive = true

enderian:init()