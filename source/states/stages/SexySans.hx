package states.stages;

class SexySans extends BaseStage
{
	var dblackShit:FlxSprite;
	var sexysansshaders:BGSprite;
	var flipaclip:BGSprite;

	override function create() {
		if (PlayState.instance != null) {
			game.midlescrol = true;
			game.firstPOV = true;
			game.canReset = false;
		}

		var bg:BGSprite = new BGSprite('Sexy', -500, -400, 1, 1);
		bg.setGraphicSize(Std.int(bg.width * 1.5));
		bg.updateHitbox();
		bg.screenCenter();	
		add(bg);
		
		sexysansshaders = new BGSprite('sexygradient', -500, -2200, 0.9, 0.9);
		add(sexysansshaders);	

		dblackShit = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		dblackShit.scrollFactor.set();
		dblackShit.cameras = [camOther];
		add(dblackShit);

		flipaclip = new BGSprite('Flipaclip', 20, 570, 0.9, 0.9);
		flipaclip.setGraphicSize(Std.int(flipaclip.width * 0.22));
		flipaclip.updateHitbox();
		add(flipaclip);	
		flipaclip.cameras = [camOther];
	}
	
	override function createPost() boyfriend.alpha = 0;

	override function update(elapsed:Float) {
		if(!ClientPrefs.data.lowQuality) {
			var mult:Float = FlxMath.lerp(0.22, flipaclip.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
			flipaclip.scale.set(mult, mult);
			flipaclip.updateHitbox();
			flipaclip.setPosition(-415 - ((276 * flipaclip.scale.x - 276) * 2), 350 - ((138 * flipaclip.scale.y - 138) * 2));
		}
	}

	
	override function countdownTick(count:Countdown, num:Int) {
		if(!ClientPrefs.data.lowQuality) {
			flipaclip.scale.set(0.25, 0.25);
			flipaclip.updateHitbox();
			flipaclip.setPosition(-415 - ((276 * flipaclip.scale.x - 276) * 2), 350 - ((138 * flipaclip.scale.y - 138) * 2));
		}
	}

	override function beatHit() {
		if(!ClientPrefs.data.lowQuality) {
			flipaclip.scale.set(0.25, 0.25);
			flipaclip.updateHitbox();
			flipaclip.setPosition(-415 - ((276 * flipaclip.scale.x - 276) * 2), 350 - ((138 * flipaclip.scale.y - 138) * 2));
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
		switch(eventName) {
			case 'BBG GF Appear':
				game.boyfriend.y += 100;
				FlxTween.tween(game.boyfriend, {alpha: 1}, flValue1 * (Conductor.crochet / 1000));
				FlxTween.tween(game.boyfriend, {y: game.boyfriend.y - 100}, flValue1 * (Conductor.crochet / 1000));

			case 'BBG BG Black':
				FlxTween.tween(sexysansshaders, {y: -200}, flValue1 * (Conductor.crochet / 1000));

			case 'FTB':	
				FlxTween.tween(dblackShit, {alpha: 1}, flValue1 * (Conductor.crochet / 1000));

			case 'FOOB':	
				FlxTween.tween(dblackShit, {alpha: 0}, flValue1 * (Conductor.crochet / 1000));
				
		}
	}
}