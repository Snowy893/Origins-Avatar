local util = require "lib.util"
local wobblelib = require "lib.thirdparty.CMwubLib"
local originsapi = require "lib.thirdparty.OriginsAPI"

---@class Origins
---@field ALL Origin[]
local origins = {}

origins.ALL = {}

---@type ItemTask[]
local bodyItemTasks = {}

---@param item ItemStack?
---@param slot integer
function pings.items(item, slot)
    local rand = math.random(-4, 4)
    bodyItemTasks[slot + 1]
        :setItem(item)
        :setScale(0.25, 0.25, 0.25)
        :setPos(rand, rand, rand / 2)
        :setRot(rand * 6, rand * 6, rand * 6)
end

if host:isHost() then
    local inventory = {}
    local oldInventory = {}

    function events.tick()
        if originsapi.hasPower(player, "gangsmputil:slime_storage") then
            if host:getScreen() == "net.minecraft.class_480" then
                for i = 0, 8 do
                    inventory[i] = host:getScreenSlot(i).id
                    if inventory[i] ~= oldInventory[i] then
                        pings.items(inventory[i], i)
                    end
                    oldInventory[i] = inventory[i]
                end
            end
            if world.getTime() % 80 then
                for i = 0, 8 do
                    pings.items(inventory[i], i)
                end
            end
        end
    end
end

local function setEmissive(toggle, origin)
    local renderType
    if toggle then renderType = "EYES" else renderType = "NONE" end
    for _, part in pairs(origin.emissiveModelParts) do
        part:setSecondaryRenderType(renderType)
    end
end

---@param toggle boolean
---@param origin Origin
local onOriginChange = util.onchange(function(toggle, _, origin)
    if origin.modelParts then
        for _, part in pairs(origin.modelParts) do part:setVisible(toggle) end
    end
    if toggle then
        if origin.page then
            action_wheel:setPage(origin.page)
        end
        if type(origin.emissive) == "boolean" and origin.emissive then
            setEmissive(true, origin)
        end
    else
        setEmissive(false, origin)
    end
    if originsapi.hasPower(player, "gangsmputil:slime_storage") then
        for i = 1, 9 do
            bodyItemTasks[i] = models.model.root.upperBody.Body:newItem("Item " .. i)
        end
    else
        for i = 1, 9 do
            bodyItemTasks[i] = nil
            models.model.root.upperBody.Body:removeTask("Item " .. i)
        end
    end
end)

---@param id string
---@return Origin
function origins:new(id)
    ---@class Origin
    ---@field page Page
    ---@field modelParts ModelPart[]
    ---@field emissive boolean | function
    ---@field emissiveModelParts ModelPart[]
    local origin = {}
    origin.id = id
    origin.emissive = false
    origin.emissiveModelParts = { models.model.root }

    ---@param toggle boolean
    origin.onEmissiveConditionChange = util.onchange(function (toggle)
        setEmissive(toggle, origin)
    end)

    ---@param func? function
    function origin:init(func)
        origin.func = func
        table.insert(origins.ALL, origin)
    end

    return origin
end

---@param modelPart ModelPart
---@param wobbleStrength? number
---@param crouchWobbleStrength? number
---@param wobbleStrengthX? number
---@param wobbleStrengthY? number
---@param wobbleStrengthZ? number
function origins:wobble(modelPart, wobbleStrength, crouchWobbleStrength,
                        wobbleStrengthX, wobbleStrengthY, wobbleStrengthZ)
    local bodyWobble = wobblelib:newWobbleSetup() --Creates a Wobble Setup to use in the script
    local wasCrouching = false                     --Checks if the first frame of you crouching/uncrouching has passed or not

    local wobble = wobbleStrength or 0.4
    local wobbleX = wobbleStrengthX or wobble / 2
    local wobbleY = wobbleStrengthY or wobble
    local wobbleZ = wobbleStrengthZ or wobble / 2
    local wobbleCrouch = crouchWobbleStrength or 0.4

    local enabled = false

    local interface = {}

    ---@param bool boolean
    function interface:setEnabled(bool)
        enabled = bool
        if not enabled then modelPart:setScale(1, 1, 1) end
    end

    -- bodyWobble.s = 0.08 --Speed
    -- bodyWobble.d = 0.08 --Dampener

    function events.WORLD_RENDER()                                                --Run code every frame the minecraft world renders
        if player:isLoaded() and enabled then                                     --If the player is loaded
            bodyWobble:update(player:getVelocity().y, true)       --Update the "bodyWobble" wobbleSetup to follow the player's Y velocity
            modelPart:setScale(                                                   --And set the model's scale based on "bodyWobble"'s "wobble" variable
                1 + bodyWobble.wobble * wobbleX,
                1 - bodyWobble.wobble * wobbleY,
                1 + bodyWobble.wobble * wobbleZ
            )
            if player:isCrouching() and not wasCrouching then                 --Checks if it's the player's first frame crouching
                bodyWobble:setWobble(wobbleCrouch, wobbleCrouch, wobbleCrouch)    --If it is, it sets "bodyWobble"'s "wobble", "wobbleVel" and "wobbleAccel" variables to 0.4
                wasCrouching = true                                                --And sets isCrouching to 'true' for the one frame check to work
            elseif not player:isCrouching() and wasCrouching then          --Checks if it's the player's first frame uncrouching
                bodyWobble:setWobble(-wobbleCrouch, -wobbleCrouch, -wobbleCrouch) --If it is, it sets "bodyWobble"'s "wobble", "wobbleVel" and "wobbleAccel" variables to -0.4
                wasCrouching = false                                               --And sets isCrouching to 'false' for the one frame check to work
            end
        end
    end

    return interface
end

events.TICK:register(function()
    local time = world.getTime()
    for i, origin in ipairs(origins.ALL) do
        if (time + i) % 5 == 0 then
            local isOrigin = originsapi.hasOrigin(player, origin.id)
            onOriginChange(isOrigin, origin)
            if isOrigin and type(origin.emissive) == "function" then
                origin.onEmissiveConditionChange(origin.emissive())
            end
            if origin.func ~= nil then origin.func(isOrigin) end
        end
    end
end)

return origins
