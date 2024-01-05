package objects;

import flixel.math.FlxPoint;

class MenuText extends FlxText { //flxtext that behaves like alphabet... to. yknow. replace it.
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

    public var sprTracker:FlxSprite;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(x:Float, y:Float, fw:Int, text:String = "", size:Int) {
		super(x, y, fw, text, size);
        super.setFormat(Paths.font("DTM-Mono.ttf"), size, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		super.borderSize = 2;
		super.antialiasing = false;

		startPosition.set(x,y);
		this.text = text;
	}

    override function update(elapsed:Float) {
        var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
        if(changeX)
            x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
        if(changeY)
            y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 30, sprTracker.y + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
			visible = sprTracker.visible;
		}
        super.update(elapsed);
    }

    public function snapToPosition() {
        if(changeX)
            x = (targetY * distancePerItem.x) + startPosition.x;
        if(changeY)
            y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
    }
}