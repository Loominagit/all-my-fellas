local replicatedStorage = game:GetService("ReplicatedStorage")

--> Packages
local Packages = replicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Flipper = require(Packages.Flipper)
local TableUtil = require(Packages.TableUtil)

local Motor = Flipper.SingleMotor.new
local Spring = Flipper.Spring.new

--> Helpers
local helpers = replicatedStorage.helpers
local create = require(helpers.create)
local textUtil = require(helpers.textUtil)
local textRenderer = require(helpers.textRenderer)
local config = require(replicatedStorage.configuration)

--> Constants
local BLACK = Color3.new()
local WHITE = Color3.new(1, 1, 1)

local FONTS = require(replicatedStorage.fonts)

local WEIGHTS = Enum.FontWeight:GetEnumItems()

local controller = Knit.GetController('fellasController')
local canvas = controller.Canvas
local screen = controller.ScreenGui

local payloads = {}
local storage = {}

payloads.titleText = function()
    local textSize = math.floor(screen.AbsoluteSize.Y * 0.2)
    local motor = Motor(textSize)

    local fontObject = Font.new(config.FontFace, Enum.FontWeight.SemiBold)
    local title = textRenderer.new(canvas)

    title.Color = WHITE

    title.AnchorPoint = Vector2.one * 0.5
    title.Position = UDim2.fromScale(0.5, 0.5)
    title.Font = fontObject

    motor:onStep(function(value)
        title.TextSize = value
    end)

    title.Text = 'ALL MY FELLAS'
    motor:setGoal(Spring(textSize * 0.6, {
        frequency = 1,
        dampingRatio = 4
    }))

    storage.title = title
    storage.motor = motor
end

payloads.cleanupTitleScreen = function()
    storage.title:Destroy()
    storage.motor:stop()
end

payloads.displayTitle1 = function()
    local textSize = math.floor(screen.AbsoluteSize.Y * 0.2)
    local title = textRenderer.new(canvas)

    title.Text = 'ALL'
    title.TextSize = textSize
    title.Font = Font.new(config.FontFace, Enum.FontWeight.SemiBold)
    
    title.Position = UDim2.fromScale(0.5, 0.5)
    title.AnchorPoint = Vector2.new(0.5, 0.5)

    storage.title1 = title
end

local returnedPayloads = {
    [1] = payloads.titleText,
    [12] = function()
        storage.title.Font = Font.new(config.FontFace, WEIGHTS[5])
    end,
    [30] = function()
        payloads.cleanupTitleScreen()
    end,
}

for i = 6, 9 do -- no pun intended
    returnedPayloads[i] = function()
        storage.title.Font = Font.new(config.FontFace, WEIGHTS[i-5])
    end
end

for i = 14, 29 do
    returnedPayloads[i] = function()
        storage.title.Font = Font.new(
            FONTS[math.random(#FONTS)], 
            WEIGHTS[math.random(#WEIGHTS)],
            (i % 2 == 0) and Enum.FontStyle.Italic or Enum.FontStyle.Normal
        )
    end
end

return returnedPayloads