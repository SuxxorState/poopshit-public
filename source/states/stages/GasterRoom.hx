package states.stages;

import objects.Character;
import shaders.*;

class GasterRoom extends BaseStage {
	var legfloor:FlxSprite;
	var shaderback:FlxSprite;
	var shadercover:FlxSprite;
	var dvFilter:DigitalVoidShader;
	var asFilter:SqrShader;
	var fallthatfloor:Bool = false;
	var accelerleg:Float = 1;
	var decider:Int = 1;
	var legtween:FlxTween;
	var fadeopp:Bool = false;
	var shadertween:FlxTween;

	override function create() {
		if (PlayState.instance != null) {
			game.isSansGone = true;
			game.skipCountdown = true;
		}

		dvFilter = new DigitalVoidShader();
		asFilter = new SqrShader();
		
		shaderback = new FlxSprite(-590, -500);
		shaderback.makeGraphic(2000, 1800, FlxColor.WHITE);
		add(shaderback);
		shaderback.shader = dvFilter;
				
		shadercover = new FlxSprite(-590, -500);
		shadercover.makeGraphic(2000, 1800, FlxColor.BLACK);
		add(shadercover);

		legfloor = new BGSprite('GasterFloor', 0, 0, 1, 1);
		legfloor.setGraphicSize(Std.int(legfloor.width * 1.5));
		legfloor.updateHitbox();
		legfloor.setPosition(-600, -150);
		add(legfloor);

		decider = FlxG.random.bool() ? -1 : 1;
	}

	override function createPost() gf.visible = false;

	override function update(elapsed:Float) {
		dvFilter.update(elapsed);
		asFilter.update(elapsed);
		if (fallthatfloor) {
			legfloor.y += 140 * game.playbackRate * elapsed * accelerleg;
			legfloor.x += 10 * game.playbackRate * elapsed * accelerleg * decider;
			legfloor.angle += 1.5 * game.playbackRate * elapsed * accelerleg * decider;
			accelerleg += 0.05;
		}
		if (fadeopp && dad.alpha > 0) {
			dad.alpha -= elapsed / 2; 
			shadercover.alpha += elapsed / 2;
		}
	}

	override function closeSubState() {if (paused) {
		if(legtween != null) legtween.active = true;
		if(shadertween != null) shadertween.active = true;
	}}
	override function openSubState(SubState:flixel.FlxSubState) {if (paused) {
		if(legtween != null) legtween.active = false;
		if(shadertween != null) shadertween.active = false;
	}}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
		switch(eventName) {
			case 'Floor Fall':
				fallthatfloor = true;
				legtween = FlxTween.tween(legfloor, {alpha: 0}, 0.75 / game.playbackRate, {onComplete: function(tween:FlxTween){remove(legfloor);}, startDelay: Conductor.crochet * 0.002 / game.playbackRate});
			
			case 'Char Fade':
				fadeopp = true;
				/*var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue1 == null) flValue2 = 0;
						switch(Math.round(flValue1)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}*/

			case 'Rapping Mode':
				shadertween = FlxTween.tween(shadercover, {alpha: flValue1 == 0 ? 0 : 1}, 0.5 / game.playbackRate, {onComplete: function(tween:FlxTween){
					//if (flValue1 != 0) shaderback.shader = asFilter;
				}});

			/*case 'Greyscale Char':
				if (value1 == 'true') {
					boyfriend.shader = pauseGSFilter;
					dad.shader = pauseGSFilter;
				} else {
					boyfriend.shader = null;
					dad.shader = null;
				}*/
		}
	}
}