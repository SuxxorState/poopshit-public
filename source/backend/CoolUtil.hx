package backend;

import flixel.util.FlxSave;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import flixel.input.keyboard.FlxKey;

#if sys
import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
#end

class CoolUtil {
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.PLUS];

	public static var initialized:Bool = false;
	inline public static function initialize() {
		if (initialized) return;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();


		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];


		FlxG.save.bind('poopshitters-demo', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();

		Highscore.load();

		if(FlxG.save.data != null && FlxG.save.data.fullscreen) 
			FlxG.fullscreen = FlxG.save.data.fullscreen;

		if (ClientPrefs.data.funVal != ClientPrefs.data.fps || ClientPrefs.data.funVal > 99 || ClientPrefs.data.fps > 99) {
			switch (ClientPrefs.data.funVal) {
				case 0: ClientPrefs.data.ibdMode = 'down-to-the-bone';
				case 66: ClientPrefs.data.ibdMode = 'eggster';
				default: ClientPrefs.data.ibdMode = 'casual';
			}
			ClientPrefs.saveSettings();
		} 

		FlxG.mouse.visible = false;
		initialized = true; 
	}

	public static var plrlevel:Float = 1;
    public static var plrhealth:Int = 20;
	public static var plrmaxhealth:Int = 20;

	inline public static function reloadHP(?lv:Null<Float> = null, ?resethp:Bool = false) {
		if (lv != null) plrlevel = lv;
		plrmaxhealth = Math.ceil(FlxMath.bound(20 + ((plrlevel - 1) * 4), 1, 999) / (ClientPrefs.data.laxMode ? 2 : 1));
		if (resethp) plrhealth = plrmaxhealth;
		else plrhealth = (plrmaxhealth < plrhealth) ? plrmaxhealth : plrhealth; 
	}

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	inline public static function formatDigits(cur:Int, max:Int = -1):String {
		var curHP:String = '$cur';
		var maxHP:String = '$max';

		if (cur < 0 && cur > -10) curHP = '-0${Math.abs(cur)}';
		else if (cur < 10 && cur > -1) curHP = '0$cur';
		if (max < 0 && max > -10) maxHP = '-0${Math.abs(max)}';
		else if (max < 10 && max > -1) maxHP = '0$max';

		if (max > -1) return '$curHP / $maxHP';
		else return '$curHP';
	}


	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	
	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function checkFUNRange(min:Int, max:Int):Bool
		return (ClientPrefs.data.funVal >= min && ClientPrefs.data.funVal <= max);

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0) {
					if(countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key in countByColor.keys()) {
			if(countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	inline public static function getSavePath(folder:String = 'SuxxorState'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	inline public static function isRecording():Bool {//ripped from indie cross... whoops
		#if sys
		var programList:Array<String> = ['obs32','obs64','streamlabs obs','bdcam','fraps','xsplit','hycam2','twitchstudio'];

		var taskList:Process = new Process('tasklist', []);
		var readableList:String = taskList.stdout.readAll().toString().toLowerCase();
		var isOBS:Bool = false;

		for (i in 0...programList.length) if (readableList.contains(programList[i])) isOBS = true;

		taskList.close();
		readableList = '';
		#else
		var isOBS:Bool = false;
		#end

		return isOBS;
	}
}
