local originsapi = require "lib.thirdparty.OriginsAPI"
local periodical = require "lib.periodical"
local util       = require "lib.util"

---@class Origins
---@field ALL { [string]: Origin }
local origins = {}

origins.ALL = {}

---@param id string
local function getOriginID(id)
    return not id:find(":", 2) and "origins:"..id or id
end

---@alias Origins.AmbientSound {
---     obj: Sound,
---     minTicks: integer?,
---     maxTicks: integer?,
---     condition: (fun(): boolean)?,
---}

---@alias Origins.Variant.TexturePart {
---     part: ModelPart,
---     texture: Texture,
---}

---@alias Origins.Variant {
---     textureParts: Origins.Variant.TexturePart[]?,
---     parts: ModelPart[]?,
---     name: string,
---     item: ItemStack|Minecraft.itemID,
---}

---@param id string If no namespace is provided, assumes `"origins:<id>"`
---@return Origin
function origins.new(id)
    ---@class Origin
    ---@field page Page
    ---@field parts ModelPart[]
    ---@field partsCoveredByArmor { [Entity.slot]: { [integer|Minecraft.itemID]: ModelPart } }
    ---@field emissive boolean|fun(): boolean
    ---@field emissiveBuffer (integer|0|{ on: integer, off: integer })?
    ---@field emissiveModelParts ModelPart[]
    ---@field isOrigin boolean
    ---@field sounds { ambient: Origins.AmbientSound?, hurt: Sound? }
    ---@field tick fun()?
    ---@field change fun(toggle: boolean)?
    ---@field variants { [string]: Origins.Variant }?
    local origin = {}
    origin.id = getOriginID(id)
    origin.isOrigin = false
    origin.emissiveModelParts = { models.model.root }
    origin.sounds = {}
    origin.variants = {}

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
    function origin.setPartsVisible(toggle)
        if not origin.parts then return end
        for _, part in ipairs(origin.parts) do
            part:setVisible(toggle)
        end
    end

    function origin.checkArmorParts()
        if not origin.partsCoveredByArmor then return end
        for slot, parts in pairs(origin.partsCoveredByArmor) do
            local item = player:getItem(slot)
            local isWearing = item.id ~= "minecraft:air"
            for k, part in pairs(parts) do
                part:setVisible(not (type(k) ~= "string" and isWearing or item.id:find(k) ~= nil))
            end
        end
    end

    ---@param toggle boolean
    function origin.setPartsEmissive(toggle)
        local renderType = toggle and "EYES" or "NONE"
        for _, part in ipairs(origin.emissiveModelParts) do
            part:setSecondaryRenderType(renderType)
        end
    end

    local function ambientSoundsInit()
        local ambient = origin.sounds.ambient
        ambient.minTicks = ambient.minTicks or 600
        ambient.maxTicks = ambient.maxTicks or 1200
        ambient.condition = ambient.condition or world.exists

        periodical.new(function()
            util.playSound(ambient.obj)
        end):condition(function()
            return origin.isOrigin and ambient.condition()
        end):timing(ambient.minTicks, ambient.maxTicks)
            :register()
    end

    local function emissiveBufferInit()
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
                    if onTimer == onBuffer or onBuffer == 0 then
                        wasEmissive = emissive
                        onTimer = 0
                    end
                    offTimer = 0
                else
                    offTimer = offTimer + 1
                    if offTimer == offBuffer or offBuffer == 0 then
                        wasEmissive = emissive
                        offTimer = 0
                    end
                    onTimer = 0
                end
            end

            return wasEmissive
        end
    end

    local function variantActionsInit()
        local variantActionWheel = action_wheel:newPage()
        if not origin.page then
            origin.page = variantActionWheel
        else
            util.switchPageActions(origin.page, variantActionWheel)
        end

        local currentVariant = config:load(origin.id.."_current_variant")

        if not currentVariant then
            for k, _ in pairs(origin.variants) do
                currentVariant = k
                break
            end
        end

        local lastVariant

        ---@param variantID string
        function pings.setVariant(variantID, lastVariantID)
            if lastVariantID then
                local last = origin.variants[lastVariantID]
                if last.parts then
                    for _, part in ipairs(last.parts) do
                        part:setVisible(false)
                    end
                end
                if last.textureParts then
                    for _, obj in ipairs(last.textureParts) do
                        obj.part:setVisible(false)
                    end
                end
            end
            local variant = origin.variants[variantID]
            if variant.parts then
                for _, part in ipairs(variant.parts) do
                    part:setVisible(true)
                end
            end
            if variant.textureParts then
                for _, obj in ipairs(variant.textureParts) do
                    obj.part:setVisible(true)
                    obj.part:setPrimaryTexture("CUSTOM", obj.texture)
                end
            end
            lastVariant = variantID
        end

        for k, variant in pairs(origin.variants) do
            variantActionWheel:newAction()
                :title(variant.name)
                :item(variant.item)
                :onLeftClick(function()
                    pings.setVariant(k, lastVariant)
                    config:save(origin.id.."_current_variant", k)
                end)
        end

        pings.setVariant(currentVariant, lastVariant)
    end

    function origin:init()
        if origin.sounds.ambient then
            ambientSoundsInit()
        end

        if emissiveFunc and origin.emissiveBuffer and origin.emissiveBuffer ~= 0 then
            emissiveBufferInit()
        end

        if host:isHost() and next(origin.variants) ~= nil then
            variantActionsInit()
        end
        
        origins.ALL[origin.id] = origin
    end

    return origin
end

local lastHealth = 20
function util.tick()
    local health = player:getHealth()
    local wasHurt = lastHealth > health

    for _, origin in pairs(origins.ALL) do
        origin.isOrigin = originsapi.hasOrigin(player, origin.id)

        if origin.wasOrigin ~= origin.isOrigin then
            wasHurt = false

            local emissive = origin.isOrigin and origin.emissive and type(origin.emissive) == "boolean"

            origin.setPartsVisible(origin.isOrigin)
            origin.setPartsEmissive(emissive)

            if origin.isOrigin then
                action_wheel:setPage(origin.page)
            end

            if origin.change then origin.change(origin.isOrigin) end
        end

        if origin.isOrigin then
            if type(origin.emissive) == "function" then
                local emissive = origin.emissive()
                if origin.wasEmissive ~= emissive then
                    origin.setPartsEmissive(emissive)
                end
                origin.wasEmissive = emissive
            end

            origin.checkArmorParts()

            if wasHurt and origin.sounds.hurt then
                util.playSound(origin.sounds.hurt)
            end

            if origin.tick then origin.tick() end
        end        

        origin.wasOrigin = origin.isOrigin
    end

    lastHealth = health
end

return origins
