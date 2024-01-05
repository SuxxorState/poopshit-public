package backend;

enum TrophyStats {
	UNLOCKED;
	INDEX;
    RANK;
}

class Trophies {
	public static var trophyStuff:Array<Array<String>> = [ //Name, Description, Ranking, Trophy save tag
		["Defecation Machine",						"Beat Constipation with no Misses.",		'silver', 		'constipation_fc'],
		["I FEEL IT COMIN'",						"Beat Kidney Stones with no Misses.",		'silver', 		'kidney-stone_fc'],
		["Daddy's Princess",						"Beat BBG with no Misses.",					'silver', 		'bbg_fc'],
		["Cracking the egg",						"Beat Eggster with no Misses.",				'gold', 		'eggster_fc'],
		["Ooh, very scary!",						"Beat Too Far with no Misses.",				'gold', 		'too-far_fc'],
		["How are your balls?",						"Beat Down to the Bone with no Misses.",	'platinum', 	'down-to-the-bone_fc'],

		["Itchy no longer",							"Scratch his nuts.",						'silver', 		'nut_scratch'],
		["Unlucky",									"Never meet Sans.",							'silver', 		'unlucky'],
		["The first of many",						"Die once.",								'bronze', 		'krill_yourself'],
		["Get Baptized!",							"Name your dumbass.",						'bronze', 		'baptism'],
		["Refreshing",								"Wait for Sans to finish his Ice Cream.",	'silver', 		'ice_cream'],
		["Pause Sans Fanatic",						"Talk to Pause Sans 50 times.",				'gold', 		'pause_sans'],
		["Pause...pyrus Fanatic?",					"Talk to Pausepyrus 50 times.",				'platinum', 	'pause_pyrus'],
		["Don't you have anything better to do?",	"Get all the trophies.",					'platinum', 	'everything']
	];
	public static var hidden:Array<Bool> = [false,false,false,true,true,true,false,false,false,false,true,false,true,true]; //for some reason TrophyItem.hx doesnt like it when its with the other shit.
	public static var trophyMap:Map<String, Bool> = new Map<String, Bool>();
	public static var pauseTracker:Array<Int> = [0,0];

	public static function unlockTrophy(name:String):Void {
		trophyMap.set(name, true);
		FlxG.sound.play(Paths.sound('save', 'overworld'));
		ClientPrefs.saveSettings();
	}

	public static function getTrophyStats(name:String, stat:TrophyStats):Dynamic {
		switch(stat) {
			case UNLOCKED: 
				if(trophyMap.exists(name) && trophyMap.get(name)) return true;
				return false;
			case INDEX: 
				for (i in 0...trophyStuff.length) if(trophyStuff[i][3] == name) return i;
				return -1;
			case RANK: 
				for (i in trophyStuff) if(i[3] == name) return i[2];
				return null;
		}
	}

	public static function loadTrophies():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.trophyMap != null) trophyMap = FlxG.save.data.trophyMap;
			if(pauseTracker == [0,0] && FlxG.save.data.pauseTracker != null) pauseTracker = FlxG.save.data.pauseTracker;
		}
		for (i in trophyStuff) {
			if (trophyMap.get(i[3]) == null || !trophyMap.get(i[3]))
				trophyMap.set(i[3], false);
		}
	}
}