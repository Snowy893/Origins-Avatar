local originsapi = require "lib.thirdparty.OriginsAPI"
local periodical = require "lib.periodical"

---@class Origins
---@field ALL { [string]: Origin }
local origins = {}

origins.ALL = {}

---@param id string
---@return Origin
function origins.new(id)
    ---@class Origin
    ---@field page Page
    ---@field modelParts ModelPart[]
    ---@field armorParts { [Entity.slot]: ModelPart[] }
    ---@field emissive boolean|fun(): boolean
    ---@field emissiveBuffer (integer|0|{ on: integer, off: integer })?
    ---@field emissiveModelParts ModelPart[]
    ---@field isOrigin boolean
    ---@field sound { obj: Sound, minTicks: integer?, maxTicks: integer? }?
    ---@field tick fun()?
    local origin = {}
    origin.id = id
    origin.emissiveModelParts = { models.model.root }
    origin.isOrigin = false
    origin.emissiveBuffer = 100

    local originmt = {}
    setmetatable(origin, originmt)

    local emissiveFunc
    
    function originmt:__newindex(key, value)
        if key == "emissive" and type(value) == "function" then
            emissiveFunc = value
        end
        rawset(self, key, value)
    end

    ---@param toggle boolean
    function origin.partsVisible(toggle)
        if not origin.modelParts then return end
        for _, part in ipairs(origin.modelParts) do
            part:setVisible(toggle)
        end
    end

    function origin.checkArmorParts()
        if not origin.armorParts then return end
        for slot, parts in pairs(origin.armorParts) do
            for _, part in ipairs(parts) do
                part:setVisible(player:getItem(slot).id == "minecraft:air")
            end
        end
    end

    ---@param toggle boolean
    function origin.partsEmissive(toggle)
        local renderType = toggle and "EYES" or "NONE"
        for _, part in ipairs(origin.emissiveModelParts) do
            part:setSecondaryRenderType(renderType)
        end
    end

    function origin:init()

        if origin.sound then
            origin.sound.minTicks = origin.sound.minTicks or 600
            origin.sound.maxTicks = origin.sound.maxTicks or 1200
            local pitch = origin.sound.obj:getPitch()

            periodical.new(function()
                origin.sound.obj:stop()
                origin.sound.obj:pitch(math.random(pitch - 0.1, pitch + 0.1))
                origin.sound.obj:pos(player:getPos())
                origin.sound.obj:play()
            end):condition(function()
                return origin.isOrigin
            end):timing(origin.sound.minTicks, origin.sound.maxTicks)
                :register()
        end

        if emissiveFunc and origin.emissiveBuffer and origin.emissiveBuffer ~= 0 then
            local onBuffer
            local offBuffer

            if type(origin.emissiveBuffer) == "table" then
                onBuffer = origin.emissiveBuffer.on
                offBuffer = origin.emissiveBuffer.off
            else
                onBuffer = origin.emissiveBuffer
                offBuffer = onBuffer
            end

            local onTimer = 0
            local offTimer = 0
            local wasEmissive

            function origin.emissive()
                local emissive = emissiveFunc()

                if wasEmissive ~= emissive then
                    if emissive then
                        onTimer = onTimer + 1
                        if onTimer == onBuffer then
                            wasEmissive = emissive
                            onTimer = 0
                        end
                        offTimer = 0
                    else
                        offTimer = offTimer + 1
                        if offTimer == offBuffer then
                            wasEmissive = emissive
                            offTimer = 0
                        end
                        onTimer = 0
                    end
                end

                return wasEmissive
            end

            function events.entity_init()
                if not origin.isOrigin then return end

                local emissive = emissiveFunc()
                origin.partsEmissive(emissive)
                wasEmissive = emissive
            end
        end
        
        origins.ALL[origin.id] = origin
    end

    return origin
end

function events.tick()
    for _, origin in pairs(origins.ALL) do
        origin.isOrigin = originsapi.hasOrigin(player, origin.id)

        if origin.wasOrigin ~= origin.isOrigin then
            local emissive = origin.isOrigin and origin.emissive and type(origin.emissive) == "boolean"

            origin.partsVisible(origin.isOrigin)
            origin.partsEmissive(emissive)

            if origin.isOrigin and origin.page then
                action_wheel:setPage(origin.page)
            end
        end

        if origin.isOrigin then
            if type(origin.emissive) == "function" then
                local emissive = origin.emissive()
                if origin.wasEmissive ~= emissive then
                    origin.partsEmissive(emissive)
                end
                origin.wasEmissive = emissive
            end

            origin.checkArmorParts()
        end

        if origin.tick then origin.tick() end

        origin.wasOrigin = origin.isOrigin
    end
end

return origins
