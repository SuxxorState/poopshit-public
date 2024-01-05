package objects;

class PauseButton extends FlxSprite {
    public var itemNum:Int = 0;
    public var selected:Bool = false;

	public function new(x:Float, y:Float, num:Int = 0, curSelected:Int = 0) {
        super(x, y);
        itemNum = num;
        loadGraphic(Paths.image('pause/' + (PlayState.SONG.song == 'Too Far' ? 'EVIL ' : '') + 'Pause Buttons', 'shared'), true, 123, 42);
        setGraphicSize(Std.int((width * 1.1) * 1.5));
        animation.add("idle", [num * 2], 24, false);
        animation.add("selected", [(num * 2) + 1], 24, false);
        updateHitbox();
        playAnim(curSelected);
        antialiasing = false;
    }

    public function playAnim(selectedItem:Int = 0) {
        if (itemNum == selectedItem)
            animation.play('selected');
        else
            animation.play('idle');
        selected = (itemNum == selectedItem);
    }
}
