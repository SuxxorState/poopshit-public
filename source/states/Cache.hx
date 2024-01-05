package states;
#if sys
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#if cpp
import sys.FileSystem;
#end

import backend.*;

using StringTools;

class Cache extends MusicBeatState {
	var folders:Array<String> = [/*'overworld/',*/ 'shared/', /*'', 'gaster_def_stage/',*/ 'papyruexe/'/*, 'peepisser/', 'poopshitter/', 'sexy/'*/];//
	var subfolders:Array<Array<String>> = [
		//['characters', 'dialogue', 'rooms/gaster-room', 'rooms/last-corridor', 'rooms/scary-sans-room', 'rooms/scary-skeleton-house'],
		[/*'characters',*/ 'icons', /*'noteColorMenu',*/ 'noteSkins', 'noteSplashes', 'pause', 'scratchUI'], 
		//['credits', 'Freeplay Overworld Assets', 'upon']
	];
	public static var mainBmpData:Map<String,FlxGraphic>;
	public static var subBmpData:Map<String,FlxGraphic>;

	var mainFold:Array<Array<String>> = [];
	var subFold:Array<Array<Array<String>>> = [];
	var songs = [];

	var loadTxt:FlxText;
	var canProceed:Bool = false;
	var thinger:Array<String> = ['Caching Assets', 'Caching Assets.', 'Caching Assets..', 'Caching Assets...'];
	
	override function create() {
        if (!CoolUtil.initialized) CoolUtil.initialize();
		
		#if desktop
		DiscordClient.changePresence("In The Menus", null);
		#end

		mainBmpData = new Map<String,FlxGraphic>();
		subBmpData = new Map<String,FlxGraphic>();

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.setGraphicSize(Std.int(logo.width * 1.5));
		logo.updateHitbox();
		logo.screenCenter();
		logo.antialiasing = false;
		add(logo);

		if (ClientPrefs.data.ibdMode != '') {
			//FlxTween.color(logo, 0.5, FlxColor.WHITE, FlxColor.RED, {onComplete: function(twn:FlxTween) {
				FlxG.sound.play(Paths.sound('car_honk', 'overworld'));
				thinger = ['Enabling IBD Mode', 'Enabling IBD Mode.', 'Enabling IBD Mode..', 'Enabling IBD Mode...'];
			//}});
		}

		loadTxt = new FlxText(0,525,0, "Caching Assets", 18);
		loadTxt.scrollFactor.set();
		loadTxt.setFormat(Paths.font("undertale-crypt-of-tommorow.ttf"), 18, FlxColor.WHITE, LEFT);
		loadTxt.alpha = 0.5;
		loadTxt.screenCenter(X);
		loadTxt.antialiasing = false;
		add(loadTxt);
		changetext();

		#if cpp
		for (h in 0...folders.length) {
			var lmao = [];
			for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/${folders[h]}images'))) {
				if (!i.endsWith(".png"))
					continue;
				lmao.push(i);
			}
			mainFold.push(lmao);
		}

		for (h in 0...subfolders.length) {
			var fuck:Array<Array<String>> = [];
			for (i in 0...subfolders[h].length) {
				var lol = [];
				for (j in FileSystem.readDirectory(FileSystem.absolutePath('assets/${folders[h]}images/${subfolders[h][i]}'))) {
					if (!j.endsWith(".png"))
						continue;
					lol.push(j);
				}
				fuck.push(lol);
			}
			subFold.push(fuck);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs"))) {
			songs.push(i);
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (canProceed && controls.ACCEPT) FlxG.switchState(new Upon());
	}

	function changetext() {
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			if (!canProceed) {
				loadTxt.text = thinger[tmr.elapsedLoops % thinger.length];
				loadTxt.screenCenter(X);
			} else tmr.cancel();
		},0);
	}

	function cache() {
		#if !linux
		var sound0:FlxSound;
		sound0 = new FlxSound().loadEmbedded(Paths.pVoices('too-far'));
		sound0.play();
		sound0.volume = 0.00001;
		FlxG.sound.list.add(sound0);
		
		var sound1:FlxSound;
		sound1 = new FlxSound().loadEmbedded(Paths.oVoices('too-far'));
		sound1.play();
		sound1.volume = 0.00001;
		FlxG.sound.list.add(sound1);

		var sound2:FlxSound;
		sound2 = new FlxSound().loadEmbedded(Paths.inst('too-far'));
		sound2.play();
		sound2.volume = 0.00001;
		FlxG.sound.list.add(sound2);
			
		for (h in 0...folders.length) {
			for (i in 0...mainFold[h].length) {
				var replaced2 = mainFold[h][i].replace(".png","");
				var data2:BitmapData = BitmapData.fromFile('assets/${folders[h]}images/${mainFold[h][i]}');
				var graph2 = FlxGraphic.fromBitmapData(data2);
				graph2.persist = true;
				graph2.destroyOnNoUse = false;
				mainBmpData.set(replaced2,graph2);
			}
		}

		for (h in 0...subfolders.length) {
			for (i in 0...subfolders[h].length) {
				for (j in 0...subFold[h][i].length) {
					var replaced = subFold[h][i][j].replace(".png","");
					var data:BitmapData = BitmapData.fromFile('assets/${folders[h]}images/${subfolders[h][i]}/${subFold[h][i][j]}');
					var graph = FlxGraphic.fromBitmapData(data);
					graph.persist = true;
					graph.destroyOnNoUse = false;
					subBmpData.set(replaced,graph);
				}
			}
		}

		for (i in songs) {
			FlxG.sound.cache('songs:assets/songs/$i/Inst.' + Paths.SOUND_EXT);
			FlxG.sound.cache('songs:assets/songs/$i/OVoices.' + Paths.SOUND_EXT);
			FlxG.sound.cache('songs:assets/songs/$i/PVoices.' + Paths.SOUND_EXT);
			FlxG.sound.cache('songs:assets/songs/$i/Pause.' + Paths.SOUND_EXT);
			Paths.excludeAsset('assets/songs/$i/Pause.' + Paths.SOUND_EXT);
		}

		#end
		canProceed = true;
		loadTxt.text = "Done!";
		loadTxt.screenCenter(X);
		new FlxTimer().start(0.5, function(tmr:FlxTimer){loadTxt.alpha = 0;});
		new FlxTimer().start(3, function(tmr:FlxTimer){
			loadTxt.text = '[PRESS ${getKeyByName('accept')}]';
			loadTxt.screenCenter(X);
			loadTxt.alpha = 0.5;
		});
	}
    
    function getKeyByName(leStr:String):String {
        var length:String = InputFormatter.getKeyName(ClientPrefs.keyBinds.get(leStr)[0]).toUpperCase();
        var width:String = InputFormatter.getKeyName(ClientPrefs.keyBinds.get(leStr)[1]).toUpperCase();
        var height:String = '';
        if (length.length < 1 || length == null || length == '---') height = width;
        else if (width.length < 1 || width == null || width == '---') height = length;
        else height = length + ' or ' + width;

        return height;
    }
}
#end