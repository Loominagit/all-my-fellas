--> Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local Iris = require(Packages:WaitForChild('Iris')).Init()

--> Knit Controller
local IrisDebugger = Knit.CreateController { Name = 'IrisDebugger' }

--> Fires after Knit controllers are initialized
function IrisDebugger:KnitStart()
    local fellasController = Knit.GetController('fellasController')
    local music = fellasController.Music
    Iris:Connect(function()
        local windowSize = Iris.State(Vector2.new(150, 300))

        Iris.Window({'Debugger'}, {size = windowSize})
            Iris.Text({'Used to debug some visuals.'})

            if Iris.Button({'Play visual'}).clicked() then
                fellasController:Play()
            end

            if Iris.Button({'Stop visual'}).clicked() then
                fellasController:Stop()
            end

            Iris.Tree({'Beats'})
                for index, pos in fellasController.Beats do
                    if Iris.Button({`Beat #{index} @ {pos}`}).clicked() then
                        assert(fellasController.Playing == false, '[Client] the visual must be stopped to jump into specific beat!')
                        music.TimePosition = (pos / 1000) * music.PlaybackSpeed
                        music:Play()
                    end
                end
            Iris.End()

            if Iris.Button({'Stop the music'}).clicked() then
                assert(fellasController.Playing == false, '[Client] the visual must not be played!')
                music:Stop()
            end
        Iris.End()
    end)
end

return IrisDebugger