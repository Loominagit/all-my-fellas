--> Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--> Packages
local Packages = replicatedStorage.Packages
local Trove = require(Packages:WaitForChild('Trove'))
local TableUtil = require(Packages:WaitForChild('TableUtil'))

--> Helpers
local helpers = replicatedStorage.helpers
local create = require(helpers.create)
local textUtil = require(helpers.textUtil)

local fontCache = {}
local camera = workspace.CurrentCamera
local acceptableTypes = {
    ['Position'] = {'UDim2'}, ['AnchorPoint'] = {'Vector2'}, ['Font'] = {'Font', 'EnumItem'}, ['Text'] = {'string'}, ['TextSize'] = {'number'}, ['Parent'] = {'Instance', 'nil'},
    ['Color'] = {'Color3'}
}

local WHITE = Color3.new(1, 1, 1)

--> Private methods
-- selene: allow(multiple_statements)
local function cacheFont(font: Font, size: number, str: string)
    local cache do
        if fontCache[font] == nil then fontCache[font] = {} end
        if fontCache[font][`Size{size}`] == nil then fontCache[font][`Size{size}`] = {} end
        cache = fontCache[font][`Size{size}`]
    end

    for first, last in utf8.graphemes(str) do
        local grapheme = str:sub(first, last)
        if cache[grapheme] ~= nil then continue end -- skip if the grapheme is present

        cache[grapheme] = textUtil:GetStringTextBounds(grapheme, font, size)
    end
end

local function changeSize(self, size)
    local font, text = self.Font, self.Text
    local screenSize = camera.ViewportSize
    local frameSize = textUtil:GetStringTextBounds(
        text, 
        font, 
        size
    )
    cacheFont(font, size, text)

    frameSize = UDim2.fromScale(
        frameSize.X / screenSize.X,
        frameSize.Y / screenSize.Y
    )

    self.frame.Size = frameSize
    for _, label: Instance in self.frame:GetChildren() do
        if not label:IsA('TextLabel') then continue end
        local labelSize = fontCache[font][`Size{size}`][label.Text]
        label.TextScaled = true
        -- label.FontFace = font

        local convertedSize = UDim2.fromScale(
            labelSize.X / self.frame.AbsoluteSize.X,
            labelSize.Y / self.frame.AbsoluteSize.Y
        )
        label.Size = convertedSize
    end
end

local onPropertyChange = {}
onPropertyChange.Position = function(self, value)
    self.frame.Position = value
end
onPropertyChange.AnchorPoint = function(self, value)
    self.frame.AnchorPoint = value
end

onPropertyChange.Text = function(self, value)
    local font, size, color = self.Font, self.TextSize, self.Color
    cacheFont(font, size, value)

    self.__textCleanup:Clean()
    for first, last in utf8.graphemes(value) do
        local grapheme = value:sub(first, last)
        -- local labelSize = fontCache[font][`Size{size}`][grapheme]
        local label = create('TextLabel', {
            BackgroundTransparency = 1,
            Text = grapheme,
            RichText = true,
            TextColor3 = color
        }, {}, self.frame)
        self.__textCleanup:Add(label)
    end

    changeSize(self, size)
end
onPropertyChange.Font = function(self, value)
    for _, label: Instance in self.frame:GetChildren() do
        if not label:IsA('TextLabel') then continue end
        label.FontFace = value
    end

    changeSize(self, self.TextSize)
end
onPropertyChange.Color = function(self, value)
    for _, label: Instance in self.frame:GetChildren() do
        if not label:IsA('TextLabel') then continue end
        label.TextColor3 = value
    end
end
onPropertyChange.TextSize = function(self, value)
    changeSize(self, value)
end
onPropertyChange.Parent = function(self, value)
    self.frame.Parent = value
end

local function find(t, k, v)
    return TableUtil.Find(t[k], function(e)
        return e == v
    end)
end

--> Metatable
local renderer = {}
local objectCalls = {}

--> Methods
objectCalls.GetLetters = function(self)
    return TableUtil.Filter(self.frame:GetChildren(), function(obj: Instance)
        return obj:IsA('TextLabel')
    end)
end

objectCalls.Destroy = function(self)
    self.__trove:Destroy()
end

--> Metamethods
renderer.__type = 'TextRenderer'
renderer.__index = function(self, key)
    local props = rawget(self, '__properties')

    -- function calls
    if objectCalls[key] ~= nil and type(objectCalls[key]) == 'function' then
        return function(self_2, ...)
            return objectCalls[key](self_2, ...)
        end
    
    -- indexing
    elseif pcall(find, acceptableTypes, key, typeof(props[key])) then
        return props[key]

    -- throw error if key is not valid member of this thing
    else
        error(`{key} is not a valid member of {renderer.__type}`)

    end
end
renderer.__newindex = function(self, key, value)
    local props = rawget(self, '__properties')
    if objectCalls[key] ~= nil and type(objectCalls[key]) == 'function' then
        -- throw error when tampering function call with another value
        error(`"{key}" is a function call, therefore you shouldn't overwrite this.`)    
    elseif pcall(find, acceptableTypes, key, typeof(props[key])) then
        props[key] = value

        if onPropertyChange[key] then
            task.spawn(onPropertyChange[key], self, value)
        end
    else
        return error(`{key} is not a valid member of {renderer.__type}`)
    end
end

local function init(self)
    local prop = self.__properties
    cacheFont(prop.Font, prop.TextSize, prop.Text)

    self.__trove:AttachToInstance(self.frame)
    self.__trove:Connect(camera:GetPropertyChangedSignal('ViewportSize'), function()
        onPropertyChange.TextSize(self, self.TextSize)
    end)
    
    for k, v in self.__properties do
        onPropertyChange[k](self, v)
    end

    return self
end

--> Constructor
local function new(parent: Instance?)
    local self = {}
    
    --> properties
    --> do not change from this table!!!
    self.__properties = {
        --> frame
        Position = UDim2.new(),
        AnchorPoint = Vector2.new(),

        --> text
        Font = Font.new('rbxasset://fonts/families/SourceSansPro.json'),
        Text = 'Label',
        TextSize = 14,
        Color = WHITE,
        Parent = parent
    }

    self.__trove = Trove.new()
    self.__textCleanup = self.__trove:Extend()

    self.list = create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal,
    })

    self.frame = create('Frame', {
        BackgroundTransparency = 1,
    }, {
        list = self.list
    }, parent)

    return init(setmetatable(self, renderer))
end

return {
    new = new
}