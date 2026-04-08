local util = require "lib.util"

local options = {}

---------------------------------------------------------------------------------

-- Replace your name with whatever you like! ("NAME HERE" will put your Minecraft username)
options.name = "NAME HERE"
-- Replace the first, second, and third numbers with red, green, and blue values of your choosing.
-- Use a color picker and get the rgb values from a color you like: https://htmlcolorcodes.com/color-picker/
options.rgb = vec(255, 255, 255)

-- Set this to false if you want to use the skin texture in the blockbench model.
options.USE_VANILLA_SKIN = true
options.USE_VANILLA_CAPE_TEXTURE = true
options.ENABLE_CAPE = false

-- Set this to false if you want to disable your origin's ambient particles in first person.
util.RENDER_AMBIENT_FIRST_PERSON = true

options.ENABLE_SLIME_WOBBLE = true
options.WOBBLE_PART = models.model.root
options.ENABLE_SLIME_TRANSPARENCY = true
options.SLIME_TRANSPARENCY = 0.9 -- Decimal number between 0.3 and 1. 1 is fully opaque.
options.TRANSPARENT_PART = models.model.root

---------------------------------------------------------------------------------

return options