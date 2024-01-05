package states.editors;

#if MODS_ALLOWED
import sys.FileSystem;
#end

import objects.Character;
import states.Freepoop;

class MasterEditorMenu extends MusicBeatState {
	var options:Array<String> = [
		'Chart Editor',
		'Character Editor',
		'Week Editor',
		'Note Splash Debug'
	];
	private var grpTexts:FlxTypedGroup<FlxText>;
	private var curSelected = 0;

	override function create() {
		#if desktop // Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = false;
		bg.color = 0xff00ddff;
		add(bg);

		grpTexts = new FlxTypedGroup<FlxText>();
		add(grpTexts);

		for (i in 0...options.length) {
			var leText:FlxText = new FlxText(0, 100 + (150 * i), options[i]);
			leText.setFormat(Paths.font("undertale-dotumche.ttf"), 48, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			leText.borderSize = 4;
			leText.antialiasing = false;
			leText.ID = i;
			leText.screenCenter(X);
			grpTexts.add(leText);
		}
		
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);
		if (controls.BACK) MusicBeatState.switchState(new Freepoop());

		if (controls.ACCEPT) {
			switch(options[curSelected]) {
				case 'Chart Editor': LoadingState.loadAndSwitchState(new ChartingState(), false);
				case 'Character Editor': LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Week Editor': MusicBeatState.switchState(new WeekEditorState());
				case 'Note Splash Debug': LoadingState.loadAndSwitchState(new NoteSplashDebugState());
			}
			FlxG.sound.music.volume = 0;
		}
		
		var bullShit:Int = 0;
		for (item in grpTexts.members) {
			item.ID = bullShit - curSelected;
			bullShit++;

			if (item.ID == 0) item.color = FlxColor.YELLOW;
			else item.color = FlxColor.WHITE;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('select'), 0.4);

		curSelected += change;

		if (curSelected < 0) curSelected = options.length - 1;
		if (curSelected >= options.length) curSelected = 0;
	}
}