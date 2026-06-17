local util = require "lib.util"

local options = {}
options.SLIME = {}
options.STRIDER = {}

---------------------------------------------------------------------------------

options.USE_VANILLA_SKIN = true -- Set this to false if you want to use the skin texture in the blockbench model.
options.USE_VANILLA_CAPE_TEXTURE = true
options.ENABLE_CAPE = false

options.ENABLE_LOCAL_AVATAR_WARNING = true

-- SLIME
options.SLIME.ENABLE_WOBBLE = true
options.SLIME.WOBBLE_PARTS = { models.model.root }
options.SLIME.ENABLE_TRANSPARENCY = true
options.SLIME.TRANSPARENCY = 0.98 -- Decimal number between 0.3 and 1. 1 is fully opaque.
options.SLIME.TRANSPARENT_PARTS = util.vanillaCubes
options.SLIME.PARTICLE_COLOR = vec(255, 255, 255)

-- STRIDER
options.STRIDER.ENABLE_SHIVER = true -- Will only shiver in biomes colder than `minecraft:plains` (aka below temperature 0.8)

---------------------------------------------------------------------------------

return options