package states.stages;

class LastCorridor extends BaseStage {
	var shitterTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

	override function create() {
		if (PlayState.instance != null) {
			game.swapstrums = true;
			game.songHasKR = true;
			game.skipCountdown = true;
		}

		var judgementHall:BGSprite = new BGSprite('Judgement Hall3', -600, 0, 1, 1);
		add(judgementHall);
	}
	
	override function createPost() {
		for (i in 0...4) {
			var pillarX:Array<Int> = [3400, 2400, 1200, 300];
			var pillar:BGSprite = new BGSprite('pillar', pillarX[i], -350, 1.78, 0);
			pillar.setGraphicSize(Std.int(pillar.width * 2.1));
			pillar.updateHitbox();
			add(pillar);
		}

		dad.color = FlxColor.BLACK;
		boyfriend.color = FlxColor.BLACK;
		shitter2.color = FlxColor.BLACK;
		shitter3.color = FlxColor.BLACK;
		dad.visible = false;
	}

	override function closeSubState() {
		for (tween in shitterTweens) tween.active = true;
	}

	override function openSubState(SubState:flixel.FlxSubState) {
		for (tween in shitterTweens) tween.active = false;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
		switch(eventName) {
			case "Sans": 
				dad.visible = true;
				shitterTweens.set('shitter', FlxTween.color(dad, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));
				shitterTweens.set('bf', FlxTween.color(boyfriend, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));

			case "Go Back":
				shitterTweens.set('shitter', FlxTween.color(dad, flValue1 * (Conductor.crochet / 1000), FlxColor.WHITE, FlxColor.BLACK));
				shitterTweens.set('bf', FlxTween.color(boyfriend, flValue1 * (Conductor.crochet / 1000), FlxColor.WHITE, FlxColor.BLACK));

			case "Reveal Backup":
				shitter2.visible = shitter2.active = true;
				shitter3.visible = shitter3.active = true;
				shitterTweens.set('shitter', FlxTween.color(dad, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));
				shitterTweens.set('shitter2', FlxTween.color(shitter2, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));
				shitterTweens.set('shitter3', FlxTween.color(shitter3, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));
				shitterTweens.set('bf', FlxTween.color(boyfriend, flValue1 * (Conductor.crochet / 1000), FlxColor.BLACK, FlxColor.WHITE));
		}
	}
}