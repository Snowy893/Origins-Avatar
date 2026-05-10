local options = require "options"
local name = require "name"
local util = require "lib.util"
local colorlib = require "lib.colorlib"
local runLater = require "lib.thirdparty.runLater"

vanilla_model.PLAYER:setVisible(false)
models.model.root.Cape:setVisible(options.ENABLE_CAPE)

if options.USE_VANILLA_SKIN then
    for _, part in ipairs(util.vanillaCubes) do
        part:setPrimaryTexture("SKIN")
    end

    local function checkArms()
        local isWide = player:getModelType() == "DEFAULT"
        models.model.root.LeftArm.wideLeftArm:setVisible(isWide)
        models.model.root.RightArm.wideRightArm:setVisible(isWide)
        models.model.root.LeftArm.slimLeftArm:setVisible(not isWide)
        models.model.root.RightArm.slimRightArm:setVisible(not isWide)
    end

    events.entity_init:register(checkArms)
    runLater(60, checkArms)
    util.tick:register(checkArms, 300)
end

if options.USE_VANILLA_CAPE_TEXTURE then
    local function updateCape()
        if player:hasCape() then
            models.model.root.Cape:setPrimaryTexture("CAPE")
            models.model.root.Elytra:setPrimaryTexture("CAPE")
        else
            models.model.root.Elytra:setPrimaryTexture("ELYTRA")
        end
    end

    events.entity_init:register(updateCape)
    runLater(60, updateCape)
    util.tick:register(updateCape, 600)
end

function events.entity_init()
    if name.TEXT == "NAME HERE" then name.TEXT = "${name}" end

    nameplate.ALL:setText(toJson {
        text = name.TEXT,
        color = "#"..vectors.rgbToHex(name.RGB / 255),
    })

    local outline = name.OUTLINE_RGB

    if name.AUTO_OUTLINE then
        outline = colorlib.lighten(name.RGB, name.AUTO_OUTLINE_OFFSET)
    end
    
    nameplate.ENTITY:setOutline(name.ENABLE_OUTLINE)
    nameplate.ENTITY:setOutlineColor(outline / 255)
end

function util.tick()
    local crouching = player:isCrouching()
    local useAction = player:getActiveItem():getUseAction()
    local leftHanded = player:isLeftHanded()

    local crouchHand = {} ---@type Hand
    local miniCrossbowHand = {} ---@type Hand
    local rightArmRot = vectors.vec3(0, 0, 0)
    local leftArmRot = vectors.vec3(0, 0, 0)

    if crouching and useAction == "BOW" then
        crouchHand.RIGHT = true
        crouchHand.LEFT = true
    elseif crouching and util.compare(useAction, "TOOT_HORN", "SPEAR", "BLOCK") then
        local mainHandActive = player:getActiveHand() == "MAIN_HAND"
        if mainHandActive ~= leftHanded then
            crouchHand.RIGHT = true
        else
            crouchHand.LEFT = true
        end
    else
        local rightItem = player:getHeldItem(leftHanded)
        local leftItem = player:getHeldItem(not leftHanded)
        local rightItemCharged = util.crossbowCharged(rightItem)
        local leftItemCharged = util.crossbowCharged(leftItem)
        if rightItemCharged or leftItemCharged then
            if rightItemCharged and leftItemCharged and util.compareall("hunters_return:mini_crossbow", rightItem.id, leftItem.id) then
                miniCrossbowHand.RIGHT = true
                miniCrossbowHand.LEFT = true
            end
            crouchHand.RIGHT = crouching
            crouchHand.LEFT = crouching
        elseif crouching then
            crouchHand.RIGHT = rightItem.id == "originsumbrellas:umbrella"
            crouchHand.LEFT = leftItem.id == "originsumbrellas:umbrella"
        end
    end

    rightArmRot.x = crouchHand.RIGHT and 20 or 0
    leftArmRot.x = crouchHand.LEFT and 20 or 0
    rightArmRot.y = leftHanded and miniCrossbowHand.RIGHT and -15 or 0
    leftArmRot.y = not leftHanded and miniCrossbowHand.LEFT and 15 or 0

    vanilla_model.RIGHT_ARM:setOffsetRot(rightArmRot)
    vanilla_model.LEFT_ARM:setOffsetRot(leftArmRot)
end

if host:isHost() then
    local rightItemPart = models.model.ItemRight:setPos(10.1, 0, 1.8):setRot(0, -10, 0)
    local rightItem = rightItemPart:newItem("rightItem")
        :setDisplayMode("FIRST_PERSON_RIGHT_HAND")
        :setRot(0, 180, 0)
    local leftItemPart = models.model.ItemLeft:setPos(-10.1, 0, 1.8):setRot(0, 10, 0)
    local leftItem = leftItemPart:newItem("leftItem")
        :setDisplayMode("FIRST_PERSON_LEFT_HAND")
        :setRot(0, 180, 0)

    function events.item_render(item, mode, _, _, _, lefthanded)
        if not player:isLoaded() then return end
        if not mode:find("FIRST_PERSON") then return end

        if player:isLeftHanded() == lefthanded and item.id == "hunters_return:mini_crossbow" then
            local part = lefthanded and leftItemPart or rightItemPart
            local task = lefthanded and leftItem or rightItem
            task:setItem(item)
            return part
        end
    end

    if options.ENABLE_LOCAL_AVATAR_WARNING and not host:isAvatarUploaded() then
        runLater(200, function()
            log("Your avatar is not uploaded, meaning other players cannot see it!")
        end)
    end
end