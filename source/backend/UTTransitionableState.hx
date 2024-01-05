package backend;

import flixel.util.FlxGradient;
import objects.Soul;

class UTTransitionableState extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;
	public static var player:Player = null;
	private var leTween:FlxTween = null;
	private var leTwn2:FlxTween = null;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var blkLeft:FlxSprite;
	var blkRight:FlxSprite;
	var tme:FlxTimer = null;
	var soul:Soul;
	var zoom:Float = 1;
	var width:Int = 1;
	var height:Int = 1;
	public static var finishsoul:Soul;

	public function new(isTransOut:Bool, transType:String) {
		super();
		this.isTransIn = !isTransOut; //what
		zoom = FlxG.camera.zoom;
		width = Std.int(FlxG.width / zoom);
		height = Std.int(FlxG.height / zoom);

		switch(transType.trim().toLowerCase()) {
			case "soul": fight();
			case "settings": settings();
			default: ow();
		}
					
		nextCamera = null;
	}

	function ow() {
		transBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		add(transBlack);

		transBlack.alpha = isTransIn ? 0 : 1;
		leTween = FlxTween.tween(transBlack, {alpha: !isTransIn ? 0 : 1}, 0.35, {onComplete: function(twn:FlxTween) {finish();}, ease: FlxEase.linear});

		if(nextCamera != null) transBlack.cameras = [nextCamera];
	}

	function settings() {
		blkLeft = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2), FlxG.height, FlxColor.BLACK);
		blkLeft.updateHitbox();
		blkLeft.scrollFactor.set();
		add(blkLeft);

		blkRight = new FlxSprite(FlxG.width / 2, 0).makeGraphic(Std.int(FlxG.width / 2), FlxG.height, FlxColor.BLACK);
		blkRight.updateHitbox();
		blkRight.scrollFactor.set();
		add(blkRight);

		if(!isTransIn) {
			FlxG.sound.play(Paths.sound('settings_open'));
			leTween = FlxTween.tween(blkLeft, {x: -(FlxG.width / 2)}, 1.25, {onComplete: function(twn:FlxTween) {finish();}, ease: FlxEase.linear, startDelay: 0.1});
			leTwn2 = FlxTween.tween(blkRight, {x: FlxG.width}, 1.25, {startDelay: 0.1});
		} else {
			blkLeft.alpha = 0;
			blkRight.alpha = 0;
			finish();
		}

		if(nextCamera != null) {
			blkLeft.cameras = [nextCamera];
			blkRight.cameras = [nextCamera];
		}
	}

	var fht:FlxTimer = null;
	var sltwn:FlxTween = null;
	function fight() {
		if (player == null || finishsoul == null) finish();

		transBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		add(transBlack);
		
		if(isTransIn) {
			player.color = FlxColor.WHITE;
			add(player);

			soul = new Soul(player.x, player.y, true);
			soul.x += (player.width - soul.actual.width) / 2;
			soul.y += (player.height - soul.actual.height) / 4;
			add(soul);

			fht = new FlxTimer().start(0.12, function(tmr:FlxTimer) {
				switch(tmr.elapsedLoops) {
					case 1:
						FlxG.sound.play(Paths.sound('black_out', 'overworld'));
						soul.visible = player.visible = true;
					case 2: 
						FlxG.sound.play(Paths.sound('black_out', 'overworld'));
						soul.visible = false;
					case 3: 
						FlxG.sound.play(Paths.sound('black_out', 'overworld'));
						soul.visible = true;
					case 4:
						FlxG.sound.play(Paths.sound('battle_fall', 'overworld'));
						player.visible = false;
						sltwn = FlxTween.tween(soul, {x: finishsoul.x, y: finishsoul.y, alpha: 0}, 0.5, {onComplete: function(twn:FlxTween) {
							finish();
						}});
				}
			},4);
		} else {
			leTween = FlxTween.tween(transBlack, {alpha: 0}, 0.25, {onComplete: function(twn:FlxTween) {close();}, ease: FlxEase.linear});
			if(nextCamera != null) transBlack.cameras = [nextCamera];
		}
	}

	function finish() {
		tme = new FlxTimer().start(0.01, function(tmr:FlxTimer){
			if (finishCallback != null && isTransIn) finishCallback();
			else if (!isTransIn) close();
		});
	}

	override function destroy() {
		if (leTwn2 != null) leTwn2.cancel();
		if (fht != null) fht.cancel();
		if (sltwn != null) sltwn.cancel();
		if (leTween != null) {
			if (finishCallback != null) finishCallback();
			leTween.cancel();
		}
		if (tme != null) tme.cancel();
		super.destroy();
	}
}