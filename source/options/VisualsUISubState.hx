package options;

import objects.Character;

class VisualsUISubState extends BaseOptionsMenu {
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new() {
		title = 'GVUI Settings';
		rpcTitle = 'Graphics, Visuals, & UI Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(580, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'Toggles some minor details, improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'Decreases performance, but has sharper visuals.',
			'antialiasing',
			'bool');
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders', //Name
			"Toby fox if he knew how to use shaders", //Description
			'shaders',
			'bool');
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"GPU can be used for caching, bad for weak pcs.", //Description
			'cacheOnGPU',
			'bool');
		addOption(option);

		/*#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"farts per stinky",
			'framerate',
			'int');
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end*/

		/*var option:Option = new Option('Splash Opacity',
			'How transparent should the Splashes be.',
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);*/

		var option:Option = new Option('Hide HUD',
			'highly unobtainable dogs',
			'hideHud',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Timer Type',
			"What the Timer displays",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Subtitles',
			"what most avid anime fans use",
			'subtitles',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"The camera won't zoom in on a beat hit.",
			'camZooms',
			'bool');
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	/*function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}*/

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		//boyfriend.visible = (antialiasingOption == curSelected);
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
