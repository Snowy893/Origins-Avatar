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

---@param hand Hand
local function crouchHandOffset(hand)
    local rightRot = hand.RIGHT and 20 or nil
    local leftRot = hand.LEFT and 20 or nil
    vanilla_model.RIGHT_ARM:setOffsetRot(rightRot)
    vanilla_model.LEFT_ARM:setOffsetRot(leftRot)
end

local lastCrouchHand = {} ---@type Hand
function util.tick()
    local crouching = player:isCrouching()
    local useAction = player:getActiveItem():getUseAction()
    local leftHanded = player:isLeftHanded()

    local crouchHand = {} ---@type Hand

    if crouching then
        if useAction == "BOW" then
            crouchHand.RIGHT = true
            crouchHand.LEFT = true
        elseif util.compare(useAction, "TOOT_HORN", "SPEAR", "BLOCK") then
            local mainHandActive = player:getActiveHand() == "MAIN_HAND"
            if mainHandActive ~= leftHanded then
                crouchHand.RIGHT = true
            else
                crouchHand.LEFT = true
            end
        else
            local rightItem = player:getHeldItem(leftHanded)
            local leftItem = player:getHeldItem(not leftHanded)
            if util.crossbowCharged(rightItem) or util.crossbowCharged(leftItem) then
                crouchHand.RIGHT = true
                crouchHand.LEFT = true
            else
                if rightItem.id == "originsumbrellas:umbrella" then
                    crouchHand.RIGHT = true
                end
                if leftItem.id == "originsumbrellas:umbrella" then
                    crouchHand.LEFT = true
                end
            end
        end
    end

    if lastCrouchHand.RIGHT ~= crouchHand.RIGHT or lastCrouchHand.LEFT ~= crouchHand.LEFT then
        crouchHandOffset(crouchHand)
        lastCrouchHand = crouchHand
    end
end

if options.ENABLE_LOCAL_AVATAR_WARNING and host:isHost() and not host:isAvatarUploaded() then
    runLater(300, function()
        log("Your avatar is not uploaded, meaning other players cannot see it!")
    end)
end