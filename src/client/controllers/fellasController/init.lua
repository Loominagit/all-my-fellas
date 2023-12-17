--> Services
local Players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local SoundService = game:GetService('SoundService')

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local Trove = require(Packages:WaitForChild('Trove'))

--> Helpers
local helpers = replicatedStorage.helpers
local create = require(helpers.create)
local config = require(replicatedStorage.configuration)
local calculateBeats = require(helpers.beatCalculation)

--> Constants
local BLACK = Color3.new()
local WHITE = Color3.new(1, 1, 1)
local PAYLOADS
local CLEANER = Trove.new()

--> Knit Controller
local fellasController = Knit.CreateController { Name = 'fellasController' }
fellasController.__BeatChanged = Instance.new('BindableEvent')
fellasController.BeatChanged = fellasController.__BeatChanged.Event

fellasController.Music = SoundService.Music
fellasController.ScreenGui = nil
fellasController.Canvas = nil

fellasController.Beats = {}
fellasController.CurrentBeat = 1
fellasController.Playing = false

function fellasController:Play()
    assert(self.ScreenGui ~= nil, '[Client]: Knit needs to be initialized first.')
    assert(fellasController.Playing == false, '[Client] The visual is currently playing')

    print('[Client] preparing visuals')

    fellasController.Playing = true

    -- display warning
    print('[Client] displaying warning')
    local warning = create('Frame', {
        Name = "warning",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.6, 0.4)
    }, {
        image = create('ImageLabel', {
            Image = "rbxassetid://13056302367",
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromScale(0.4, 0.4),
        }, {
            aspectratio = create('UIAspectRatioConstraint')
        }),
        title = create('TextLabel', {
            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = "Warning!",
            TextColor3 = WHITE,
            TextScaled = true,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0.375),
            Size = UDim2.fromScale(1, 0.2)
        }),
        content = create('TextLabel', {
            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = "The content you are looking contains scenes with rapidly flashing colors. Take caution if you are affected by epilepsy.",
            TextColor3 = WHITE,
            TextScaled = true,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0.6),
            Size = UDim2.fromScale(1, 0.4)
        }),
        blackframe = create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = BLACK,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),

            ZIndex = 2
        })
    }, self.Canvas)

    for i = 0, 1, 0.1 do
        task.wait()
        warning.blackframe.BackgroundTransparency = i
    end

    task.wait(5)

    for i = 1, 0, -0.1 do
        task.wait()
        warning.blackframe.BackgroundTransparency = i
    end

    warning:Destroy()

    task.wait(1)

    print('[Client] playing song')

    self.Music:Play()
    self.CurrentBeat = 1

    -- selene: allow(multiple_statements)
    while #self.Beats == 0 or not self.Music.Playing do task.wait() end

    print('[Client] hooking beats to renderstepped')

    CLEANER:Connect(RunService.RenderStepped, function()
        if not self.Music.Playing then return end
        local beat = self.Beats[self.CurrentBeat]
        local payloadFunction = PAYLOADS[self.CurrentBeat]
        if beat ~= nil and (self.Music.TimePosition / self.Music.PlaybackSpeed) * 1000 >= beat then
            -- print(`[Client] beat {self.CurrentBeat} passed`)
            if payloadFunction ~= nil and type(payloadFunction) == 'function' then
                payloadFunction() -- execute the payload at certain beat.
            end
            self.CurrentBeat += 1
            self.__BeatChanged:Fire(self.CurrentBeat)
            SoundService.Metronome:Play()
        end
        if self.CurrentBeat >= #self.Beats then
            self:Stop()
        end
    end)

    print('[Client] hooked beats')
    print()
end

function fellasController:Stop()
    assert(self.ScreenGui ~= nil, '[Client]: Knit needs to be initialized first.')
    assert(fellasController.Playing == true, '[Client] The visual is not currently playing')

    print('[Client] performing cleanup')
    self.Canvas:ClearAllChildren()
    self.Music:Stop()
    CLEANER:Clean()

    self.Playing = false
    print('[Client] visuals stopped')
    print()
end

--> Fires when Knit is about to initialize
function fellasController:KnitInit()
    local player = Players.LocalPlayer
    self.ScreenGui = create('ScreenGui', {
        Enabled = true,
        ResetOnSpawn = false,
        ScreenInsets = Enum.ScreenInsets.None,

        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, {
        Canvas = create('Frame', {
            BackgroundColor3 = BLACK,
            BorderSizePixel = 0,

            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.one * 0.5
        })
    }, player:WaitForChild('PlayerGui'))
    self.Canvas = self.ScreenGui.Canvas
end

--> Fires after Knit controllers are initialized
function fellasController:KnitStart()
    calculateBeats(self.Music, config):andThen(function(beats)
        self.Beats = beats
    end)

    PAYLOADS = require(script.payloads)
    self:Play()
end

return fellasController