---@alias Util.ArrowTick.func fun(arrow: Entity): hide: boolean?
---@class Util
---@field tick function | { register: fun(self: table, func: function, ticks: integer?) }
---@field TICK function | { register: fun(self: table, func: function, ticks: integer?) }
---@field arrow_tick Util.ArrowTick.func | { register: fun(self: table, func: Util.ArrowTick.func, ticks: integer?) }
---@field ARROW_TICK Util.ArrowTick.func | { register: fun(self: table, func: Util.ArrowTick.func, ticks: integer?) }
local util = {}
local utilmt = {}
setmetatable(util, utilmt)

local tickObjs = {}
local arrowTickObjs = {}
local arrows = {}

utilmt.__index = setmetatable(
    {
        tick = {},
        arrow_tick = {},
    },
    {
        __index = function(self, key)
            if type(key) == "string" then
                return rawget(self, key:lower())
            end
        end,
    }
)

function utilmt:__newindex(key, value)
    local event
    if type(key) == "string" then event = key:lower() end
    if event and event == "tick" or event == "arrow_tick" then
        self[event]:register(value, 1)
        return
    end
    rawset(self, key, value)
end

---@param func function
---@param ticks integer?
function util.tick:register(func, ticks)
    table.insert(tickObjs, { func = func, ticks = ticks, timer = 0 })
end

---@param func fun(arrow: Entity): hide: boolean?
---@param ticks integer?
function util.arrow_tick:register(func, ticks)
    table.insert(arrowTickObjs, { func = func, ticks = ticks })
end

function events.arrow_render(_, arrow)
    local uuid = arrow:getUUID()
    arrows[uuid] = arrows[uuid] or { timer = 0, shouldHide = false }
    return arrows[uuid].shouldHide
end

function events.tick()
    for _, obj in ipairs(tickObjs) do
        if obj.ticks == 1 then
            obj.func()
        else
            obj.timer = obj.timer + 1
            if obj.timer == obj.ticks then
                obj.timer = 0
                obj.func()
            end
        end
    end
    for uuid, arrow in pairs(arrows) do
        local entity = world.getEntity(uuid)
        if entity then
            arrow.timer = arrow.timer + 1
            for _, obj in ipairs(arrowTickObjs) do
                if arrow.timer % obj.ticks == 0 then
                    arrows[uuid].shouldHide = obj.func(entity)
                end
            end
        else
            arrows[uuid] = nil
        end
    end
end

---@generic T
---@param func fun(value, oldValue, ...: T)
---@param initialValue? any
---@return fun(value, ...: T)
---@nodiscard
function util.onchange(func, initialValue)
    local oldValue = initialValue
    return function(value, ...)
        if oldValue ~= value then
            func(value, oldValue, ...)
        end
        oldValue = value
    end
end

if not toboolean then
    ---Returns an explicit boolean value out of a value that is truthy or falsy
    ---@param value any
    ---@return boolean
    ---@nodiscard
    function toboolean(value)
        return value and true or false
    end
end

if not table.find then
    ---@param tbl table
    ---@param value any
    ---@nodiscard
    function table.find(tbl, value)
        local isTable = type(value) == "table"
        for _, v in pairs(tbl) do
            if value == v or (isTable and type(v) == "table" and util.comparetables(value, v)) then
                return true
            end
        end
    end
end

---@generic T
---@param value T
---@param ... T
---@return T?
function util.compare(value, ...)
    for _, v in pairs({ ... }) do
        if v == value then return value end
    end
    return nil
end

---@param val1 any
---@param val2 any
---@return type|nil
---@nodiscard
function util.comparetype(val1, val2)
    local t = type(val1)
    return t == type(val2) and t or nil
end

---@param tbl1 table
---@param tbl2 table
---@return boolean
---@nodiscard
function util.comparetables(tbl1, tbl2)
    for k, v in pairs(tbl1) do
        if util.comparetype(tbl2[k], v) then
            if not util.comparetables(tbl2[k], v) then
                return false
            end
        elseif tbl2[k] ~= v then
            return false
        end
    end
    return true
end

---@param tbl { [any]: function }?
---@param mtbl table?
---@return table
---@nodiscard
function util.functiontable(tbl, mtbl)
    local t = tbl or {}
    local mt = mtbl or {}
    function mt:__call(...)
        for _, func in pairs(self) do func(...) end
    end

    return setmetatable(t, mt)
end

---Thanks `user973713` on stackoverflow!
---@param input string
---@param separator string
---@return string[]
---@nodiscard
function util.splitstring(input, separator)
    local sep = separator or "%s"
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---Properly checks if a table is a table, even if it has set its type with `__type`
---@param tbl table
function util.istable(tbl)
    local t = type(tbl)
    return t ~= "nil" and t ~= "number" and t ~= "string" and t ~= "boolean" and t ~= "function"
end

---@param tbl table
---@return table
function util.deepcopy(tbl)
    local t = {}
    for key, value in pairs(tbl) do
        if util.istable(value) then
            t[key] = util.deepcopy(value)
        else
            t[key] = value
        end
    end
    return t
end

---@generic T
---@param tbl T
---@return T
function util.index(tbl)
    local mt = {}
    function mt:__index()
        return self
    end
    return setmetatable(tbl, mt)
end

---@param func function
---@param args ...
function util.bind(func, args)
    return function()
        func(args)
    end
end

------------------------------------------------------------------------------

---@param key any
---@param default any
---@return any
---@nodiscard
function util.getOrDefault(key, default)
    local value = config:load(key)
    if value ~= nil then
        return value
    else
        return default
    end
end

local permissionLevels = {
    BLOCKED = 0,
    LOW = 1,
    DEFAULT = 2,
    HIGH = 3,
    MAX = 4,
}

---Returns true if the current permission level is greater than or equal to the input permission level
---@overload fun(targetLevel: AvatarAPI.permissionLevel): boolean
---@param targetLevel AvatarAPI.permissionLevel
---@param currentLevel AvatarAPI.permissionLevel
---@return boolean
---@nodiscard
function util.comparePermissionLevel(targetLevel, currentLevel)
    local level = currentLevel or avatar:getPermissionLevel()
    return permissionLevels[level] >= permissionLevels[targetLevel]
end

---@param fromPage Page
---@param toPage Page
---@param title string?
---@param item (ItemStack|Minecraft.itemID)?
---@return Action, Action
function util.switchPageActions(fromPage, toPage, title, item)
    return
        fromPage:newAction()
            :title(title)
            :item(item)
            :setOnLeftClick(function() action_wheel:setPage(toPage) end),
        toPage:newAction()
            :title("Back")
            :item("minecraft:barrier")
            :setOnLeftClick(function() action_wheel:setPage(fromPage) end)
end

---@param playr Player?
---@return boolean
---@nodiscard
function util.handsEmpty(playr)
    local p = playr or player
    return p:getHeldItem():getCount() == 0 and p:getHeldItem(true):getCount() == 0
end

---`:getTags()` returns the item tags, `:getTag()` or `.tag` returns data components
---@param itemStack ItemStack
---@return table?
---@nodiscard
function util.getProjectiles(itemStack)
    local projectiles = itemStack:getTag().ChargedProjectiles
    return projectiles
end

---@param itemStack ItemStack
---@return boolean
---@nodiscard
function util.crossbowCharged(itemStack)
    local projectiles = util.getProjectiles(itemStack)
    return projectiles ~= nil and next(projectiles) ~= nil
end

---@overload fun(...: ItemStack.useAction): boolean
---@param playr Player
---@param ... ItemStack.useAction
---@return boolean
---@nodiscard
function util.checkUseAction(playr, ...)
    local actions = { ... }
    local p

    if type(playr) == "PlayerAPI" then
        p = playr
    else
        table.insert(actions, playr)
        p = player
    end

    local activeItem = p:getActiveItem()
    if activeItem:getCount() == 0 then return false end

    local useAction = activeItem:getUseAction()
    for _, action in ipairs(actions) do
        if useAction == action then return true end
    end

    return false
end

---@alias Hand {
---     RIGHT: boolean?,
---     LEFT: boolean?,
---}

---@param id string
---@param playr Player?
---@return Hand?
function util.isHolding(id, playr)
    local p = playr or player
    local leftHanded = p:isLeftHanded()
    local rightItem = p:getHeldItem(leftHanded)
    local leftItem = p:getHeldItem(not leftHanded)

    local hand = {
        RIGHT = toboolean(rightItem.id:find(id)),
        LEFT = toboolean(leftItem.id:find(id)),
    }
    
    return next(hand) ~= nil and hand or nil
end

---@param action Action
---@param bool boolean?
function util.toggle(action, bool)
    action:toggled(bool)
    action.toggle(bool)
end

---@param entity Entity
---@param delta number?
---@nodiscard
function util.eyePos(entity, delta)
    return entity:getPos(delta):add(0, entity:getEyeHeight(), 0)
end

------------------------------------------------------------------------------
--Thanks `kitcat962` on the Figura Discord!

---@param direction Vector3
---@return Vector3
---@nodiscard
function util.directionToEuler(direction)
    local yaw = math.atan2(direction.x, direction.z)
    local pitch = math.atan2(direction.y, direction.xz:length())
    return vec(-pitch, -yaw, 0)
end

---@param direction Vector3
---@return Vector3
---@nodiscard
function util.directionToEulerDegree(direction)
    local yaw = math.atan2(direction.x, direction.z)
    local pitch = math.atan2(direction.y, direction.xz:length())
    return vec(-math.deg(pitch), -math.deg(yaw), 0)
end

---@overload fun(rotation: Vector3)
---@param x any
---@param y any
---@param z any
---@nodiscard
function util.realRotToModelRot(x, y, z)
    local rot = type(x) == "Vector3" and x or vec(x, y, z)
    return vec(0, 180, 0) - rot
end

------------------------------------------------------------------------------

---Formats effect ids as `"effect.<namespace>.<name>` regardless of Minecraft version
---(1.20.5 and above formats it as `"<namespace>:<name>"`)
---@param effect string
---@return Minecraft.effectID
---@nodiscard
function util.getEffect(effect)
    local id = effect
    if effect:find(":", 2) then
        local namespace, name = effect:match("^(.-):?([^:]+)$")
        id = "effect." .. namespace .. "." .. name
    end
    return id
end

---@param ticks integer
---@return fun(time: integer): boolean
---@nodiscard
function util.createTimer(ticks)
    local lastTime = 0
    return function(time)
        local bool = time == lastTime or time % ticks == 0
        lastTime = time
        return bool
    end
end

---@return boolean
---@nodiscard
function util.isNight()
    local time = world.getDayTime()
    return time >= 13000 and time <= 23000
end

---@param sound Sound
---@param position Vector3?
---@param pitch number?
---@param noRandomPitch boolean?
function util.playSound(sound, pitch, position, noRandomPitch)
    pitch = pitch or 1
    local p = noRandomPitch and pitch or math.lerp(pitch - 0.25, pitch + 0.25, math.random())
    local pos = position or player:getPos()
    sound:stop()
    sound:pitch(p)
    sound:pos(pos)
    sound:play()
end

util.RENDER_AMBIENT_FIRST_PERSON = false

---@alias Util.AmbientParticle {
---     id: Minecraft.particleID,
---     rate: number,
---     radius: number,
---     offset: Vector3?,
---     velocity: number?,
---     condition: (fun(): boolean)?,
---     countLeft: 0,
---}

---@type Util.AmbientParticle[]
local ambients = {}

---@param ambient Util.AmbientParticle
---@return Util.AmbientParticle
function util.newAmbientParticles(ambient)
    ambient.offset = ambient.offset or vec(0, 1, 0)
    ambient.velocity = ambient.velocity or 0.5
    ambient.condition = ambient.condition or world.exists
    ambient.countLeft = 0
    table.insert(ambients, ambient)
    return ambient
end

function util.tick()
    if not util.RENDER_AMBIENT_FIRST_PERSON and renderer:isFirstPerson() then return end
    for _, ambient in ipairs(ambients) do
        if ambient.condition() then
            local playerPos = player:getPos()
            ambient.countLeft = ambient.countLeft + ambient.rate / 20
            while ambient.countLeft > 0 do
                ambient.countLeft = ambient.countLeft - 1
                local pos = vec(playerPos.x, playerPos.y, playerPos.z):add(ambient.offset):add(
                    math.lerp(-ambient.radius, ambient.radius, math.random()),
                    math.lerp(-ambient.radius, ambient.radius, math.random()),
                    math.lerp(-ambient.radius, ambient.radius, math.random())
                )
                if ambient.velocity == 0 then
                    particles:newParticle(ambient.id, pos, 0, 0, 0)
                else
                    particles:newParticle(ambient.id, pos,
                        math.lerp(-ambient.velocity, ambient.velocity, math.random()),
                        math.lerp(-ambient.velocity, ambient.velocity, math.random()),
                        math.lerp(-ambient.velocity, ambient.velocity, math.random())
                    )
                end
            end
        end
    end
end

---@param particle Minecraft.particleID
---@param position Vector3?
---@param radius number?
---@param velocity Vector3?
---@param amount integer?
function util.particleExplosion(particle, position, radius, velocity, amount)
    position = position or player:getPos()
    radius = radius or 3
    velocity = velocity or vec(0.3, 0.3, 0.3)
    amount = amount or 20

    local calculateVelocity = velocity.x ~= 0 and velocity.y ~= 0 and velocity.z ~= 0

    for _ = 1, amount do
        if calculateVelocity then
            particles:newParticle(particle,
                position.x + math.lerp(-radius, radius, math.random()),
                position.y + math.lerp(-radius, radius, math.random()),
                position.z + math.lerp(-radius, radius, math.random()),
                math.lerp(-velocity.x, velocity.x, math.random()),
                math.lerp(-velocity.y, velocity.y, math.random()),
                math.lerp(-velocity.z, velocity.z, math.random())
            )
        else
            particles:newParticle(particle, position, 0, 0, 0)
        end
    end
end

-- Thanks `manuel_2867` from the Figura Discord!
do
    math.dt = 0
    local st = 0
    local getst = client.getSystemTime
    local exp = math.exp
    -- https://youtu.be/LSNQuFEDOyQ?t=2980
    ---@param a number
    ---@param b number
    ---@param decay number
    ---@param dt number
    ---@return number
    function math.expDecay(a, b, decay, dt)
        return b + (a - b) * exp(-decay * dt)
    end

    function events.render(_, context)
        if context ~= "FIRST_PERSON" and context ~= "RENDER" then return end
        local newst = getst()
        math.dt = (newst - st) / 1000
        st = newst
    end
end

---@return ModelPart
---@nodiscard
function util.getDominantArm()
    return player:isLeftHanded() and models.model.root.LeftArm or models.model.root.RightArm
end

---@param playr Player?
---@return boolean
function util.isWearingArmor(playr)
    local p = playr or player
    for i = 3, 6 do
        local armor = p:getItem(i)
        if armor and armor.id ~= "minecraft:air" then return true end
    end
    return false
end

---@alias Util.Curios.slot
---| "head"
---| "necklace"
---| "back"
---| "rings"
---| "hands"
---| "waist"
---| "belt"
---| "talisman"
---| "feet"
---| "charm"

---@alias Util.Curios.inventory { [Util.Curios.slot]: {
---     items: ItemStack[]?,
---     visible: boolean,
---}? }

---@param playr Player?
---@return Util.Curios.inventory?
function util.getCuriosInventory(playr)
    if not client.isModLoaded("curios") then return nil end
    local nbt = (playr or player):getNbt()
    local curios = nbt.ForgeCaps
        and nbt.ForgeCaps["curios:inventory"]
        and nbt.ForgeCaps["curios:inventory"].Curios
    if not curios then return nil end
    local inv = {}
    for _, v in ipairs(curios) do
        inv[v.Identifier] = {
            items = v.StacksHandler.Stacks.Items,
            visible = v.StacksHandler.Renders.Renders[1]
                and v.StacksHandler.Renders.Renders[1].Render == 1,
        }
    end
    return next(inv) ~= nil and inv or nil
end

---@param playr Player?
---@return boolean
function util.isWearingCurios(playr)
    if not client.isModLoaded("curios") then return false end
    local nbt = (playr or player):getNbt()
    local curios = nbt.ForgeCaps
        and nbt.ForgeCaps["curios:inventory"]
        and nbt.ForgeCaps["curios:inventory"].Curios
    if not curios then return false end
    for _, v in ipairs(curios) do
        local items = v.StacksHandler.Stacks.Items
        local visible = v.StacksHandler.Renders.Renders[1]
            and v.StacksHandler.Renders.Renders[1].Render == 1
        if visible and next(items) ~= nil then return true end
    end
    return false
end

util.vanillaCubes = {
    models.model.root.Head.Head,
    models.model.root.Head.Hat,
    models.model.root.Body.Body,
    models.model.root.Body.Jacket,
    models.model.root.LeftArm.wideLeftArm.LeftArm,
    models.model.root.LeftArm.wideLeftArm["Left Sleeve"],
    models.model.root.RightArm.wideRightArm.RightArm,
    models.model.root.RightArm.wideRightArm["Right Sleeve"],
    models.model.root.LeftArm.slimLeftArm.SlimLeftArm,
    models.model.root.LeftArm.slimLeftArm["SlimLeft Sleeve"],
    models.model.root.RightArm.slimRightArm.SlimRightArm,
    models.model.root.RightArm.slimRightArm["SlimRight Sleeve"],
    models.model.root.LeftLeg.LeftLeg,
    models.model.root.LeftLeg["Left Pants"],
    models.model.root.RightLeg.RightLeg,
    models.model.root.RightLeg["Right Pants"],
}

util.isHost = host:isHost()

return util
