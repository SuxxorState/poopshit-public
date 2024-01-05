package options;

import states.Freepoop;
import backend.StageData;
import flixel.addons.display.shapes.FlxShapeCircle;

class OptionsState extends MusicBeatState {
	var options:Array<String> = ['Exit', 'Language', 'Note Colors', 'Control Config', 'Note Offset', 'Graphics, Visuals, and UI', 'Gameplay', 'Settings'];
	var optionsY:Array<Float> = [0, 50, 115, 130, 145, 195, 210, 225];
	private var particles:FlxTypedGroup<SetParticle>;
	private var ass:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	public static var instance:OptionsState;

	private var offsetTxt:FlxText;
	private var offset:Float = 0;
	var beatTxt:FlxText;
	var languages:Array<String> = ["English"];
	var langTxt:FlxText;
	var beatTwn:FlxTween;
	var memX:Array<Null<Float>> = [];
	var memTwns:Map<Int, FlxTween> = new Map<Int, FlxTween>();
	var mainActive:Bool = true;
	var annoydog:FlxSprite;
	var quoteTxt:FlxText;
	var sun:FlxSprite;
	var msc:FlxTimer = null;

	function openSelectedSubstate(label:String) {
		FlxG.sound.play(Paths.sound('confirm'));
		for (twn in memTwns) twn.cancel();
		for (i in 0...ass.members.length) {
			var member = ass.members[i];

			if (memX[i*2] == null) memX[i*2] = member.x;
			if (memX[(i*2)+1] == null) memX[(i*2)+1] = member.alpha;
			memTwns.set(i*2, FlxTween.tween(member, {x: memX[i*2] - 615}, 1, {ease: FlxEase.sineOut}));
			if (member.ID != 420) memTwns.set((i*2) + 1, FlxTween.tween(member, {alpha: 0}, 1, {ease: FlxEase.sineOut}));
		}
		mainActive = false;

		switch(label) {
			case 'Exit':
				if(beatTwn != null) beatTwn.cancel();
				if(onPlayState) {
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
					onPlayState = false;
				} else MusicBeatState.switchState(new Freepoop());
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Control Config':
				openSubState(new options.ControlsSubState());
			case 'Graphics, Visuals, and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Settings':
				openSubState(new options.SettingsSettingsSubState());
		}
	}

	override function create() {
		mainActive = false;
		#if desktop
		DiscordClient.changePresence("Settings Menu", null);
		#end
		offset = ClientPrefs.data.noteOffset;
		instance = this;

		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		msc = new FlxTimer().start(1.5, function(tmr:FlxTimer){FlxG.sound.playMusic(getSeasonal('music'), 1, true);mainActive = true;});
		Conductor.changeBPM(getSeasonal('bpm'));

		persistentUpdate = true;
		persistentDraw = true;
		
		particles = new FlxTypedGroup<SetParticle>();
		add(particles);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length) {
			var optionText:FlxText = new FlxText(50, 130 + (35 * i) + optionsY[i], 0, options[i].toUpperCase());
			optionText.setFormat(Paths.font("DTM-Mono.ttf"), 40, FlxColor.WHITE, LEFT);
			optionText.antialiasing = false;
			optionText.scale.x = Math.min(1, 18 / (optionText.text.length + 2));
			optionText.updateHitbox();
			optionText.x = 50;
			optionText.ID = i;
			ass.add(optionText);
			grpOptions.add(optionText);

			if (options[i] == "Language") {
				langTxt = new FlxText(optionText.x + optionText.width + 50, 130 + (35 * i) + optionsY[i], languages[0].toUpperCase());
				langTxt.setFormat(Paths.font("DTM-Mono.ttf"), 40, FlxColor.WHITE, LEFT);
				langTxt.antialiasing = false;
				ass.add(langTxt);
				add(langTxt);
			} else if (options[i] == 'Note Offset') {
				offsetTxt = new FlxText(optionText.x + optionText.width + 50, 130 + (35 * i) + optionsY[i], 0, ClientPrefs.data.noteOffset + ' MS');
				offsetTxt.setFormat(Paths.font("DTM-Mono.ttf"), 40, FlxColor.WHITE, LEFT);
				offsetTxt.antialiasing = false;
				ass.add(offsetTxt);
				add(offsetTxt);
			}
		}

		sun = new FlxShapeCircle(FlxG.width - 275, 0, 128, {thickness: 0}, 0xFFFFF000);
		sun.antialiasing = false;
		sun.scale.set(0.75, 0.75);
		sun.active = sun.visible = (getSeasonal('season') == 'summer');
		add(sun);
		if (getSeasonal('season') == 'summer') suntween();

		beatTxt = new FlxText(0, 670, '-BEAT HIT-');
		beatTxt.setFormat(Paths.font("DTM-Mono.ttf"), 36, FlxColor.WHITE, LEFT);
		beatTxt.alpha = 0;
		beatTxt.antialiasing = false;
		beatTxt.screenCenter(X);
		ass.add(beatTxt);
		add(beatTxt);

		quoteTxt = new FlxText(590, 400, 320, getSeasonal('quote'));
		quoteTxt.setFormat(Paths.font("DTM-Mono.ttf"), 36, FlxColor.WHITE, LEFT);
		quoteTxt.antialiasing = false;
		quoteTxt.angle = 30;
		quoteTxt.alpha = 0.5;
		ass.add(quoteTxt);
		add(quoteTxt);
		
		annoydog = new FlxSprite(700, 650).loadGraphic(Paths.image('settings/dog'), true, 28, 28);
		annoydog.antialiasing = false;
		annoydog.setGraphicSize(Std.int(annoydog.width * 3));
		annoydog.updateHitbox();
		annoydog.animation.add('spring', [2,3,2,4], 2);
		annoydog.animation.add('summer', [5,6], 2);
		annoydog.animation.add('autumn', [0]);
		annoydog.animation.add('winter', [1]);
		annoydog.animation.play(getSeasonal('season'));
		annoydog.ID = 420;
		ass.add(annoydog);
		add(annoydog);
		if (getSeasonal('season') == 'summer') dogtween();

		var title:FlxText = new FlxText(0, 30, 0, 'SETTINGS');
		title.setFormat(Paths.font("DTM-Mono.ttf"), 80, FlxColor.WHITE, CENTER);
		title.screenCenter(X);
		title.antialiasing = false;
		ass.add(title);
		add(title);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	public function twnBack() {
		for (twn in memTwns) twn.cancel();
		for (i in 0...ass.members.length) {
			var member = ass.members[i];
			memTwns.set(i*2, FlxTween.tween(member, {x: memX[i*2]}, 1, {ease: FlxEase.sineOut}));
			memTwns.set((i*2)+1, FlxTween.tween(member, {alpha: memX[(i*2)+1]}, 1, {ease: FlxEase.sineOut}));
		}
		mainActive = true;
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	var suntwn:FlxTween;
	function suntween() {
		suntwn = FlxTween.tween(sun.scale, {x: 0.5, y: 0.5}, 0.75, {ease: FlxEase.sineInOut, onComplete: function (twn:FlxTween) {
			suntwn = FlxTween.tween(sun.scale, {x: 0.75, y: 0.75}, 0.75, {ease: FlxEase.sineInOut, onComplete: function (twn:FlxTween) {suntween();}});
		}});
	}

	var dogtwn:FlxTween;
	function dogtween() {
		dogtwn = FlxTween.tween(annoydog.scale, {x: 5, y: 2}, 1.5, {ease: FlxEase.sineInOut, onComplete: function (twn:FlxTween) {
			dogtwn = FlxTween.tween(annoydog.scale, {x: 2, y: 5}, 1.5, {ease: FlxEase.sineInOut, onComplete: function (twn:FlxTween) {dogtween();}});
		}});
	}
	
	var holdTime:Float = 0;
	var qtangle:Float = 0;
	var sunang:Float = 0;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (quoteTxt != null) {
			qtangle -= 3 * elapsed;
			quoteTxt.offset.set(Math.cos(qtangle) * 3, Math.sin(qtangle) * 3);
		}
		if (sun.active) {
			sunang += 2 * elapsed;
			sun.offset.set(Math.cos(sunang) * 15, Math.sin(sunang) * 15);
		}

		if (quoteTxt.x <= 0 || quoteTxt.y <= 0) quoteTxt.visible = false;
		else if (!quoteTxt.visible) quoteTxt.visible = true;
		
		if (getSeasonal('season') != 'summer' && particles.members.length < 120) {
			var particle:SetParticle = new SetParticle(getSeasonal('season'));
			particles.add(particle);
		}

		if (mainActive) {
			var addNum:Int = 1;
			if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER)) addNum = 3;

			if (controls.UI_UP_P) changeSelection(-1);
			if (controls.UI_DOWN_P) changeSelection(1);

			switch(options[curSelected]) {
				case 'Note Offset':
					if(controls.UI_LEFT_P) {
						offset = FlxMath.bound(offset - 1, -500, 500);
						updateOffset();
					} else if(controls.UI_RIGHT_P) {
						offset = FlxMath.bound(offset + 1, -500, 500);
						updateOffset();
					}
		
					var mult:Int = 1;
					if(controls.UI_LEFT || controls.UI_RIGHT) {
						holdTime += elapsed;
						if(controls.UI_LEFT) mult = -1;
					}
		
					if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;
		
					if(holdTime > 0.5) {
						offset += 100 * addNum * elapsed * mult;
						offset = FlxMath.bound(offset, -500, 500);
						updateOffset();
					}
		
					if(controls.RESET) {
						holdTime = 0;
						offset = 0;
						updateOffset();
					}
				case 'Language':

				default:
					if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
			}

			if (controls.BACK) openSelectedSubstate('Exit');
		}
		
		Conductor.songPosition = FlxG.sound.music.time;
	}

	var lastBeatHit:Int = -1;
	override public function beatHit() {
		super.beatHit();
		if(lastBeatHit == curBeat) return;

		switch(options[curSelected]) {
			case 'Note Offset':
				if (curBeat % 4 == 2) {
					if(beatTwn != null) beatTwn.cancel();
					beatTxt.alpha = 0.5;
					beatTwn = FlxTween.tween(beatTxt, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween){beatTwn = null;}});
				}
		}
		
		lastBeatHit = curBeat;
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		for (item in grpOptions.members) {
			if (item.ID == curSelected) item.color = FlxColor.YELLOW;
			else item.color = FlxColor.WHITE;
		}

		langTxt.color = options[curSelected] == 'Language' ? FlxColor.YELLOW : FlxColor.WHITE;
		offsetTxt.color = options[curSelected] == 'Note Offset' ? FlxColor.YELLOW : FlxColor.WHITE;
		beatTxt.visible = options[curSelected] == 'Note Offset';
		
		if (change != 0) FlxG.sound.play(Paths.sound('select'));
	}
	
	function updateOffset() {
		ClientPrefs.data.noteOffset = Math.round(offset);
		offsetTxt.text = ClientPrefs.data.noteOffset + ' MS';
	}
	
	final south:Bool = ClientPrefs.data.southSeasons;
	function getSeasonal(data:String = ''):Null<Dynamic> {
		var season:String = 'autumn';
		var thing:Null<Dynamic> = null;
		
		var seasonShit:Map<String, Array<Dynamic>> = [
			'spring' => ['UwaSoShitterate', ["spring time back to school", "my favorite weather is bird chirping weather", "is it safe to come out of hibernation", "where flowers bloom, so does hope", "despite the forecast, live like it's spring"]],
			'summer' => ['UwaSoIMFUCKINGMELTING', ["try to withstand the sun's life-giving rays", "it's always summer somewhere", "salt in the air, sand in my hair", "keep calm, summer is here", "that crazy sun of a beach"]],
			'autumn' => ['UwaSoShitterate', ["don't stop be-leafing", "orange you glad it's autumn", "sweep a leaf sweep away a troubles", "man school sucks", "halloween is the best"]],
			'winter' => ['UwaSoCanadian', ["cold outside but stay warm inside of you", "feelin' frosty", "does shivering count as exercise", "it's hard to look cool and be warm at the same time", "can we skip to next season already please"]]
		];
		
		switch (Date.now().getMonth()) {
			case 11 | 0 | 1: season = south ? 'summer' : 'winter';
			case 2 | 3 | 4: season = south ? 'autumn' : 'spring';
			case 5 | 6 | 7: season = south ? 'winter' : 'summer';
			case 8 | 9 | 10: season = south ? 'spring' : 'autumn';
		}

		switch (data) {
			case 'music': thing = Paths.music(seasonShit.get(season)[0]);
			case 'quote':
				var list:Array<String> = seasonShit.get(season)[1];
				thing = list[FlxG.random.int(0, list.length - 1)];

				if (FlxG.random.bool(1)) {
					var altList:Array<String> = ["all toasters toast toast", "dookie doo doo fart shit ass", "how are your balls", "name yourself exe or don't", "human i remember you're genocides", "we destroyed casino crash in 2012"];
					thing = altList[FlxG.random.int(0, altList.length - 1)];
				}
			case 'season': thing = season;
			case 'bpm': thing = (season == 'summer' ? 114 : 140);
			default:
		}

		return thing;
	}

	override function destroy() {
		ClientPrefs.loadPrefs();
		for (twn in memTwns) twn.cancel();
		if (suntwn != null) suntwn.cancel();
		if (dogtwn != null) dogtwn.cancel();
		if (msc != null) msc.cancel();
		instance = null;

		super.destroy();
	}

}

class SetParticle extends FlxSprite {
    var movex:Int = 0;
    var movey:Int = 0;
	var moveang:Int = 0;
    var refresh:Null<Void->Void>;
	var seasonshit:Map<String, Array<FlxColor>> = [
		'spring' => [0xFFDB6953],
		'autumn' => [0xFFC6000D,0xFFB76E2A,0xFFC3C600],
		'winter' => [0xFFFFFFFF]
	];

	public function new(season:String, ?onComp:Null<Void->Void>) {
        super();
        refresh = onComp;
		antialiasing = false;

        loadGraphic(Paths.image('settings/particles'), true, 7,7);
		animation.add('leaf', [0]);
		animation.add('flake', [1]);
		animation.play(season == 'winter' ? 'flake' : 'leaf');
		color = seasonshit.get(season)[FlxG.random.int(0, seasonshit.get(season).length - 1)];

		alpha = 0.6;
		setGraphicSize(Std.int(width * 3));
		updateHitbox();
        
		recycle();
    }

    public function recycle() {
        if (refresh != null) refresh();
        setPosition(FlxG.random.int(-200,1100), -100);
        movex = (FlxG.random.bool() ? -1 : 1) * FlxG.random.int(2,40);
        movey = FlxG.random.int(20,40);
		moveang = (FlxG.random.bool() ? -1 : 1) * FlxG.random.int(20,30);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        y += 5 * movey * elapsed;
        x -= 7 * movex * elapsed;
		angle += 5 * moveang * elapsed;
        if (y > 800 || x < -100 || x > 1000) recycle();
    }
}
