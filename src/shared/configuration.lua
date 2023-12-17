return {
	-- main font that will be used in the game
	FontFace = 'rbxasset://fonts/families/SourceSansPro.json',

	-- The song's beat per minute (BPM)
	SongBPM = 160,

	-- Song's tempo. For example: if you assign the value to 4, it'll be 1/4.
	Tempo = 16,

	-- Song's time position where the first beat occurred in miliseconds.
	Offset = 782,

	-- Song's length in miliseconds. This defaults to the Sound's `TimeLength` properties.
	Length = nil,
}