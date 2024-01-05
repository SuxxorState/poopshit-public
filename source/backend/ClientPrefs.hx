package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

// Add a variable here and it will get automatically saved
class SaveVariables {
	//poopshitter prefs
	public var permaUnlocks:Map<String, Bool> = [
		'eggster' => false, 
		'too-far' => false,
		'down-to-the-bone' => false,
	];
	public var funVal:Int = 0;
	public var fps:Int = 0; //this is a fake variable that is also the FUN value. for checking if it was edited or not.
	public var ibdMode:String = ''; //the funny
	public var charName:String = '';
	public var soulTrait:String = 'Determination';
	public var southSeasons:Bool = false;
	public var soulX:Bool = false;
	public var soulY:Bool = false;
	public var soulZ:Bool = false;
	public var laxMode:Bool = false;
	public var subtitles:Bool = false;

	//psych & xor prefs
	public var dynamicCam:Bool = true;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var autoPause:Bool = false;
	public var antialiasing:Bool = true;
	public var splashAlpha:Float = 0.6;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; //From Stilic
	public var cursing:Bool = true;
	public var violence:Bool = true;
	public var camZooms:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]];

	public var ghostTapping:Bool = true;
	public var timeBarType:String = 'Time Left';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var hitsoundVolume:Float = 0;
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;
	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		// -kade
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
	public var discordRPC:Bool = true;

	public function new()
	{
		//Why does haxe needs this again?
	}
}

class ClientPrefs {
	public static var data:SaveVariables = null;
	public static var defaultData:SaveVariables = null;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_up'			=> [W, UP],
		'note_left'			=> [A, LEFT],
		'note_down'			=> [S, DOWN],
		'note_right'		=> [D, RIGHT],
		
		'overworld_left'	=> [A, LEFT],
		'overworld_down'	=> [S, DOWN],
		'overworld_up'		=> [W, UP],
		'overworld_right'	=> [D, RIGHT],
		
		'ui_up'				=> [W, UP],
		'ui_left'			=> [A, LEFT],
		'ui_down'			=> [S, DOWN],
		'ui_right'			=> [D, RIGHT],

		'dia_next'			=> [Z],
		'dia_skip'			=> [X],

		'accept'			=> [SPACE, ENTER],
		'back'				=> [BACKSPACE, ESCAPE],
		'menu'				=> [C, CONTROL],
		'pause'				=> [ENTER, ESCAPE],
		'reset'				=> [R],
		
		'volume_mute'		=> [ZERO],
		'volume_up'			=> [PLUS],
		'volume_down'		=> [MINUS],
		
		'debug_1'			=> [SEVEN],
		'debug_2'			=> [EIGHT]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up'			=> [DPAD_UP, Y],
		'note_left'			=> [DPAD_LEFT, X],
		'note_down'			=> [DPAD_DOWN, A],
		'note_right'		=> [DPAD_RIGHT, B],
		
		'overworld_left'	=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'overworld_down'	=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'overworld_up'		=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'overworld_right'	=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'ui_up'				=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left'			=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down'			=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right'			=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'dia_next'			=> [A],
		'dia_skip'			=> [B],

		'accept'			=> [A],
		'back'				=> [B],
		'menu'				=> [X],
		'pause'				=> [START],
		'reset'				=> [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
	{
		if(controller != true)
		{
			for (key in keyBinds.keys())
			{
				if(defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());
			}
		}
		if(controller != false)
		{
			for (button in gamepadBinds.keys())
			{
				if(defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
			}
		}
	}

	public static function clearInvalidKeys(key:String) {
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
	}

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings() {
		for (key in Reflect.fields(data)) {
			//trace('saved variable: $key');
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}
		FlxG.save.data.trophyMap = Trophies.trophyMap;
		FlxG.save.data.pauseTracker = Trophies.pauseTracker;
		FlxG.save.flush();

		//Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(data == null) data = new SaveVariables();
		if(defaultData == null) defaultData = new SaveVariables();

		for (key in Reflect.fields(data)) {
			if (key != 'permaUnlocks' && key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key)) {
				//trace('loaded variable: $key');
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
			}
		}
		
		if(Main.fpsVar != null) {
			Main.fpsVar.visible = data.showFPS;
		}

		#if (!html5 && !switch)
		FlxG.autoPause = ClientPrefs.data.autoPause;
		#end

		if(FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}
		
		if(FlxG.save.data.permaUnlocks != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.permaUnlocks;
			for (name => value in savedMap)
				data.permaUnlocks.set(name, value);
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if desktop
		DiscordClient.check();
		#end

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if(save != null)
		{
			if(save.data.keyboard != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls) {
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
				}
			}
			if(save.data.gamepad != null) {
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls) {
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
				}
			}
			reloadVolumeKeys();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic {
		if(!customDefaultValue) defaultValue = defaultData.gameplaySettings.get(name);
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys() {
		CoolUtil.muteKeys = keyBinds.get('volume_mute').copy();
		CoolUtil.volumeDownKeys = keyBinds.get('volume_down').copy();
		CoolUtil.volumeUpKeys = keyBinds.get('volume_up').copy();

		toggleVolumeKeys(true);
	}
	public static function toggleVolumeKeys(turnOn:Bool) {
		if(turnOn) {
			FlxG.sound.muteKeys = CoolUtil.muteKeys;
			FlxG.sound.volumeDownKeys = CoolUtil.volumeDownKeys;
			FlxG.sound.volumeUpKeys = CoolUtil.volumeUpKeys;
		} else {
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
		}
	}
}
