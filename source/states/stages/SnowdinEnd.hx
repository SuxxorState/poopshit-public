package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxBackdrop;

class SnowdinEnd extends BaseStage {
	var backLand:BGSprite;
	var iceblock:BGSprite;
	var icepyrus:BGSprite;
	var pissboppers:FlxTypedGroup<BGSprite>;

	var whiteout:FlxBackdrop;

	var snowlimit:Int = 500;
	var snowflakes:FlxTypedGroup<Snowflake>;
	var thefuckingtree:BGSprite;

	override function create() {
		if (PlayState.instance != null) {
			game.swapstrums = true;
			game.skipCountdown = true;
		}

		pissboppers = new FlxTypedGroup<BGSprite>();

		var water:BGSprite = new BGSprite('water', 0, 0, 1, 1);
		water.setGraphicSize(Std.int(water.width * 1.5));
		water.updateHitbox();
		water.setPosition(-600, -150);
		add(water);

		backLand = new BGSprite('backland', 0, 0, 1, 1, ['backland idle'], !ClientPrefs.data.lowQuality);
		backLand.setGraphicSize(Std.int(backLand.width * 1.5));
		backLand.updateHitbox();
		backLand.setPosition(-600, -150);
		add(backLand);
		
		if(!ClientPrefs.data.lowQuality) {
			iceblock = new BGSprite('ice', 100, 300, 1, 1, ['backland idle'], true);
			iceblock.setGraphicSize(Std.int(iceblock.width * 1.25));
			iceblock.updateHitbox();
			iceblock.setPosition(-300, 300);	
			iceblock.active = true;
			iceblock.velocity.x = FlxG.random.float(50, 65);
			add(iceblock);

			icepyrus = new BGSprite('Skinpyrus', iceblock.x, iceblock.y, 1, 1, ['idlel instance 1']);
			icepyrus.setGraphicSize(Std.int(icepyrus.width * 1.2));
			icepyrus.updateHitbox();
			icepyrus.setPosition(iceblock.x, iceblock.y);	
			icepyrus.y -= icepyrus.height * 0.67;
			icepyrus.x -= 20;
			icepyrus.active = true;
			icepyrus.velocity.x = iceblock.velocity.x;
			pissboppers.add(icepyrus);
		}

		//middleground
		var land:BGSprite = new BGSprite('Land', 0, 0, 1, 1);
		land.setGraphicSize(Std.int(land.width * 1.5));
		land.updateHitbox();
		land.setPosition(-600, -150);	
		pissboppers.add(land);

		if(!ClientPrefs.data.lowQuality) {
			var sleepshitter:BGSprite = new BGSprite('sleepshitter', 0, 0, 1, 1, ['sdleeeep instance 1']);
			sleepshitter.setGraphicSize(Std.int(sleepshitter.width * 1.35));
			sleepshitter.updateHitbox();
			sleepshitter.setPosition(100, 250);	
			pissboppers.add(sleepshitter);

			var stompyrus:BGSprite = new BGSprite('stompyrus', 0, 0, 1, 1, ['stomp instance 1']);
			stompyrus.setGraphicSize(Std.int(stompyrus.width * 1.35));
			stompyrus.updateHitbox();
			stompyrus.setPosition(375, 0);	
			pissboppers.add(stompyrus);


			var thinkpyrus:BGSprite = new BGSprite('thinkpyrus', 0, 0, 1, 1, ['thinkpyrus instance 1']);
			thinkpyrus.setGraphicSize(Std.int(thinkpyrus.width * 1.25));
			thinkpyrus.updateHitbox();
			thinkpyrus.setPosition(1050, 0);	
			pissboppers.add(thinkpyrus);
		}

		add(pissboppers);
				
		whiteout = new FlxBackdrop(Paths.image('Snowdin Snow Thing'));
		add(whiteout);
	}
	
	override function createPost() {
		thefuckingtree = new BGSprite('tree', 0, 0, 1, 1);
		thefuckingtree.setGraphicSize(Std.int(thefuckingtree.width * 1.5));
		thefuckingtree.updateHitbox();
		thefuckingtree.setPosition(-600, -150);	
		thefuckingtree.alpha = 0;
		add(thefuckingtree);
		
		if(!ClientPrefs.data.lowQuality) {
			snowflakes = new FlxTypedGroup<Snowflake>();
			for (i in 0...snowlimit) {
				var snow:Snowflake;
				snow = new Snowflake();
				snow.alpha = 0;
				snowflakes.add(snow);
				insert(FlxG.random.int(members.indexOf(backLand) + 1, members.length, [members.indexOf(icepyrus)]), snow);
			}
		}

		var snowdinshading:BGSprite = new BGSprite('SnowdinGradient', 0, 0, 1, 1);
		snowdinshading.setGraphicSize(Std.int(snowdinshading.width * 2.5));
		snowdinshading.updateHitbox();
		snowdinshading.setPosition(-600, -200);	
		add(snowdinshading);

		dad.color = FlxColor.BLACK;
		boyfriend.color = FlxColor.BLACK;
	}

	override function update(elapsed:Float) {	
		if(!ClientPrefs.data.lowQuality) {
			if (whiteout.exists && whiteout != null) whiteout.x -= 1;
			if (iceblock.x >= 2400) iceblock.x = -1000;
			if (icepyrus.x >= 2400) icepyrus.x = -1000;
		}
	}
	
	override function countdownTick(count:Countdown, num:Int) pissboppers.forEach(function(spr:BGSprite){spr.dance();});
	override function beatHit() {
		pissboppers.forEach(function(spr:BGSprite){spr.dance();});
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
		switch(eventName) {
			case 'Uncoverpyrus':
				FlxTween.tween(whiteout, {alpha: 0}, flValue1 * (Conductor.crochet / 1000), {onComplete: function(twn:FlxTween) {
					remove(whiteout);
					whiteout.destroy();
				}});
				FlxTween.tween(thefuckingtree, {alpha: 1}, flValue1 * (Conductor.crochet / 1000));
				if(!ClientPrefs.data.lowQuality) for (snow in snowflakes.members) FlxTween.tween(snow, {alpha: FlxG.random.float(0.5, 1)}, flValue1 * (Conductor.crochet / 1000));
				FlxTween.color(boyfriend, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE);
				FlxTween.color(dad, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE);	
		}
	}
}