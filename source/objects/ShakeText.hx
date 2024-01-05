package objects;

class ShakeText extends FlxText
{
    var maxPos:Float = 1;
    var posAmt:Float = 0.5;
    var trackedPos:Array<Float> = [0,0];
    public var shakeIt:Bool = true;
    override function update(elapsed:Float)
    {
        if (antialiasing) antialiasing = false;
        if (FlxG.random.bool(80) && shakeIt)
        {
            var moveAmtX:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
            var moveAmtY:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
            if (FlxG.random.bool(50))
            {
                if (trackedPos[0] == maxPos && moveAmtX == posAmt)
                    moveAmtX = -posAmt;
                if (moveAmtX == -posAmt && trackedPos[0] == -maxPos)
                    moveAmtX = posAmt;
                trackedPos[0] += moveAmtX;
                x += moveAmtX;
            }
            if (FlxG.random.bool(50))
            {
                if (trackedPos[1] == maxPos && moveAmtY == posAmt)
                    moveAmtY = -posAmt;
                if (trackedPos[1] == -maxPos && moveAmtY == -posAmt)
                    moveAmtY = posAmt;
                trackedPos[1] += moveAmtY;
                y += moveAmtY;
            }
        }

        super.update(elapsed);
    }
}