local name = {}

---------------------------------------------------------------------------------

-- Replace your name with whatever you like! ("NAME HERE" will put your Minecraft username)
name.TEXT = "NAME HERE"

-- Replace the first, second, and third numbers with red, green, and blue values of your choosing.
-- Use a color picker and get the rgb values from a color you like: https://htmlcolorcodes.com/color-picker/
name.RGB = vec(255, 255, 255)

name.ENABLE_OUTLINE = true

-- If true, automatically picks a color for the outline based off of `name.RGB`.
-- If false, will use `name.OUTLINE_RGB`.
name.AUTO_OUTLINE = true

-- The offset from the color of `name.RGB` for the auto outline.
-- Positive means lighter, negative means darker.
name.AUTO_OUTLINE_OFFSET = -25

-- Replace the first, second, and third numbers with red, green, and blue values of your choosing.
-- Won't do anything if `name.AUTO_OUTLINE` is set to true.
name.OUTLINE_RGB = vec(255, 255, 255)

---------------------------------------------------------------------------------

return name