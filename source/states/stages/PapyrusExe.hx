package states.stages;

class PapyrusExe extends BaseStage {
	override function create() {
		if (PlayState.instance != null) {
			game.swapstrums = true;
			game.firstPOV = true;
			game.isSansGone = true;
			PlayState.startOnTime = 19060;
			game.health = ClientPrefs.data.laxMode ? 45 : 90;
		}

		var bg:BGSprite = new BGSprite('BattleBG', 100, 100, 1, 1);
		bg.setGraphicSize(Std.int(bg.width * 1.8));
		bg.updateHitbox();
		bg.screenCenter();	
		add(bg);
	}

	var floatUp:Bool = true;
	override function update(elapsed:Float) {
		dad.y += floatUp ? -0.75 : 0.75;

		if (dad.y >= 499) floatUp = true;
		else if (dad.y <= 471) floatUp = false;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
		switch(eventName) {
			case 'Papyrus Blaster' | 'Final P Blaster':
				var papyhead:FlxSprite = new FlxSprite(FlxG.width + 10).loadGraphic(Paths.image('Papyrus Blaster'));
				papyhead.setGraphicSize(Std.int(papyhead.width * 12));
				papyhead.updateHitbox();
				papyhead.screenCenter(Y);
				papyhead.y += 200;
				var blast:FlxSprite = new FlxSprite(-1900).loadGraphic(Paths.image('Blast'));
				blast.setGraphicSize(Std.int(blast.width * 12));
				blast.updateHitbox();
				blast.screenCenter(Y);
				blast.y += 200;
				blast.visible = false;
				add(blast);
				add(papyhead);
				FlxG.sound.play(Paths.sound('sans_battle_gasterblaster_charge'), 0.25);
				FlxTween.tween(papyhead, {x: 700}, 1, {onComplete: function(tween:FlxTween){
					blast.visible = true;
					if (eventName != 'Final P Blaster') game.health -= ClientPrefs.data.laxMode ? 5 : 10;
					game.boyfriend.playAnim('Hurt', true);
					FlxG.sound.play(Paths.sound('DBZ_-_Beam_Fire'), 0.25);
					FlxTween.tween(papyhead, {alpha: 0}, 1, {onComplete: function(tween:FlxTween){remove(papyhead);}});
					FlxTween.tween(blast, {alpha: 0}, 1, {onComplete: function(tween:FlxTween){remove(blast);}});
				}});
		}
	}
	override function eventPushed(event:objects.Note.EventNote) {
		switch(event.event) {
			case 'Papyrus Blaster' | 'Final P Blaster':
				precacheImage('Papyrus Blaster');
				precacheImage('Blast');
				precacheSound('sans_battle_gasterblaster_charge');
				precacheSound('DBZ_-_Beam_Fire'); 
		}
	}
}