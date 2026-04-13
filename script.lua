local options = require "options"
local util = require "lib.util"

vanilla_model.PLAYER:setVisible(false)
models.model.root.Cape:setVisible(options.ENABLE_CAPE)

if options.USE_VANILLA_SKIN then
    for _, part in ipairs(util.vanillaCubes) do
        part:setPrimaryTexture("SKIN")
    end

    local modelType

    function events.entity_init()
        modelType = player:getModelType() == "DEFAULT"
        models.model.root.LeftArm.wideLeftArm:setVisible(modelType)
        models.model.root.RightArm.wideRightArm:setVisible(modelType)
        models.model.root.LeftArm.slimLeftArm:setVisible(not modelType)
        models.model.root.RightArm.slimRightArm:setVisible(not modelType)
    end

    util.tick:register(function()
        local type = player:getModelType() == "DEFAULT"
        if modelType ~= type then
            models.model.root.LeftArm.wideLeftArm:setVisible(modelType)
            models.model.root.RightArm.wideRightArm:setVisible(modelType)
            models.model.root.LeftArm.slimLeftArm:setVisible(not modelType)
            models.model.root.RightArm.slimRightArm:setVisible(not modelType)
        end
        modelType = type
    end, 100)
end

if options.USE_VANILLA_CAPE_TEXTURE then
    function events.entity_init()
        if player:hasCape() then
            models.model.root.Cape:setPrimaryTexture("CAPE")
            models.model.root.Elytra:setPrimaryTexture("CAPE")
        else
            models.model.root.Elytra:setPrimaryTexture("ELYTRA")
        end
    end
end

if options.NAME == "NAME HERE" then options.NAME = "${name}" end
nameplate.ALL:setText(toJson {
    text = options.NAME,
    color = "#"..vectors.rgbToHex(options.RGB / 255),
})

---@param hand Hand
local function crouchHandOffset(hand)
    local rightRot = (hand and hand.RIGHT) and 20 or nil
    local leftRot = (hand and hand.LEFT) and 20 or nil
    vanilla_model.RIGHT_ARM:setOffsetRot(rightRot)
    vanilla_model.LEFT_ARM:setOffsetRot(leftRot)
end

local lastCrouchHand ---@type Hand
function util.tick()
    local crouching = player:isCrouching()
    local useAction = player:getActiveItem():getUseAction()
    local leftHanded = player:isLeftHanded()

    local crouchHand ---@type Hand
    local singleCrouchHand ---@type Hand?
    local doubleCrouchhand ---@type Hand?

    if crouching then
        if useAction == "BOW" then
            doubleCrouchhand = { RIGHT = true, LEFT = true}
        elseif util.compare(useAction, "TOOT_HORN", "SPEAR", "BLOCK") then
            local mainHandActive = player:getActiveHand() == "MAIN_HAND"
            singleCrouchHand = mainHandActive ~= leftHanded and { RIGHT = true } or { LEFT = true }
        else
            local rightItem = player:getHeldItem(leftHanded)
            local leftItem = player:getHeldItem(not leftHanded)
            if util.crossbowCharged(rightItem) or util.crossbowCharged(leftItem) then
                doubleCrouchhand = { RIGHT = true, LEFT = true }
            end
        end
    end

    crouchHand = singleCrouchHand or doubleCrouchhand

    if lastCrouchHand ~= crouchHand then
        crouchHandOffset(crouchHand)
        lastCrouchHand = crouchHand
    end
end