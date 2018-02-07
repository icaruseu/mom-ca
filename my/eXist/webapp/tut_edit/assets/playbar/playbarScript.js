cp.playbarAssetArr = 
[
	'AudioOff',
	'AudioOn',
	'BackGround',
	'Backward',
	'Color',
	'ColorSmall',
	'CC',
	'Exit',
	'FastForward',
	'FastForward1',
	'FastForward2',
	'Forward',
	'Glow',
	'GlowSmall',
	'Height',
	'Play',
	'Pause',
	'Progress',
	'Rewind',
	'Stroke',
	'StrokeSmall',
	'Thumb',
	'ThumbBase',
	'TOC'
];
cp.playbarTooltips = 
{
	AudioOff : "Audio an ",
	AudioOn : "Audio aus ",
	Backward : "Zurück ",
	CC : "Bilduntertitel ",
	Exit : "Beenden ",
	FastForward : "Zweifache Vorspulgeschwindigkeit ",
	FastForward1 : "Vierfache Vorspulgeschwindigkeit ",
	FastForward2 : "Normale Geschwindigkeit ",
	Forward : "Weiter ",
	Play : "Abspielen ",
	Pause : "Anhalten ",
	Rewind : "Zurückspulen ",
	TOC : "Inhaltsverzeichnis ",
	Info : "Informationen ",
	Print : "Drucken "
};
cp.responsiveButtons = 
{
	//"ButtonName"	: 	[Primary,Tablet,Mobile],
	"Rewind"		: 	[true,true,true,true,false],
	"Backward"		: 	[true,true,true,true,true],
	"Play"			: 	[true,true,true,true,true],
	"Slider"		: 	[true,true,true,true,false],
	"Forward"		: 	[true,true,true,true,true],
	"CC"			: 	[true,true,true,true,true],
	"AudioOn"		: 	[true,true,false,false,false],
	"Exit"			: 	[true,true,true,true,true],
	"FastForward"	: 	[true,true,true,true,false],
	"TOC"			: 	[true,true,true,true,false]
};
cp.handleSpecialForPlaybar = function(playbarConstruct)
{
}