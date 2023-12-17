--> Services
local ContentProvider = game:GetService('ContentProvider')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

--> Packages
local Packages = ReplicatedStorage.Packages
local Promise = require(Packages:WaitForChild('Promise'))

--> Beat configuration type
export type BeatConfiguration = {
    -- The song's beat per minute (BPM)
	SongBPM: number,

	-- Song's tempo. For example: if you assign the value to 4, it'll be 1/4.
	Tempo: number,

	-- Song's time position where the first beat occurred in miliseconds.
	Offset: number,

	-- Song's length in miliseconds. This defaults to the Sound's `TimeLength` properties.
	Length: number?,
}

--> Calculate beats from the specified configuration
return function(sound: Sound, conf: BeatConfiguration)
    return Promise.new(function(resolve)
        local offset: number = conf.Offset
        local bpm: number = conf.SongBPM
        local tempo: number = conf.Tempo

        local beats = {}
        local music = sound

        print('[Client] calculateBeats: loading sounds...')
        ContentProvider:PreloadAsync({ music.SoundId })
        print('[Client] calculateBeats: sound loaded')

        local length = conf.Length or (music.TimeLength * 1000)
        local speed = music.PlaybackSpeed

        local tick = (60000 / bpm) * (4 / tempo)

        print('[Client] calculateBeats: start beat calculation with following settings:')
        print(`[Client] calculateBeats: offset: {offset}; bpm: {bpm}; tempo: 1/{tempo};`)
        print(`[Client] calculateBeats: length: {length}ms; speed: {speed}x`)
        print(`[Client] calculateBeats: {tick}ms per beat`)

        table.insert(beats, offset)
        while beats[#beats] <= (length / speed) do
            table.insert(beats, beats[#beats] + tick)
            RunService.RenderStepped:Wait()
        end
        
        print(`[Client] calculateBeats: beats calculated. total beats: {#beats}`)
        resolve(beats)
    end)
end