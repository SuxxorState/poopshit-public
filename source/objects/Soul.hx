package objects;

private var soulColors:Map<String, Array<String>> = [//normal color, damage flash color
    'determination' => ['FF0000', '800000'],
    'bravery' => ['FCA600', 'EC6F00'],
    'justice' => ['FFFF00', 'F4D400'],
    'kindness' => ['00C000', '008000'],
    'patience' => ['42FCFF', '00A6C5'],
    'integrity' => ['003CFF', '001D7F'],
    'perseverance' => ['D535D9', '8F1C93']
];

private var soulHitbox:Map<String, Array<Int>> = [
    'normal' => [16,16],
    'flee' => [16,24],
    'small' => [9,9],
    'break' => [20,16],
    'normal-flip' => [16,16],
    'flee-flip' => [16,24],
    'small-flip' => [9,9],
    'break-flip' => [20,16]
];

class Soul extends FlxSpriteGroup {
    public var small:Bool = true;
    var soul:FlxSprite;
    public var actual:FlxSprite;
    public var soulColor/*(default, set)*/:String = '';
    public var curAnim:String = '';
    public var sprTracker:FlxSprite;
    var anims:Array<Dynamic> = [['normal',[0]], ['flee',[1,2]], ['small',[3]], ['break',[4]], ['normal-flip',[8]], ['flee-flip',[9,10]], ['small-flip',[11]], ['break-flip',[12]]];

    public function new(x:Float, y:Float, ?color:String = null, ?mini:Bool = false) {
        small = mini;
        if (color == null || color == '') color = ClientPrefs.data.soulTrait;
        soulColor = color.toLowerCase().trim();
        super(x,y);
        
        soul = new FlxSprite().loadGraphic(Paths.image('soul', 'overworld'), true, 21, 25);
        for (i in anims) soul.animation.add(i[0], i[1], 6);
        soul.animation.play((small ? 'small' : 'normal')+(ClientPrefs.data.soulX ? '-flip' : ''));
        soul.color = CoolUtil.colorFromString(soulColors.get(soulColor)[0]);
        soul.antialiasing = false;
        curAnim = (small ? 'small' : 'normal')+(ClientPrefs.data.soulX ? '-flip' : '');
        add(soul);

        actual = new FlxSprite(0,1).makeGraphic(soulHitbox.get(soul.animation.curAnim.name)[0], soulHitbox.get(soul.animation.curAnim.name)[1], FlxColor.TRANSPARENT);
        actual.visible = false;
        actual.alpha = 0;
        add(actual);
    }

    var die:Bool = false;
    var maxPos:Float = 1;
    var posAmt:Float = 0.5;
    var trackedPos:Array<Float> = [0,0];
    override public function update(elapsed:Float) {
        soul.update(elapsed); //what
        if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 7);
            //y += ((sprTracker.height / 2) - actual.height);
		}

        if (die) {
            var moveAmtX:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
            var moveAmtY:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
            if (FlxG.random.bool(50)) {
                soul.x = x;
                if (trackedPos[0] == maxPos && moveAmtX == posAmt)
                    moveAmtX = -posAmt;
                if (moveAmtX == -posAmt && trackedPos[0] == -maxPos)
                    moveAmtX = posAmt;
                trackedPos[0] += moveAmtX;
                soul.x += moveAmtX;
            }
            if (FlxG.random.bool(50)) {
                soul.y = y;
                if (trackedPos[1] == maxPos && moveAmtY == posAmt)
                    moveAmtY = -posAmt;
                if (trackedPos[1] == -maxPos && moveAmtY == -posAmt)
                    moveAmtY = posAmt;
                trackedPos[1] += moveAmtY;
                soul.y += moveAmtY;
            }
        }
        if (shards.length >= 1) {
            for (i in 0...shards.length) {
                shards[i].update(elapsed);
                shards[i].x += shardShit[i][0];
                shards[i].y += shardShit[i][1];
                shardShit[i][1] += (0.05 + Math.abs(shardShit[i][1] * elapsed * 0.5));
            }
        }
        super.update(elapsed);
    }

    public function playAnim(anim:String) {
        soul.flipX = false;
        if (ClientPrefs.data.soulX && !anim.endsWith('-flip')) anim += '-flip';

        if (anim.startsWith('shatter')) {
            remove(soul);
            soul.active = soul.visible = false;
            FlxG.sound.play(Paths.sound('soul_shatter', 'overworld'));
            summonShards();
        } else {
            soul.animation.play(anim, true);
            if (anim.startsWith('break')) soul.offset.x = 2;
            else soul.offset.x = 0;
            actual.setGraphicSize(soulHitbox.get(anim)[0], soulHitbox.get(anim)[1]);
            actual.updateHitbox();
            actual.setPosition(0,1);
        }
        curAnim = anim;
        if (anim.startsWith('break')) FlxG.sound.play(Paths.sound('soul_split', 'overworld'));
        else if (anim.startsWith('flee')) {
            soul.flipX = true;
            FlxG.sound.play(Paths.sound('flee', 'overworld'));
        }
    }

    /*function set_soulColor(color:String) {
        soul.color = CoolUtil.colorFromString(soulColors.get(color)[0]);
        if (color == 'green' && soulColor != 'green') FlxG.sound.play(Paths.sound('soul_green_start', 'overworld'));
        return(color);
    }*/

    var posTwn:FlxTween;
    var amtTwn:FlxTween;
    var dieTmr:FlxTimer;
    public function menuShatter(?onComplete:Void->Void) {
        die = true;

        FlxG.sound.play(Paths.sound('what'));
        posTwn = FlxTween.tween(this, {maxPos: 10}, 2, {ease: FlxEase.linear});
        amtTwn = FlxTween.tween(this, {posAmt: 4}, 2, {ease: FlxEase.linear});
        dieTmr = new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            playAnim('shatter');
            dieTmr = new FlxTimer().start(1, function(tmr:FlxTimer) {
                if (onComplete != null) onComplete();
                this.destroy();
            });
        });
    }

    var shards:Array<FlxSprite> = [];
    var shardShit:Array<Array<Float>> = [];
    public function summonShards() {
        var shit:Int = 1;
        for (i in 0...FlxG.random.int(4,7)) {
            var shard = new FlxSprite().loadGraphic(Paths.image('soul', 'overworld'), true, 21, 25);
            shard.color = CoolUtil.colorFromString(soulColors.get(soulColor)[0]);
            shard.animation.add('idle', [5,6,7,6], 6);
            shard.animation.play('idle', true, false, FlxG.random.int(0,3));
            shard.antialiasing = false;
            shardShit.push([FlxG.random.float(-4, 4) * shit, FlxG.random.float(-8, 5)]);
            shit *= -1;
            add(shard);
            shards.push(shard);
        }
    }

    @:deprecated("this shit broken dawg, use scale.set instead")
    override public function setGraphicSize(w:Int = 0, h:Int = 0) super.setGraphicSize(w,h);

    override public function destroy() {
        if (posTwn != null) posTwn.cancel();
        if (amtTwn != null) amtTwn.cancel();
        if (dieTmr != null) dieTmr.cancel();

        super.destroy();
    }
}