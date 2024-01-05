package objects;

class TrophyItem extends FlxSpriteGroup {
    public var trophyStats:Array<String>;
    var unlocked:Bool = false;
    var bgbck:FlxSprite;
    var bgfnt:FlxSprite;
    var toby:FlxSprite;
    var title:FlxText;
    var desc:FlxText;
    var percent:FlxText;

    var tobyAnims:Array<String> = ['bronze','silver','gold','platinum','unknown'];
    public var startPos:FlxPoint = new FlxPoint(0, 0);
    public var num:Int = 0;

    override public function new(stats:Array<String>, x:Float, y:Float, i:Int) {
        super(x,y);
		startPos.set(x,y);
        num = i;
        antialiasing = false;
        scrollFactor.set();
        unlocked = Trophies.getTrophyStats(stats[3], UNLOCKED);

        bgbck = new FlxSprite().makeGraphic(900,200, FlxColor.WHITE);
        bgfnt = new FlxSprite(5,5).makeGraphic(Std.int(bgbck.width - 10), Std.int(bgbck.height - 10), FlxColor.BLACK);
        add(bgbck);
        add(bgfnt);

        toby = new FlxSprite(32,25).loadGraphic(Paths.image('trophies'), true, 24,24);
        toby.antialiasing = false;
        for (i in 0...tobyAnims.length) {
            toby.animation.add(tobyAnims[i] + '-idle', [(i * 5)]);
            toby.animation.add(tobyAnims[i] + '-walk', [(i * 5)+1, (i * 5)+2], 2);
            toby.animation.add(tobyAnims[i] + '-bark', [(i * 5)+3, (i * 5)+4], 2);
        }
        toby.setGraphicSize(150);
        toby.updateHitbox();
        add(toby);

        title = new FlxText(toby.x + toby.width - 4, 22, 690, (!Trophies.getTrophyStats(stats[3], UNLOCKED) && Trophies.hidden[Trophies.getTrophyStats(stats[3], INDEX)]) ? 'Hidden Trophy' : stats[0]);
        title.setFormat(Paths.font("monster-friend-back-pro.ttf"), title.text.length > 21 ? 24 : 30, FlxColor.WHITE);
        title.antialiasing = false;
        add(title);
        
        desc = new FlxText(toby.x + toby.width - 4, 10 + title.height + 20, 720, stats[1]);
        desc.setFormat(Paths.font("8bitoperator_jve.ttf"), 36, FlxColor.WHITE);
        desc.antialiasing = false;
        add(desc);

        trophyStats = stats;
        unlocked = Trophies.getTrophyStats(stats[3], UNLOCKED);
        reloadTrophy(stats);
        changeSelected(num == 0);
    }

    function reloadTrophy(stats:Array<String>) {
        toby.animation.play((unlocked ? stats[2] : 'unknown') + '-idle');
        title.text = (!Trophies.getTrophyStats(stats[3], UNLOCKED) && Trophies.hidden[Trophies.getTrophyStats(stats[3], INDEX)]) ? 'Hidden Trophy' : stats[0];
        desc.text =  unlocked ? stats[1] : 'This trophy is locked.';
    }

	override function update(elapsed:Float) {
        var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
        y = FlxMath.lerp(y, (num * 1.3 * 225) + startPos.y, lerpVal);
        super.update(elapsed);
    }

    public function changeSelected(curSelected:Bool = false) {
        if (trophyStats != null) {
            if (curSelected) {
                bgbck.color = FlxColor.YELLOW;
                toby.animation.play('${unlocked ? trophyStats[2] : 'unknown'}-walk', false, false, toby.animation.curAnim.curFrame);
            } else {
                bgbck.color = FlxColor.WHITE;
                toby.animation.play('${unlocked ? trophyStats[2] : 'unknown'}-idle', false, false, toby.animation.curAnim.curFrame);
            }
        }
    }

    public var soundPlaying = false;
    public function playTrophyAudio() {
        if (!soundPlaying) {
            soundPlaying = true;
            toby.animation.play('${unlocked ? trophyStats[2] : 'unknown'}-bark', false, false, toby.animation.curAnim.curFrame);
            FlxG.sound.play(Paths.sound('trophies/' + (unlocked ? trophyStats[3] : 'locked${FlxG.random.int(1,3)}')), 0.7, function(){
                changeSelected(num == 0);
                soundPlaying = false;
            });
        }
    }
    
	public function snapToPosition() y = (num * 1.3 * 225) + startPos.y;
    
}