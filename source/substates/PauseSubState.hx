package substates;

import backend.SongData;
import backend.Highscore;
import backend.Song;
import backend.Trophies;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxStringUtil;

import states.Overworld;
import states.Freepoop;
import options.OptionsState;

import objects.PauseButton;
import objects.PauseShitter;
import objects.Player;
import objects.TrophyPopup;

class PauseSubState extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<PauseButton>;

	var menuItems:Array<String> = ['Resume', 'Restart', 'Options', 'Flee'];
	var curSelected:Int = 0;

	var backscrolling:FlxBackdrop;
	var frontscrolling:FlxBackdrop;

	var pauseMusic:FlxSound;
	var sans:PauseShitter;
	var papyrus:PausePisser;
	var blackout:FlxSprite;
	var soul:Soul;

	public function new(x:Float, y:Float) {
		super();

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.pauseMusic(PlayState.SONG.song), true, true);
		if (pauseMusic == null) pauseMusic.loadEmbedded(Paths.pauseMusic('constipation'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite(0, 50).loadGraphic(Paths.image('pause/bg', 'shared'));
		bg.setGraphicSize(960, 720);
		bg.updateHitbox();
		bg.setPosition(0, 75);
		bg.scrollFactor.set();
		add(bg);
		
		backscrolling = new FlxBackdrop(Paths.image('pause/shitsquare', 'shared'), XY, -1, -1);
		if(!ClientPrefs.data.lowQuality) backscrolling.velocity.set(-45,-45);
		backscrolling.alpha = 0.3;
		frontscrolling = new FlxBackdrop(Paths.image('pause/shitsquare', 'shared'), XY, -1, -1);
		if(!ClientPrefs.data.lowQuality) frontscrolling.velocity.set(45,45);

		if (PlayState.SONG.song == 'Too Far')  {
			FlxG.mouse.visible = true;
			backscrolling.color = FlxColor.RED;
			frontscrolling.color = FlxColor.RED;
		}

		add(backscrolling);
		add(frontscrolling);

		if (ClientPrefs.data.funVal == 99) {
			papyrus = new PausePisser(480, 100);
			if (!PlayState.instance.isSansGone) add(papyrus);
		} else {
			sans = new PauseShitter(7.5, 275);
			if (!PlayState.instance.isSansGone) add(sans);
		}
		

		/*var sign:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pause/placeholder', 'shared'));
		sign.setGraphicSize(Std.int(sign.width * 10));
		sign.updateHitbox();
		sign.setPosition(10, 275);
		add(sign);*/

		var levelHeader:FlxText = new FlxText(20, 10, 0, "F N F '  :  P O O P S H I T T E R S", 54);
		levelHeader.scrollFactor.set();
		levelHeader.setFormat(Paths.font(PlayState.SONG.song == 'Too Far' ? 'arial.ttf' : '8bitoperator_jve.ttf'), 54, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelHeader.borderSize = 3;
		levelHeader.updateHitbox();
		levelHeader.screenCenter(X);
		levelHeader.antialiasing = false;
		add(levelHeader);

		var levelInfo:FlxText = new FlxText(20, 60, 0, "NOW PLAYING: " + PlayState.SONG.song.toUpperCase(), 36);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font(PlayState.SONG.song == 'Too Far' ? 'arial.ttf' : "8bitoperator_jve.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.borderSize = 3;
		levelInfo.updateHitbox();
		levelInfo.screenCenter(X);
		levelInfo.antialiasing = false;
		add(levelInfo);

		grpMenuShit = new FlxTypedGroup<PauseButton>();
		add(grpMenuShit);
		
		soul = new Soul(45, 627);
		soul.scale.set(1.8, 1.8);
        soul.updateHitbox();
		soul.visible = !FlxG.mouse.visible;
		add(soul);

		blackout = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackout.visible = false;
		blackout.scrollFactor.set();
		add(blackout);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var pausechar:String = 'pause_' + (ClientPrefs.data.funVal == 99 ? 'pyrus' : 'sans');
		if (Trophies.pauseTracker[pausechar.endsWith('pyrus') ? 1 : 0] >= 49 && !Trophies.getTrophyStats(pausechar, UNLOCKED)) {
            Trophies.unlockTrophy(pausechar);
            add(new TrophyPopup(pausechar, cameras[cameras.length - 1]));
		}
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float) {
		if (soul.curAnim.startsWith('flee')) soul.x += 3;

		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_LEFT_P;
		var downP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var talkless = controls.DIA_NEXT;
		var finishnow = controls.DIA_SKIP;

		if (upP && !selectSmth) changeSelection(-1);
		if (downP && !selectSmth) changeSelection(1);

		if (FlxG.mouse.visible && !selectSmth) {
			if (FlxG.mouse.y > 800 && FlxG.mouse.y < 940) {
				if (FlxG.mouse.x < 86 && FlxG.mouse.x > -230) {
					if (curSelected != 0) changeSelection(0, 0);
				} else if (FlxG.mouse.x < 510 && FlxG.mouse.x > 170) {
					if (curSelected != 1) changeSelection(0, 1);
				} else if (FlxG.mouse.x < 930 && FlxG.mouse.x > 590) {
					if (curSelected != 2) changeSelection(0, 2);
				} else if (FlxG.mouse.x < 1300 && FlxG.mouse.x > 1010) {
					if (curSelected != 3) changeSelection(0, 3);
				}
				if (FlxG.mouse.justPressed) selectThing();
			}
		}
		
		if (accepted && (cantUnpause <= 0 || !controls.controllerMode)) {
			selectThing();
		}
		
		if (ClientPrefs.data.funVal != 99 && sans.gone && !PlayState.instance.isSansGone) {
			FlxG.sound.play(Paths.sound('black_out', 'overworld'));
			blackout.visible = true;
			sans.gone = false;
			sans.visible = sans.active = false;

			new FlxTimer().start(0.25, function(tmr:FlxTimer) {
				FlxG.sound.play(Paths.sound('black_out', 'overworld'));
				blackout.visible = false;
			});
		}
	}
	
	var selectSmth:Bool = false;
	function selectThing() {
		if (selectSmth) return;
		selectSmth = true;

		switch (menuItems[curSelected]) {
			case "Resume":
				close();
			case "Restart":
				PlayState.instance.paused = true; // For lua
				FlxG.sound.music.volume = 0;
				PlayState.instance.pvocals.volume = 0;
				PlayState.instance.ovocals.volume = 0;
		
				MusicBeatState.resetState();
			case 'Options':
				PlayState.instance.paused = true; // For lua
				PlayState.instance.pvocals.volume = 0;
				PlayState.instance.ovocals.volume = 0;                    
				MusicBeatState.whatTransition = "settings";
				MusicBeatState.doTransition = true;
				MusicBeatState.switchState(new OptionsState());
				FlxG.sound.playMusic(Paths.pauseMusic(PlayState.SONG.song), pauseMusic.volume);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
				FlxG.sound.music.time = pauseMusic.time;
				OptionsState.onPlayState = true;
			case "Flee":
				soul.playAnim('flee');
				new FlxTimer().start(PlayState.SONG.song == 'Too Far' ? 0.01 : 1, function(tmr:FlxTimer) {
					#if desktop DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					if(PlayState.isStoryMode) {
						CoolUtil.plrhealth = Std.int(PlayState.instance.karma);
						Overworld.map = SongData.allSongs.get(Paths.formatToSongPath(PlayState.SONG.song)).overworld;
						if (PlayState.SONG.song == 'Too Far') Player.forgetPos();
						MusicBeatState.switchState(new Overworld());
						Overworld.fled = true;
					} else {
						MusicBeatState.switchState(new Freepoop());
					}
					PlayState.cancelMusicFadeTween();
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
				});
		}
	}

	override function destroy() {
		if (ClientPrefs.data.funVal == 99) {
			remove(papyrus);
			papyrus.destroy();
		} else {
			remove(sans);
			sans.destroy();
		}

		FlxG.mouse.visible = false;

		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0, forceChange:Int = 99):Void {
		curSelected += change;

		if (forceChange < 99) curSelected = forceChange;

		if (change != 0 || forceChange < 99) FlxG.sound.play(Paths.sound('select'));

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		for (item in grpMenuShit.members) {
			item.playAnim(curSelected);

			if (item.itemNum == curSelected) soul.x = item.x + 5;
		}
	}

	function regenMenu():Void {
		var xpos:Array<Int> = [20, 257, 510, 760];
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new PauseButton(xpos[i], 620, i, curSelected);
			grpMenuShit.add(item);
		}
		curSelected = 0;

		changeSelection();
	}
}
