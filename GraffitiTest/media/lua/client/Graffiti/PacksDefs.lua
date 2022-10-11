local self = {}

self.AddPackDefs = function(packDefs)
	triggerEvent("Graffiti:AddPackDefs", packDefs)
end

self.Packs = {
	mod_graffiti = {
		displayName="Azakaela's Graffiti",
		tilesetType="text",
		tilesetbase="mod_graffiti_",
		charsPerPosition=26,
		charIndexes={
			[string.char(65)]=0,
			[string.char(66)]=1,
			[string.char(67)]=2,
			[string.char(68)]=3,
			[string.char(69)]=4,
			[string.char(70)]=5,
			[string.char(71)]=6,
			[string.char(72)]=7,
			[string.char(73)]=8,
			[string.char(74)]=9,
			[string.char(75)]=10,
			[string.char(76)]=11,
			[string.char(77)]=12,
			[string.char(78)]=13,
			["O"]=14,
			["P"]=15,
			["Q"]=16,
			["R"]=17,
			["S"]=18,
			["T"]=19,
			["U"]=20,
			["V"]=21,
			["W"]=22,
			["X"]=23,
			["Y"]=24,
			["Z"]=25,
			[string.char(97)]=0,
			[string.char(98)]=1,
			[string.char(99)]=2,
			[string.char(100)]=3,
			[string.char(101)]=4,
			[string.char(102)]=5,
			[string.char(103)]=6,
			[string.char(104)]=7,
			[string.char(105)]=8,
			[string.char(106)]=9,
			[string.char(107)]=10,
			[string.char(108)]=11,
			[string.char(109)]=12,
			[string.char(110)]=13,
			[string.char(111)]=14,
			[string.char(112)]=15,
			[string.char(113)]=16,
			[string.char(114)]=17,
			[string.char(115)]=18,
			[string.char(116)]=19,
			[string.char(117)]=20,
			[string.char(118)]=21,
			[string.char(119)]=22,
			[string.char(120)]=23,
			[string.char(121)]=24,
			[string.char(122)]=25,
		},
		invalidCharOffset=nil,
		singleWhitespace=string.char(32),
		positionsPerSquare=3,
		positionOffsets={ 0, 32, 64 },
		directionSuffixes={ "west_", "north_" },
	},
	mod_graffiti_style2 = {
		displayName="Azakaela's Graffiti Style 2",
		tilesetType="text",
		tilesetbase="mod_graffiti_style2_",
		charsPerPosition=26,
		charIndexes={
			[string.char(65)]=0,
			[string.char(66)]=1,
			[string.char(67)]=2,
			[string.char(68)]=3,
			[string.char(69)]=4,
			[string.char(70)]=5,
			[string.char(71)]=6,
			[string.char(72)]=7,
			[string.char(73)]=8,
			[string.char(74)]=9,
			[string.char(75)]=10,
			[string.char(76)]=11,
			[string.char(77)]=12,
			[string.char(78)]=13,
			["O"]=14,
			["P"]=15,
			["Q"]=16,
			["R"]=17,
			["S"]=18,
			["T"]=19,
			["U"]=20,
			["V"]=21,
			["W"]=22,
			["X"]=23,
			["Y"]=24,
			["Z"]=25,
			[string.char(97)]=0,
			[string.char(98)]=1,
			[string.char(99)]=2,
			[string.char(100)]=3,
			[string.char(101)]=4,
			[string.char(102)]=5,
			[string.char(103)]=6,
			[string.char(104)]=7,
			[string.char(105)]=8,
			[string.char(106)]=9,
			[string.char(107)]=10,
			[string.char(108)]=11,
			[string.char(109)]=12,
			[string.char(110)]=13,
			[string.char(111)]=14,
			[string.char(112)]=15,
			[string.char(113)]=16,
			[string.char(114)]=17,
			[string.char(115)]=18,
			[string.char(116)]=19,
			[string.char(117)]=20,
			[string.char(118)]=21,
			[string.char(119)]=22,
			[string.char(120)]=23,
			[string.char(121)]=24,
			[string.char(122)]=25
		},
		invalidCharOffset=nil,
		singleWhitespace=string.char(32),
		positionsPerSquare=3,
		positionOffsets={ 0, 32, 64 },
		directionSuffixes={ "west_", "north_" },
	},
	mod_graffiti_symbols = {
		displayName="Azakaela's Symbols",
		tilesetType="image",
		tilesetbase="mod_graffiti_symbols_",
		charsPerPosition=26,
		charIndexes={
			["Yin_Yang"]=0,
			["Troll"]=2,
			["Cobra"]=4,
			["Dragon"]=6,
			["Butterfly"]=8,
			["Rock"]=10,
			["Cool_S"]=12,
			["Fist"]=14,
			["Sword"]=16,
			["Skull"]=18,
			["Finger"]=20,
			["Female"]=22,
			["Trans"]=24,
			["Male"]=26,
			["Cancer"]=28,
			["Leo"]=30,
			["Aries"]=32,
			["Libra"]=34,
			["Virgo"]=36,
			["Scorpio"]=38,
			["Taurus"]=40,
			["Aquarius"]=42,
			["Gemini"]=44,
			["Capricorn"]=46,
			["Sagittarius"]=48,
			["Pisces"]=50,
			["Wolf"]=52,
			["Eye"]=54,
			["Anarchy"]=56,
			["Occult"]=58,
			["Moon"]=60,
			["Star"]=62,
			["Heart"]=64,
			["Broken_Heart"]=66,
			["Scorpion"]=68,
			["Crow"]=70,
			["Hammer"]=72,
			["Dino"]=74,
			["X"]=76,
			["Circle"]=78,
			["Up"]=80,
			["Down"]=82,
			["Right"]=84,
			["Left"]=86,
			["DontOpen"]=88,
			["DeadInside"]=90,
			["Home"]=92,
			["Plus"]=94,
			["Doctor"]=96,
			["Pizza"]=98,
			["Creeper"]=100,
			["Gun"]=102,
			["Happy"]=104,
			["Sad"]=106,
			["Thinking"]=108,
			["Pentagram"]=110,
			["Fire"]=112,
			["Biohazard"]=114,
			["Warning"]=116,
			["Paw"]=118,
			["Question"]=120,
			["Thieves"]=122,
			["Dark_Brotherhood"]=124,
			["Aza"]=126,
		},
		invalidCharOffset=nil,
		singleWhitespace=string.char(32),
		positionsPerSquare=1,
		positionOffsets={ 0, },
		directionSuffixes={ "west_", "north_" },
	}
};


return self