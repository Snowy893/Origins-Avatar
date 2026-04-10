local util = require "lib.util"

local options = {}
options.SLIME = {}
options.STRIDER = {}

---------------------------------------------------------------------------------

-- Replace your name with whatever you like! ("NAME HERE" will put your Minecraft username)
options.NAME = "NAME HERE"
-- Replace the first, second, and third numbers with red, green, and blue values of your choosing.
-- Use a color picker and get the rgb values from a color you like: https://htmlcolorcodes.com/color-picker/
options.RGB = vec(255, 255, 255)

-- Set this to false if you want to use the skin texture in the blockbench model.
options.USE_VANILLA_SKIN = true
options.USE_VANILLA_CAPE_TEXTURE = true
options.ENABLE_CAPE = false

-- Set this to false if you want to disable your origin's ambient particles in first person.
util.RENDER_AMBIENT_FIRST_PERSON = true

-- SLIME
options.SLIME.ENABLE_WOBBLE = true
options.SLIME.WOBBLE_PARTS = { models.model.root }
options.SLIME.ENABLE_TRANSPARENCY = true
options.SLIME.TRANSPARENCY = 0.9 -- Decimal number between 0.3 and 1. 1 is fully opaque.
options.SLIME.TRANSPARENT_PARTS = util.vanillaCubes
options.SLIME.TINT = vec(255, 255, 255)
options.SLIME.LAND_PARTICLE_COLOR = vec(255, 255, 255)

-- STRIDER
options.STRIDER.ENABLE_SHIVER = true -- Will only shiver in biomes colder than `minecraft:plains` (aka below temperature 0.8)

---------------------------------------------------------------------------------

return options