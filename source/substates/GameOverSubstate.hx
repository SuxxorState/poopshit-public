package substates;

import backend.SongData;
import backend.Highscore;
import backend.Trophies;
import backend.Dialogue;

import objects.Character;
import objects.TrophyPopup;

import states.Overworld;
import states.Freepoop;
import objects.Player;

class GameOverSubstate extends MusicBeatSubstate {
	public static var gameOverTypes:Array<String> = ['undertale', 'papyrus-exe', 'none'];
	public static var instance:GameOverSubstate;
	public static var goVars:GameOverVars = {};
	var deathStage:Int = 0;

	public var soul:Soul;
	var gameover:FlxText;
	var dialogueTxt:UTTypeText;
	var dialogue:Array<String> = [];
	var curDia:Int = 0;

	var sex:FlxSound;
	var fuckYou:FlxSprite;
	var scaryOver:FlxSprite;
	var isEnding:Bool = false;

	public static function resetVariables() {
		goVars.type = 'undertale';
		goVars.character = 'asgore';
		goVars.musicLoop = 'demoralization';
		goVars.songEnded = false;
		
		var _song = PlayState.SONG;
		if(_song != null) {
			if(_song.gameOverType != null && _song.gameOverType.trim().length > 0) goVars.type = _song.gameOverType;
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) goVars.character = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) goVars.deathSound = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) goVars.musicLoop = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) goVars.musicEnd = _song.gameOverEnd;
		}
	}

	override function create() {
		instance = this;
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, isSongEnd:Bool = false) {
		super();
		PlayState.instance.setOnScripts('inGameOver', true);
		Conductor.songPosition = 0;
		goVars.songEnded = isSongEnd;
		Player.forgetPos();

		switch(goVars.type) {
			case 'none':
				if (PlayState.isStoryMode) MusicBeatState.switchState(new Overworld());
				else MusicBeatState.resetState();

			case 'papyrus-exe':
				if (isSongEnd && PlayState.instance.songMisses <= 0 && !Trophies.getTrophyStats('too-far_fc', UNLOCKED)) {
					Trophies.unlockTrophy('too-far_fc');
					add(new TrophyPopup('too-far_fc', PlayState.instance.camOther));
				}
				sex = new FlxSound().loadEmbedded(Paths.sound('SansDies', 'papyruexe'));
				sex.play();
				fuckYou = new FlxSprite().loadGraphic(Paths.image('scaryass'));
				fuckYou.cameras = [PlayState.instance.camHUD];
				fuckYou.screenCenter();
				scaryOver = new FlxSprite().loadGraphic(Paths.image('gameover'));
				scaryOver.cameras = [PlayState.instance.camHUD];
				scaryOver.setGraphicSize(FlxG.width);
				scaryOver.updateHitbox();
				scaryOver.screenCenter();

			default:
				var boyfriend:Character = new Character(x, y, PlayState.instance.boyfriend.curCharacter, true);
				soul = new Soul(x + boyfriend.positionArray[0] + (boyfriend.width * 0.67),y + boyfriend.positionArray[1] + (boyfriend.height / 3));
				soul.scale.set(1.5,1.5);
				soul.cameras = [PlayState.instance.camHUD];
				add(soul);
	
				gameover = new FlxText(0, 20, 0, 'GAME\nOVER');
				gameover.cameras = [PlayState.instance.camHUD];
				gameover.setFormat(Paths.font('8-bit-wonder.TTF'), 148, FlxColor.WHITE, CENTER);
				gameover.screenCenter(X);
				gameover.antialiasing = false;
				gameover.alpha = 0;
				add(gameover);

				var charData:CharOptions = Dialogue.getCharData(goVars.character);
				dialogue = Dialogue.getDead(goVars.character);
				
				dialogueTxt = new UTTypeText(200, 500, 500, '', charData.typeFont, Std.int(32 * charData.fontSizeMult));
				dialogueTxt.cameras = [PlayState.instance.camHUD];

				var soundbs:Array<FlxSound> = [];
				if (charData.sbAmt > 1) for (i in 0...charData.sbAmt) soundbs.push(new FlxSound().loadEmbedded(Paths.sound('dialogue/${goVars.character}/$i', 'overworld')));
				else soundbs.push(new FlxSound().loadEmbedded(Paths.sound('dialogue/${charData.soundByte}', 'overworld')));
				dialogueTxt.sounds = soundbs;

				add(dialogueTxt);
	
				FlxG.camera.scroll.set();
				FlxG.camera.target = null;
		}

		if (PlayState.deathCounter >= 1 && !Trophies.getTrophyStats('krill_yourself', UNLOCKED)) {
            new FlxTimer().start(0.5, function(Tmr:FlxTimer) {
                Trophies.unlockTrophy('krill_yourself');
                add(new TrophyPopup('krill_yourself', PlayState.instance.camOther));
            });
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (deathStage > 1) {
			if (controls.ACCEPT || (controls.BACK && goVars.songEnded)) endBullshit();

			if (controls.BACK && !goVars.songEnded && !isEnding) {
				#if desktop DiscordClient.resetClientID(); #end
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				isEnding = true;

				FlxG.sound.music.fadeOut(1.9, 0, function(Twn:FlxTween) {FlxG.sound.music.stop();});
				PlayState.instance.camHUD.fade(FlxColor.BLACK, 2, false, function() {
					if (PlayState.isStoryMode) {
						Overworld.map = SongData.allSongs.get(Paths.formatToSongPath(PlayState.SONG.song)).overworld;
						MusicBeatState.switchState(new Overworld());
					} else {
						MusicBeatState.switchState(new Freepoop());
						Overworld.fled = false;
						PlayState.deathCounter = 0;
					}
				});

				PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
			}
		}

		switch (goVars.type) {
			case 'none':

			case 'papyrus-exe':
				sex.volume = FlxG.sound.volume;
				if (!isEnding) {
					if (!sex.playing && deathStage == 0) {
						add(fuckYou);
						sex = new FlxSound().loadEmbedded(Paths.sound('Springtrap', 'papyruexe'));
						sex.play();
						deathStage = 1;
					} else if ((!sex.playing && deathStage == 1) || controls.ACCEPT) {
						remove(fuckYou);
						sex.stop();
						FlxG.sound.playMusic(Paths.sound('GameOverEXE', 'papyruexe'));
						add(scaryOver);
						deathStage = 2;
					}
				}

			default:
				if (soul.curAnim != '' && soul.curAnim != 'shatter' && deathStage == 0) {
					deathStage = -1; //so that no events are triggered whilst the timer is going and that the player cant continue
					new FlxTimer().start(0.25, function(tmr:FlxTimer) {soul.playAnim('break');});
					new FlxTimer().start(1.25, function(tmr:FlxTimer) {
						soul.playAnim('shatter');
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {deathStage = 1;});
					});
				} else if (deathStage == 1) {
					deathStage = -2;

					FlxG.sound.playMusic(Paths.music(goVars.musicLoop));
					FlxTween.tween(gameover, {alpha: 1}, 2, {onComplete: function(twn:FlxTween) {
						deathStage = -3;
						dialogueTxt.resetText(dialogue[0]);
						if (dialogue[curDia] == '' || dialogue[curDia] == null) {
							diaFin = true;
							curDia++;
							if (curDia >= dialogue.length) deathStage = 2;
						} else {
							dialogueTxt.start(0.06, function() {
								diaFin = true;
								curDia++;
								if (curDia >= dialogue.length) deathStage = 2;
							});
						}
					}});
				} else if (deathStage == -3 && (controls.ACCEPT || controls.DIA_NEXT) && diaFin) {
					diaFin = false;
					dialogueTxt.resetText(dialogue[curDia]);
					if (dialogue[curDia] == '' || dialogue[curDia] == null) {
						diaFin = true;
						curDia++;
						if (curDia >= dialogue.length) deathStage = 2;
					} else {
						dialogueTxt.start(0.06, function() {
							diaFin = true;
							curDia++;
							if (curDia >= dialogue.length) deathStage = 2;
						});
					}
				}
		}

		if (FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var diaFin:Bool = false;

	function endBullshit():Void {
		if (isEnding) return;

		CoolUtil.reloadHP(true);
		isEnding = true;

		switch (goVars.type) {
			case 'papyrus-exe':
				FlxG.sound.music.stop();
				sex.stop();
				if (goVars.songEnded) {
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, 1);
						FlxG.save.flush();
					}
					PlayState.instance.checkUnlockSong();
					MusicBeatState.switchState(new Freepoop());
				} else {
					FlxG.sound.play(Paths.sound('ConfirmLaugh', 'papyruexe'));
					FlxTween.tween(scaryOver, {alpha: 0}, 3.5, {onComplete:function(twn:FlxTween) {
						if (PlayState.isStoryMode) {
							Overworld.map = SongData.allSongs.get(Paths.formatToSongPath(PlayState.SONG.song)).overworld;
							MusicBeatState.switchState(new Overworld());
						} else 
							MusicBeatState.resetState();
					}});
				}

			default:
				FlxG.sound.music.fadeOut(1.9, 0, function(Twn:FlxTween) {FlxG.sound.music.stop();});
				//FlxG.sound.play(Paths.music(goVars.musicEnd));
				PlayState.instance.camHUD.fade(FlxColor.BLACK, 2, false, function() {
					if (PlayState.isStoryMode) {
						MusicBeatState.switchState(new Overworld());
					} else
						MusicBeatState.resetState();
				});
		}

		PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
	}

	override function destroy() {
		instance = null;
		super.destroy();
	}
}

typedef GameOverVars = {
	@:optional var type:String;
    @:optional var songEnded:Bool;

    @:optional var character:String;
    @:optional var deathSound:String;
    @:optional var musicLoop:String;
    @:optional var musicEnd:String;
}