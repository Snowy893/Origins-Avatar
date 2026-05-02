local periodical = require "lib.periodical"
local util = require "lib.util"

---@alias Origin.Sounds.Ambient {
---     sound: Sound,
---     minTicks: integer?,
---     maxTicks: integer?,
---     condition: (fun(): boolean)?,
---     pitch: number,
---}

---@alias Origin.Sounds.Hurt {
---     sound: Sound,
---     pitch: number?,
---}

---@alias Origin.Variant.Part {
---     part: ModelPart,
---     texture: Texture?,
---}

---@alias Origin.Variant {
---     parts: Origin.Variant.Part[]?,
---     name: string,
---     item: ItemStack|Minecraft.itemID,
---}

---@generic T
---@class Origin
---@field id string
---@field page Page?
---@field parts ModelPart[]?
---@field partsCoveredByArmor { [Entity.slot]: { [integer|Minecraft.itemID]: ModelPart } }?
---@field sounds { ambient: (Origin.Sounds.Ambient|Sound)?, hurt: (Origin.Sounds.Hurt|Sound)? }?
---@field tick fun()?
---@field render Event.Render.func?
---@field change fun(toggle: boolean)?
---@field variants Origin.Variant[]?
---@field squishy SquAPI<T>[]?
---@field currentVariant integer?
---@field hasAmbientParticles boolean?
---@field ALL { [string]: Origin }
local Origin = {}
Origin.__index = Origin
Origin.ALL = {}

function Origin:__newindex(key, value)
    if type(key) == "string" and key:lower() == "tick" then
        if not self.tickObjs then self.tickObjs = {} end
        table.insert(self.tickObjs, value)
        return
    end
    rawset(self, key, value)
end

---@param ambient Util.AmbientParticle
function Origin:newAmbientParticles(ambient)
    self.hasAmbientParticles = true
    local cond = ambient.condition
    if cond then
        function ambient.condition()
            return self.isOrigin and cond()
        end
    else
        function ambient.condition()
            return self.isOrigin
        end
    end
    util.newAmbientParticles(ambient)
end

---@param variant Origin.Variant
function Origin:addVariant(variant)
    if not self.variants then self.variants = {} end
    table.insert(self.variants, variant)
end

---@param toggle boolean
function Origin:setEnabled(toggle)
    self.isOrigin = toggle

    if self.parts then
        for _, part in ipairs(self.parts) do
            part:setVisible(toggle)
        end
    end

    if toggle then
        action_wheel:setPage(self.page)
    end

    if self.change then
        self.change(toggle)
    end
end

function Origin:checkArmorParts()
    if not self.partsCoveredByArmor then return end
    for slot, parts in pairs(self.partsCoveredByArmor) do
        local item = player:getItem(slot)
        local isWearing = item.id ~= "minecraft:air"
        for k, part in pairs(parts) do
            part:setVisible(not (type(k) ~= "string" and isWearing or item.id:find(k) ~= nil))
        end
    end
end

function Origin:squishyTick()
    if not self.squishy then return end
    for _, obj in ipairs(self.squishy) do
        if obj.tick then obj:tick() end ---@diagnostic disable-line: undefined-field
    end
end

---@param delta number
---@param context Event.Render.context
function Origin:squishyRender(delta, context)
    if not self.squishy then return end
    for _, obj in ipairs(self.squishy) do
        if obj.render then obj:render(delta, context) end ---@diagnostic disable-line: undefined-field
    end
end

function Origin:register()
    if host:isHost() and self.hasAmbientParticles then
        self.page = self.page or action_wheel:newPage()
        local bool = config:load("first_person_ambient_particles") or false
        self.page:newAction()
            :title("Disable First Person Ambient Particles")
            :item("minecraft:brush")
            :onToggle(function(state)
                config:save("first_person_ambient_particles", state)
                util.RENDER_AMBIENT_FIRST_PERSON = not state
            end)
            :toggled(bool)
            .toggle(bool)
    end

    if self.sounds.hurt then
        if type(self.sounds.hurt) == "Sound" then
            self.sounds.hurt = { sound = self.sounds.hurt }
        end
        local hurt = self.sounds.hurt
        hurt.pitch = hurt.pitch or hurt.sound:getPitch()
    end

    if self.sounds.ambient then
        if type(self.sounds.ambient) == "Sound" then
            self.sounds.ambient = { sound = self.sounds.ambient }
        end
        local ambient = self.sounds.ambient
        ambient.minTicks = ambient.minTicks or 1200
        ambient.maxTicks = ambient.maxTicks or 1800
        ambient.condition = ambient.condition or world.exists
        ambient.pitch = ambient.pitch or ambient.sound:getPitch()

        periodical.new(function()
            util.playSound(ambient.sound, ambient.pitch) ---@diagnostic disable-line: param-type-mismatch
        end):condition(function()
            return self.isOrigin and ambient.condition()
        end):timing(ambient.minTicks, ambient.maxTicks)
            :register()
    end

    if host:isHost() and self.variants then
        local variantActionWheel = action_wheel:newPage()

        if not self.page then
            self.page = variantActionWheel
        else
            util.switchPageActions(self.page, variantActionWheel)
        end

        self.currentVariant = config:load(self.id.."_current_variant")
        
        if not self.currentVariant or not self.variants[self.currentVariant] or type(self.currentVariant) ~= "number" then
            self.currentVariant = 1
            config:save(self.id.."_current_variant", self.currentVariant)
        end

        for i, variant in ipairs(self.variants) do
            variantActionWheel:newAction()
                :title(variant.name)
                :item(variant.item)
                :onLeftClick(function()
                    pings.setVariant(i) ---@diagnostic disable-line: param-type-mismatch
                    config:save(self.id.."_current_variant", i)
                    self.currentVariant = i
                end)
        end

        util.tick:register(function()
            if self.isOrigin then
                pings.setVariant(self.currentVariant) ---@diagnostic disable-line: param-type-mismatch
            end
        end, 120)
    end

    Origin.ALL[self.id] = self
end

---@param id string If no namespace is provided, assumes `"origins:<id>"`
---@return Origin
function Origin.new(id)
    local origin = setmetatable({}, Origin)

    origin.isOrigin = false
    origin.sounds = {}
    origin.numberToVariant = {}
    origin.variantToNumber = {}
    
    origin.id = not id:find(":", 2) and "origins:" .. id or id
    return origin
end

---@param layer "origins:origin"|"origins_backgrounds:background"
---@return Origin?
local function getCurrentOrigin(layer)
    local nbt = player:getNbt()
    local layers = nbt.cardinal_components
        and nbt.cardinal_components[layer]
        and nbt.cardinal_components[layer].OriginLayers
    local origin
    for _, v in ipairs(layers) do
        if v.Layer == layer then
            origin = v.Origin
            break
        end
    end
    return Origin.ALL[origin]
end

---@param variantID integer
function pings.setVariant(variantID)
    local origin = Origin.current
    if not origin or not origin.variants then return end
    local variant = origin.variants[variantID]

    if origin.lastVariant then
        local last = origin.variants[origin.lastVariant]
        if last.parts then
            for _, obj in ipairs(variant.parts) do
                obj.part:setVisible(false)
            end
        end
    end

    if variant.parts then
        for _, obj in ipairs(variant.parts) do
            obj.part:setVisible(true)
            if obj.texture then
                obj.part:setPrimaryTexture("CUSTOM", obj.texture)
            end
        end
    end

    origin.lastVariant = variantID
end

function events.entity_init()
    for _, origin in pairs(Origin.ALL) do
        origin:setEnabled(false)
    end
end

function util.tick()
    Origin.current = getCurrentOrigin("origins:origin")
    local origin = Origin.current

    if not origin then
        if Origin.last then
            Origin.last:setEnabled(false)
        end
        Origin.last = origin
        return
    end

    if origin ~= Origin.last then
        if Origin.last then
            Origin.last:setEnabled(false)
        end

        origin:setEnabled(true)

        if origin.currentVariant then
            pings.setVariant(origin.currentVariant) ---@diagnostic disable-line: param-type-mismatch
        end
    end

    origin:checkArmorParts()

    origin:squishyTick()

    if origin.tickObjs then
        for _, obj in ipairs(origin.tickObjs) do obj() end
    end

    Origin.last = origin
end

-- Thanks `manuel_2867` on the Figura Discord for original snippet!
-- https://discord.com/channels/1129805506354085959/1234218592187453452/1463663512520753227
function events.on_play_sound(id, pos, volume, pitch, loop, category, path)
    if not path then return
    elseif not Origin.current or not Origin.current.sounds.hurt then return
    elseif not player:isLoaded() then return end

    local nearest = math.huge
    local uuid

    for _, playr in pairs(world.getPlayers()) do
        local dist = (playr:getPos() - pos):length()
        if dist < nearest then
            nearest = dist
            uuid = playr:getUUID()
        end
    end

    if uuid ~= player:getUUID() or nearest > 0.8 then return end

    if id:find("player") and id:find("hurt") then
        ---@diagnostic disable-next-line: param-type-mismatch
        util.playSound(Origin.current.sounds.hurt.sound, Origin.current.sounds.hurt.pitch, pos)
    end
end

function events.render(delta, context, matrix)
    if Origin.current then
        if Origin.current.render then
            Origin.current.render(delta, context, matrix)
        end
        Origin.current:squishyRender(delta, context)
    end
end

return Origin
