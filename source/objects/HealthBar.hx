package objects;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class HealthBar extends FlxSpriteGroup
{
	public var leftBar:FlxSprite;
	public var karmaBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bg:FlxSprite;
	public var valueFunctionOne:Void->Float = function() return 0;
	public var valueFunctionTwo:Void->Float = function() return 0;
	public var percent(default, set):Float = 0;
	public var krpercent(default, set):Float = 0;
	public var bounds:Dynamic = {min: 0, max: 1};
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	// you might need to change this if you want to use a custom bar
	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = new FlxPoint(4, 4);

	public function new(x:Float, y:Float, image:String = 'healthBar', valueFunctionOne:Void->Float = null,  valueFunctionTwo:Void->Float = null, boundX:Float = 0, boundY:Float = 1, karmaActive:Bool = false)
	{
		super(x, y);
		offset.x = x; //i dont even know

		if(valueFunctionOne != null) this.valueFunctionOne = valueFunctionOne;
		if(valueFunctionTwo != null) this.valueFunctionTwo = valueFunctionTwo;
		setBounds(boundX, boundY);
		
		barWidth = Std.int((boundY * 1.2) * 1.5);
		barHeight = 22;
		bg = new FlxSprite(x - 4, y - 4).makeGraphic(barWidth + 8, barHeight + 8, FlxColor.BLACK);
		bg.antialiasing = false;

		karmaBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height), FlxColor.MAGENTA);
		if (!karmaActive) karmaBar.color = FlxColor.YELLOW;
		karmaBar.antialiasing = antialiasing = false;

		leftBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height), FlxColor.YELLOW);
		leftBar.antialiasing = antialiasing = false;

		rightBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height), FlxColor.RED);
		rightBar.antialiasing = false;

		add(bg);
		add(karmaBar);
		add(rightBar);
		add(leftBar);
		regenerateClips();
	}

	override function update(elapsed:Float) {
		var valuea:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunctionOne(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
		percent = (valuea != null ? valuea : 0);

		var valueb:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunctionTwo(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
		krpercent = (valueb != null ? valueb : 0);
		super.update(elapsed);
	}
	
	public function setBounds(min:Float, max:Float)
	{
		bounds.min = min;
		bounds.max = max;
	}

	public function setColors(left:FlxColor, right:FlxColor)
	{
		//leftBar.color = left;
		//rightBar.color = right;
	}

	public function updateBar()
	{
		if(karmaBar == null || leftBar == null || rightBar == null) return;

		karmaBar.setPosition(bg.x, bg.y);
		leftBar.setPosition(bg.x, bg.y);
		rightBar.setPosition(bg.x, bg.y);

		
		var leftSize:Float = 0;
		if(leftToRight) leftSize = FlxMath.lerp(0, barWidth, percent / 100);
		else leftSize = FlxMath.lerp(0, barWidth, 1 - percent / 100);

		var karmaSize:Float = 0;
		if(leftToRight) karmaSize = FlxMath.lerp(0, barWidth, krpercent / 100);
		else karmaSize = FlxMath.lerp(0, barWidth, 1 - krpercent / 100);

		karmaBar.clipRect.width = karmaSize;
		karmaBar.clipRect.height = barHeight;
		karmaBar.clipRect.x = barOffset.x;
		karmaBar.clipRect.y = barOffset.y;

		leftBar.clipRect.width = leftSize;
		leftBar.clipRect.height = barHeight;
		leftBar.clipRect.x = barOffset.x;
		leftBar.clipRect.y = barOffset.y;

		rightBar.clipRect.width = barWidth - karmaSize;
		rightBar.clipRect.height = barHeight;
		rightBar.clipRect.x = barOffset.x + karmaSize;
		rightBar.clipRect.y = barOffset.y;

		barCenter = karmaBar.x + karmaSize + barOffset.x;

		karmaBar.clipRect = karmaBar.clipRect;
		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips()
	{
		if(karmaBar != null)
		{
			karmaBar.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
			karmaBar.updateHitbox();
			karmaBar.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));
		}
		if(leftBar != null)
		{
			leftBar.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
			leftBar.updateHitbox();
			leftBar.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));
		}
		if(rightBar != null)
		{
			rightBar.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
			rightBar.updateHitbox();
			rightBar.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));
		}
		updateBar();
	}

	private function set_krpercent(value:Float)
	{
		var doUpdate:Bool = false;
		if(value != percent) doUpdate = true;
		krpercent = value;

		if(doUpdate) updateBar();
		return value;
	}
		
	private function set_percent(value:Float)
	{
		var doUpdate:Bool = false;
		if(value != percent) doUpdate = true;
		percent = value;

		if(doUpdate) updateBar();
		return value;
	}

	private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

	private function set_barWidth(value:Int)
	{
		barWidth = value;
		regenerateClips();
		return value;
	}

	private function set_barHeight(value:Int)
	{
		barHeight = value;
		regenerateClips();
		return value;
	}
}