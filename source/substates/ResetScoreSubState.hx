package substates;

import backend.Highscore;

class ResetScoreSubState extends MusicBeatSubstate {
	var bg:FlxSprite;
	var textArray:Array<FlxText> = [];
	var char:NPC;
	var charShit:Array<String> = [];
	var charOff:Array<Float> = [];
	var onYes:Bool = false;
	var yesText:FlxText;
	var noText:FlxText;
	var soul:Soul;

	var song:String;
	var difficulty:Int = 0;
	var week:Int;

	public function new(song:String, charc:Array<String>, off:Array<Float>) {
		this.song = song;
		this.charShit = charc;
		if (charShit == null || charShit.length < 1) charShit = ['', 'idle', 'idle', 'idle'];
		do {charShit.push('idle');} while (charShit.length < 4);
		charOff = off;
		do {charOff.push(0);} while (charOff.length < 2);

		super();

		var name:String = song;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:FlxText = new FlxText(0, 100, 0, "Reset the score of");
		text.setFormat(Paths.font("DTM-Mono.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 4;
		text.screenCenter(X);
		textArray.push(text);
		text.alpha = 0;
		add(text);

		var text:FlxText = new FlxText(0, text.y + 60, 0, name + "?");
		text.setFormat(Paths.font("DTM-Mono.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 4;
		text.screenCenter(X);
		textArray.push(text);
		text.alpha = 0;
		add(text);
	
		char = new NPC('sans');
		char.current = charShit[0];
		char.setGraphicSize(char.width * 6);
		char.setPosition(120, FlxG.height - (char.height - 20 + (charOff[0] * 6)) + (charOff[1] * 6));
		char.alpha = 0;
		add(char);

		yesText = new FlxText(0, text.y + 100, 0, 'Yes', 32);
		yesText.setFormat(Paths.font("DTM-Mono.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.borderSize = 4;
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new FlxText(0, text.y + 100, 0, 'No', 32);
		noText.setFormat(Paths.font("DTM-Mono.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.borderSize = 4;
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);

		soul = new Soul(noText.x - 20, 0, true);
		soul.scale.set(3,3);
		soul.updateHitbox();
		soul.y = noText.y + 3;
		soul.alpha = 0;
		add(soul);

		updateOptions();
	}

	var selectedSmth:Bool = false;
	override function update(elapsed:Float) {
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...textArray.length) {
			var spr = textArray[i];
			spr.alpha += elapsed * 2.5;
		}
		char.alpha += elapsed * 2.5;
		soul.alpha += elapsed * 2.5;

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('select'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('select'), 1);
			close();
		} else if(controls.ACCEPT && !selectedSmth) {
			selectedSmth = true;
			if(onYes) {
				soul.menuShatter(function() {
					Highscore.resetSong(song, difficulty);
					close();
				});
			} else {
				FlxG.sound.play(Paths.sound('select'), 1);
				close();
			}
		}
		super.update(elapsed);
	}

	function updateOptions() {
		//yesText.color = onYes ? FlxColor.YELLOW : FlxColor.WHITE;
		//noText.color = !onYes ? FlxColor.YELLOW : FlxColor.WHITE;

		char.playAnim(charShit[onYes? 2 : 3]);
		soul.x = (onYes ? yesText.x : noText.x) - (35 + soul.actual.width);
	}
}