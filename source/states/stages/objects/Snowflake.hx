package states.stages.objects;

class Snowflake extends FlxSprite {
    var movex:Int = 0;
    var movey:Int = 0;
    var refresh:Null<Void->Void>;
	public function new(?shit:Null<Void->Void>) {
        super();
        refresh = shit;

        loadGraphic(Paths.image('snow'));
        setPosition(FlxG.random.int(0,2700), FlxG.random.int(-200,1700));
        setGraphicSize(Std.int(10 * FlxG.random.float(0.05, 1)));
        movex = FlxG.random.int(10,16);
        movey = FlxG.random.int(10,12);
    }

    public function recycle() {
        if (refresh != null) refresh();
        setPosition(FlxG.random.int(500,2700), -200);
        setGraphicSize(Std.int(10 * FlxG.random.float(0.05, 1)));
        movex = FlxG.random.int(5,20);
        movey = FlxG.random.int(5,16);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        y += 5 * movey * elapsed;
        x -= 7 * movex * elapsed;
        if (y > 1700 || x < -700) recycle();
    }
}