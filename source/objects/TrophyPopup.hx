package objects;

class TrophyPopup extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null) {
		setPosition(30,25);
		super(x, y);
		ClientPrefs.saveSettings();

		var trophyShit:Array<Dynamic> = Trophies.trophyStuff[Trophies.getTrophyStats(name, INDEX)];
		var fucks:Array<String> = ['bronze', 'silver', 'gold', 'platinum'];

		var bg:FlxSprite = new FlxSprite(-3,-3).makeGraphic(426, 126, FlxColor.WHITE);
		bg.antialiasing = false;
		bg.scrollFactor.set();
		bg.stamp(new FlxSprite().makeGraphic(420, 120, FlxColor.BLACK), 3, 3);
		add(bg);

		var toby:FlxSprite = new FlxSprite(10, 10).loadGraphic(Paths.image('trophies'), true, 24, 24);
		toby.antialiasing = false;
		toby.animation.add(trophyShit[2], [fucks.indexOf(trophyShit[2]) * 5]);
		toby.animation.play(trophyShit[2]);
		toby.setGraphicSize(100);
		toby.updateHitbox();

		var title:FlxText = new FlxText(toby.x + toby.width + 20, toby.y + 4, 280, trophyShit[0]);
		title.antialiasing = false;
		title.setFormat(Paths.font("monster-friend-back-pro.ttf"), trophyShit[0].length <= 16 ? 16 : 12, FlxColor.YELLOW, LEFT);

		var desc:FlxText = new FlxText(title.x, title.y + title.height + 8, 280, trophyShit[1]);
		desc.antialiasing = false;
		desc.setFormat(Paths.font("8bitoperator_jve.ttf"), 20, FlxColor.WHITE, LEFT);

		bg.stamp(title, Std.int(title.x + 3), Std.int(title.y + 3));
		bg.stamp(desc, Std.int(desc.x + 3), Std.int(desc.y + 3));
		bg.stamp(toby, 58, 53);

		var cam:Array<FlxCamera> = FlxG.cameras.list;
		if(camera != null) cam = [camera];
		y = -10 - height;
		alpha = 0;
		bg.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1, y: 25}, 0.5, {ease: FlxEase.smootherStepOut, onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0, y: -10 - height}, 0.5, {
				ease: FlxEase.smootherStepIn, startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) alphaTween.cancel();
		super.destroy();
	}
}