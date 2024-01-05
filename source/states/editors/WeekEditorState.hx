package states.editors;

import backend.SongData;

import openfl.utils.Assets;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import lime.system.Clipboard;
import objects.MenuText;
import tjson.TJSON as Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import objects.HealthIcon;
//import objects.MenuCharacter;
//import objects.MenuItem;

import states.editors.MasterEditorMenu;

class WeekEditorState extends MusicBeatState {
	var weekFile:SongFile = null;
	public function new(weekFile:SongFile = null)
	{
		super();
		this.weekFile = SongData.createSongFile();
		if(weekFile != null) this.weekFile = weekFile;
	}

    var bg:FlxSprite;
    var nameTxt:FlxText;
    var loveTxt:FlxText;
    var timeTxt:FlxText;
    var songtxt:FlxText;
    var char:NPC;

	override function create() {
		FlxG.mouse.visible = true;
        bg = new FlxSprite(0, -375).loadGraphic(Paths.image('freeplayOW/room-' + weekFile.bgVariant));
        bg.setGraphicSize(Std.int(bg.width * 3));
        bg.updateHitbox();
        bg.screenCenter(X);
        bg.antialiasing = false;
		add(bg);
      
        char = new NPC(weekFile.songChar[0], 470, 440);
        char.playAnim(weekFile.songChar[1]);
        char.setGraphicSize(char.width * 3);
        add(char);

        FlxG.sound.music.stop();
        FlxG.sound.playMusic(Paths.music(weekFile.bgMusic));

        nameTxt = new FlxText(270, 150, 0, (weekFile.playerName != null && weekFile.playerName != '') ? weekFile.playerName : ClientPrefs.data.charName, 32);
        nameTxt.antialiasing = false;
        nameTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(nameTxt);  

        loveTxt = new FlxText(0, 150, 0, 'LV ${weekFile.level}', 32);
        loveTxt.antialiasing = false;
        loveTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        loveTxt.screenCenter(X);
        add(loveTxt);  

        timeTxt = new FlxText(610, 150, 0, "0", 32);
        timeTxt.antialiasing = false;
        timeTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(timeTxt);  

        songtxt = new FlxText(0, 200, 0, weekFile.song, 32);
        songtxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songtxt.updateHitbox();
        songtxt.screenCenter(X);
        songtxt.antialiasing = false;
        add(songtxt);  

		addEditorBox();
		super.create();

		reloadAllShit();
	}

	var UI_box:FlxUITabMenu;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	function addEditorBox() {
		var tabs = [
			{name: 'Character', label: 'Character'},
			{name: 'Song', label: 'Song'},
		];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(250, 200);
		UI_box.x = FlxG.width - UI_box.width - 100;
		UI_box.y = FlxG.height - UI_box.height - 60;
		UI_box.scrollFactor.set();
		
		UI_box.selected_tab_id = 'Week';
		addSongUI();
		addCharacterUI();
		add(UI_box);

		var loadWeekButton:FlxButton = new FlxButton(0, 685, "Load Week", function() {
			loadWeek();
		});
		loadWeekButton.screenCenter(X);
		loadWeekButton.x -= 60;
		add(loadWeekButton);
	
		var saveWeekButton:FlxButton = new FlxButton(0, 685, "Save Week", function() {
			saveWeek(weekFile);
		});
		saveWeekButton.screenCenter(X);
		saveWeekButton.x += 60;
		add(saveWeekButton);
	}
	
	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if (sender == songInputTxt) {
				weekFile.song = songInputTxt.text;
				songtxt.text = weekFile.song;
				songtxt.updateHitbox();
				songtxt.screenCenter(X);
			} else if (sender == nameInputTxt) {
				weekFile.playerName = nameInputTxt.text;
				nameTxt.text = weekFile.playerName;
			} else if (sender == overworldInputTxt) {
				weekFile.overworld = overworldInputTxt.text;
			} else if (sender == musicInputTxt) {
				weekFile.bgMusic = musicInputTxt.text;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music(weekFile.bgMusic));
			} else if (sender == bgInputTxt) {
				weekFile.bgVariant = bgInputTxt.text;
				bg.loadGraphic(Paths.image('freeplayOW/room-' + weekFile.bgVariant));
				bg.setGraphicSize(Std.int(bg.width * 3));
				bg.updateHitbox();
				bg.screenCenter(X);
				bg.antialiasing = false;
			} else if (sender == charNameInputTxt || sender == idleNameInputTxt || sender == yesNameInputTxt || sender == noNameInputTxt) {
				weekFile.songChar = [charNameInputTxt.text,idleNameInputTxt.text,yesNameInputTxt.text,noNameInputTxt.text];
				char.current = weekFile.songChar[0];
				char.playAnim(weekFile.songChar[1]);
			} 
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if(sender == levelStepper) {
				weekFile.level = levelStepper.value;
				loveTxt.text = 'LV ${weekFile.level}';
			} else if(sender == offsetStepperX || sender == offsetStepperY) {
				weekFile.charOffsets = [offsetStepperX.value, offsetStepperY.value];
			}
		}
	}

	var levelStepper:FlxUINumericStepper;
	var songInputTxt:FlxUIInputText;
	var nameInputTxt:FlxUIInputText;
	var overworldInputTxt:FlxUIInputText;
	var musicInputTxt:FlxUIInputText;
	var bgInputTxt:FlxUIInputText;
	var secretSongCheckbox:FlxUICheckBox;
	function addSongUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Song";

		songInputTxt = new FlxUIInputText(10, 10, 100, '', 8);
		overworldInputTxt = new FlxUIInputText(songInputTxt.x + 110, 10, 100, '', 8);

		nameInputTxt = new FlxUIInputText(10, songInputTxt.y + 30, 100, '', 8);
		levelStepper = new FlxUINumericStepper(nameInputTxt.x + 110, songInputTxt.y + 30, 1, 1, -3.75, 999999, 2);

		musicInputTxt = new FlxUIInputText(10, levelStepper.y + 70, 100, '', 8);
		bgInputTxt = new FlxUIInputText(musicInputTxt.x + 110, musicInputTxt.y, 100, '', 8);

		secretSongCheckbox = new FlxUICheckBox(10, musicInputTxt.y + 30, null, null, "Hide Song Until Beaten?", 100);
		secretSongCheckbox.callback = function() {weekFile.secretSong = secretSongCheckbox.checked;};
		
		tab_group.add(new FlxText(10, songInputTxt.y - 18, 0, 'Song Name:'));
		tab_group.add(new FlxText(overworldInputTxt.x, overworldInputTxt.y - 18, 0, 'Overworld Point:'));
		tab_group.add(new FlxText(10, levelStepper.y - 18, 0, 'Player Name / Level:'));
		tab_group.add(new FlxText(musicInputTxt.x, musicInputTxt.y - 18, 0, 'BG Music:'));
		tab_group.add(new FlxText(bgInputTxt.x, bgInputTxt.y - 18, 0, 'BG Variant:'));
		tab_group.add(levelStepper);
		tab_group.add(songInputTxt);
		tab_group.add(overworldInputTxt);
		tab_group.add(nameInputTxt);
		tab_group.add(musicInputTxt);
		tab_group.add(bgInputTxt);
		tab_group.add(secretSongCheckbox);
		UI_box.addGroup(tab_group);
	}

	var charNameInputTxt:FlxUIInputText;
	var idleNameInputTxt:FlxUIInputText;
	var yesNameInputTxt:FlxUIInputText;
	var noNameInputTxt:FlxUIInputText;
	var offsetStepperX:FlxUINumericStepper;
	var offsetStepperY:FlxUINumericStepper;
	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

		charNameInputTxt = new FlxUIInputText(10, 10, 100, '', 8);
		idleNameInputTxt = new FlxUIInputText(charNameInputTxt.x + 100, charNameInputTxt.y, 100, '', 8);

		yesNameInputTxt = new FlxUIInputText(10, charNameInputTxt.y + 70, 100, '', 8);
		noNameInputTxt = new FlxUIInputText(yesNameInputTxt.x + 110, yesNameInputTxt.y, 100, '', 8);

		offsetStepperX = new FlxUINumericStepper(10, yesNameInputTxt.y + 30, 1, 1, -960, 960, 1);
		offsetStepperY = new FlxUINumericStepper(offsetStepperX.x + 80, offsetStepperX.y, 1, 1, -720, 720, 1);
		
		tab_group.add(new FlxText(10, charNameInputTxt.y - 18, 0, 'Character:'));
		tab_group.add(new FlxText(idleNameInputTxt.x, idleNameInputTxt.y - 18, 0, 'Idle Anim:'));
		tab_group.add(new FlxText(10, yesNameInputTxt.y - 18, 0, 'Yes/No Anims:'));
		tab_group.add(new FlxText(10, offsetStepperX.y - 18, 0, 'X/Y Offset:'));
		tab_group.add(charNameInputTxt);
		tab_group.add(idleNameInputTxt);
		tab_group.add(yesNameInputTxt);
		tab_group.add(noNameInputTxt);
		tab_group.add(offsetStepperX);
		tab_group.add(offsetStepperY);
		UI_box.addGroup(tab_group);
	}
	
	function reloadAllShit() {
		levelStepper.value = weekFile.level;
		songInputTxt.text = weekFile.song;
		nameInputTxt.text = weekFile.playerName;
		overworldInputTxt.text = weekFile.overworld;
		musicInputTxt.text = weekFile.bgMusic;
		bgInputTxt.text = weekFile.bgVariant;
		secretSongCheckbox.checked = weekFile.secretSong;

		charNameInputTxt.text = weekFile.songChar[0];
		idleNameInputTxt.text = weekFile.songChar[1];
		yesNameInputTxt.text = weekFile.songChar[2];
		noNameInputTxt.text = weekFile.songChar[3];
		offsetStepperX.value = weekFile.charOffsets[0];
		offsetStepperY.value = weekFile.charOffsets[1];
	}

	override function update(elapsed:Float) {
		if(loadedWeek != null) {
			super.update(elapsed);
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new WeekEditorState(loadedWeek));
			loadedWeek = null;
			return;
		}
		
		if(charNameInputTxt.hasFocus || idleNameInputTxt.hasFocus || yesNameInputTxt.hasFocus || noNameInputTxt.hasFocus || songInputTxt.hasFocus || nameInputTxt.hasFocus || overworldInputTxt.hasFocus || musicInputTxt.hasFocus || bgInputTxt.hasFocus) {
			ClientPrefs.toggleVolumeKeys(false);
			if(FlxG.keys.justPressed.ENTER) {
				charNameInputTxt.hasFocus = idleNameInputTxt.hasFocus = yesNameInputTxt.hasFocus = noNameInputTxt.hasFocus = songInputTxt.hasFocus = nameInputTxt.hasFocus = overworldInputTxt.hasFocus = musicInputTxt.hasFocus = bgInputTxt.hasFocus = false;
			}
		} else {
			ClientPrefs.toggleVolumeKeys(true);
			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('PoopshittersMainMenu'));
			}
		}
		super.update(elapsed);
	}
	
	private static var _file:FileReference;
	public static function loadWeek() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}
	
	public static var loadedWeek:SongFile = null;
	public static var loadError:Bool = false;
	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
				loadedWeek = cast Json.parse(rawJson);
				if(loadedWeek.song != null && loadedWeek.level != null) //Make sure it's really a week
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					loadError = false;

					_file = null;
					return;
				}
			}
		}
		loadError = true;
		loadedWeek = null;
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
		private static function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	private static function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	public static function saveWeek(weekFile:SongFile) {
		var data:String = haxe.Json.stringify(weekFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "Data.json");
		}
	}
	
	private static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
		private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}
