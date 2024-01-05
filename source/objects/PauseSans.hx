package objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import objects.UTText;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PauseSans extends FlxSpriteGroup {
	var dialogue:Array<Array<Dynamic>> = [
		["i'm thinking about getting into the telescope business.", 4, 'shrug'], 
		['fun fact, this mod creator guy had another mod.', 0, 'idle', 1, 'wonder what happened to it...', 9, 'shrug'], 
		['if you miss notes, you take damage.', 0, 'idle'], 
		['', 5, 'idle'], 
		['well, that went well.', 9, 'idle'], 
		["fun fact, you can press one of those big buttons...", 0, 'idle', 0.5, "and they'll do something.", 4, 'idle', 1, "crazy, right?", 9, 'shrug'],
		['hey guys', 0, 'idle'],
		["do you get what i'm saying?", 9, 'shrug'],
		["isn't my brother cool?", 4, 'idle'],
		['have you seriously played this ' + Std.string(PlayState.deathCounter + 1) + ' time' + (PlayState.deathCounter > 0 ? 's' : '') + '?', 4, 'idle', 1, PlayState.deathCounter > 0 ? "wow, that's some dedication..." : "that sucks, 'cause it's better the second time.", 9, 'shrug'],
		['better hurry up kid,', 9, 'idle', 0.5, 'i took time outta my break for this.', 4, 'shrug'],
		['do you wanna have a bad ti-', 1, 'fist', 0.5, 'wait...', 5, 'idle', 0.5, 'wrong line...', 9, 'idle'],     
		['no. not today.', 6, 'fist'],
		['fun fact,', 0, 'shrug', 0.5, 'i am rapidly approaching.', 1, 'fist']           
	];
    var theInt:Int = 0;
    var shutup:Bool = false;
    var theLine:Int = 1;

    private var head:FlxSprite;
    private var torso:FlxSprite;
    private var legs:FlxSprite;
    private var speechBubble:FlxSprite;
    private var text:FlxTypeText;

    public var shouldDisappear:Bool = false;
    public var doneTalking:Bool = false;
    var talkTimer:FlxTimer;

    public var canSleep:Bool = false;
    var sleepTimer:FlxTimer;
    var sleepFrames:Array<Int> = [7, 13, 14];
    var sleepLoops:Int = 0;
    var day:Float = 0;
    public var asleep:Bool = false;
    var zedtween1:FlxTween;
    var zedtween2:FlxTween;
    var zedtween3:FlxTween; //literally only because it crashes the game if i dont null them
    var die:Bool = false;
    var lescal:Float = 7.5;

    public function new(x:Float, y:Float) {
        day = y;
        super(x, y);
        
        if (Paths.formatToSongPath(PlayState.SONG.song) == 'kidney-stone' && FlxG.random.int(1, 5) == 5) theInt = 8;
        else theInt = FlxG.random.int(0, dialogue.length - 1);

        if (theInt == 4 && (PlayState.deathCounter <= 0 || FlxG.sound.music.time < (FlxG.sound.music.length * 0.9)))
            theInt = FlxG.random.int(0, dialogue.length - 1, [4]);

        speechBubble = new FlxSprite(350, 0).loadGraphic(Paths.image('pause/bubble', 'shared'));
        speechBubble.setGraphicSize(Std.int(speechBubble.width * 2));
        speechBubble.updateHitbox();
        speechBubble.antialiasing = false;

        head = new FlxSprite(Std.int(9 * lescal), Std.int(-1.5 * lescal)).loadGraphic(Paths.image('pause/Heads', 'shared'),true,33,30);
        head.setGraphicSize(Std.int(head.width * lescal));
        head.updateHitbox();
        for (i in 0...15) head.animation.add("" + i, [i], 24, false);
        head.animation.play(dialogue[theInt][1]);
        head.antialiasing = false;

        torso = new FlxSprite(0, Std.int(23 * lescal)).loadGraphic(Paths.image('pause/Torsos', 'shared'),true,62,25);
        torso.setGraphicSize(Std.int(torso.width * lescal));
        torso.updateHitbox();
        torso.animation.add("idle",     [0], 24, false);
        torso.animation.add("handmove", [0,1,2,3,4], 15, false);
        torso.animation.add("shrug",    [5], 24, false);
        torso.animation.add("fist",     [6], 24, false);
        torso.animation.play(dialogue[theInt][2]);
        torso.antialiasing = false;

        legs = new FlxSprite(Std.int(6 * lescal) - (lescal / 2), Std.int(45 * lescal)).loadGraphic(Paths.image('pause/Pants', 'shared'));
        legs.setGraphicSize(Std.int(legs.width * lescal));
        legs.updateHitbox();
        legs.antialiasing = false;

        if (dialogue[theInt][0].length > 0) add(speechBubble);
        add(legs);
        add(torso);
        add(head);

        text = new FlxTypeText(420, 20, 390, dialogue[theInt][0], 24);
        text.antialiasing = false;
        text.setFormat(Paths.font("undertale-comic-sans-battle.ttf"), 24, FlxColor.BLACK, LEFT);
        text.sounds = [FlxG.sound.load(Paths.sound('dialogue/Sans Dialogue', 'overworld'), 0.8)];  
        if (dialogue[theInt][0].length > 0) {
            add(text);
            text.start(0.05, false, false, ClientPrefs.keyBinds.get('dia_skip'));
            talkTimer = new FlxTimer().start((0.05 * dialogue[theInt][0].length), function(tmr:FlxTimer) {
                doneTalking = true;
                if (theInt == 12) shouldDisappear = true;
            });
        } else {
            goToSleep(); 
        }
        dance();
    }

    function torsoPlayAnim(theAnim:String = 'idle') {
        var leAnim:String = theAnim.toLowerCase();
        var wait:Bool = false;
        if (die) return;
        if ((leAnim == 'shrug' || leAnim == 'fist') && torso.animation.curAnim.name == 'idle') {
            torso.animation.play('handmove');
            wait = true;
        } else if ((torso.animation.curAnim.name == 'shrug' || torso.animation.curAnim.name == 'fist') && leAnim == 'idle') {
            torso.animation.play('handmove', false, true);
            wait = true;
        }
        new FlxTimer().start(wait ? 0.33 : 0, function(tmr:FlxTimer) {
            if (!die) torso.animation.play(leAnim);
        });
    }

    function headPlayAnim(theAnim:String) {
        if (!die) head.animation.play(theAnim);
    }

    public function nextLine() {
        if (doneTalking && !shutup) {
            theLine++;

            talkTimer = null;
            if (theInt == 11 && theLine == 4) 
                rerollDialogue();
            else if ((dialogue[theInt].length > 3 && theLine == 2) || (dialogue[theInt].length > 7 && theLine == 3))
                rerollDialogue(theInt, theLine == 2, theLine == 3);
            else
                finishDialogue();
        }
    }

    function finishDialogue() {
        shutup = true;
        canSleep = true;
        text.visible = false;
        speechBubble.visible = false;
        headPlayAnim('0');
        torsoPlayAnim('idle');

        sleepTimer = new FlxTimer().start(5, function(tmr:FlxTimer) {
            if (sleepLoops < 3) {
                headPlayAnim('' + sleepFrames[sleepLoops]);
                sleepLoops++;
            } else 
                goToSleep();
        }, 4);
    }

    public function cancelSleep() {
        sleepTimer.cancel();
        sleepTimer = null;
        sleepLoops = 0;
        headPlayAnim('0');
        finishDialogue();
    }

    function goToSleep() {
        shutup = true;
        text.visible = false;
        speechBubble.visible = false;
        asleep = true;
        headPlayAnim('5');
        torsoPlayAnim('idle');
        
        //summonZed();
    }

    /*function summonZed() {
        var zedLoop:Int = 0;
        new FlxTimer().start(zedLoop == 0 ? 2 : 0, function(tmr:FlxTimer) {
            if (!asleep) return;
        new FlxTimer().start(0.5, function(tmr:FlxTimer) {
            if (!asleep) return;
            var zed:FlxSprite = new FlxSprite(head.width, Std.int(4 * lescal) - (lescal / 2)).loadGraphic(Paths.image('pause/Z', 'shared'));
            zed.setGraphicSize(Std.int(zed.width * 1.5));
            zed.updateHitbox();
            zed.antialiasing = false;
            zed.alpha = 0;
            if (asleep) insert(1, zed);
            zedtween1 = FlxTween.tween(zed, {y: zed.y - 180}, 1.5, {ease: FlxEase.sineIn});
            zedtween2 = FlxTween.tween(zed, {x: zed.x + 135}, 1.5, {ease: FlxEase.sineOut});
            zedtween3 = FlxTween.tween(zed, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut,onComplete: function(twn:FlxTween) {
                zedtween3 = FlxTween.tween(zed, {alpha: 0}, 1, {ease: FlxEase.cubeInOut,onComplete: function(twn:FlxTween) {
                    if (asleep) remove(zed);
                    zedLoop++;
                    if (zedLoop > 2 && asleep) summonZed();
                }});
            }});
        }, 3);
        });
    }*/

    public function rerollDialogue(num:Int = -1, isSecondary:Bool = false, isTert:Bool = false) {
        if (!shutup) {
            if (Paths.formatToSongPath(PlayState.SONG.song) == 'kidney-stone' && !isSecondary && FlxG.random.int(1, 5) == 5) num = 8;
            else if (num == -1) {
                theInt = FlxG.random.int(0, dialogue.length - 1, [3]);
                theLine = 1;
            }

            var cooladd:Int = 4 * (theLine - 1);

            headPlayAnim(dialogue[theInt][1 + cooladd]);
            torsoPlayAnim(dialogue[theInt][2 + cooladd]);

            text.resetText(dialogue[theInt][0 + cooladd]);
            text.start(0.05, false, false, [FlxKey.X]);

            talkTimer = new FlxTimer().start((0.05 * dialogue[theInt][0 + cooladd].length), function(tmr:FlxTimer) {
                doneTalking = true;
                if ((theInt == 13 && theLine == 2) || (theInt == 12 && theLine == 1)) shouldDisappear = true;
            });
        }
    }

    public function stopTalking() {
        shutup = true;
        text.skip();
        sleepTimer = null;
        asleep = false;
        zedtween1 = null;
        zedtween2 = null;
        zedtween3 = null;
        die = true;
    }

    public function dance() {
        var headint:Int = 0;
        var headys:Array<Float> = [1.5, 1, 0.5, 0, -0.5, -0.5, -0.5, 0, 0.5, 1, 1.5];
        var torsoys:Array<Float> = [23, 23, 22.5, 22, 22, 22, 22, 22, 22.5, 23, 23];
        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            new FlxTimer().start(headint > 5 ? 0.05 : 0, function(tmr:FlxTimer) {head.y = day + Std.int((headys[headint] * lescal) - (lescal * 2));});
            new FlxTimer().start(headint > 5 ? 0 : 0.05, function(tmr:FlxTimer) {torso.y = day + Std.int((torsoys[headint] * lescal) - (lescal / 2));});
            headint++;
            if (headint >= 11) headint = 0;
        }, 11);
        new FlxTimer().start((0.3 * 11) + 0.3, function(tmr:FlxTimer) {
            dance();
        });        
    }

    /*override public function update(elapsed:Float) {
        zedoffx = Math.sin(elapsed) * 10;
        zedoffy = Math.sin(elapsed) * 10;
        zedGroup.forEach(function(zed:FlxSprite) {
            zed.offset.x = zedoffx;
            zed.offset.y = zedoffy;
        });
    }*/
}