package objects;

private var controls(get, never):Controls;
private function get_controls() return Controls.instance;
private var lescal:Float = 7.5;

class PauseShitter extends FlxSpriteGroup {
	var dialogue:Array<Dynamic> = [//dialogue, head & torso anims => repeat for multiple lines
		["i'm thinking about getting into the telescope business.", ["wink", "shrug"]], 
		["fun fact, this mod creator guy had another mod.", ["normal", "idle"], "wonder what happened to it...", ["side-grin", "shrug"]], 
		["if you miss notes, you take damage.", ["normal", "idle"]], 
		["", ["closed", "idle"]], 
		["well, that went well.", ["side-grin", "idle"]], 
		["fun fact, you can press one of those big buttons...", ["normal", "idle"], "and they'll do something.", ["wink", "idle"], "crazy, right?", ["side-grin", "shrug"]],
		["hey guys", ["normal", "idle"]],
		["do you get what i'm saying?", ["side-grin", "shrug"]],
		["isn't my brother cool?", ["wink", "idle"]],
        ['have you seriously played this ${PlayState.deathCounter + 1} time${PlayState.deathCounter > 0 ? 's' : ''}?', ["wink", "idle"], PlayState.deathCounter > 0 ? "wow, that's some dedication..." : "that sucks, 'cause it's better the second time.", ["side-grin", "shrug"]],
        ["better hurry up kid,", ["side-grin", "idle"], "i took time outta my break for this.", ["wink", "shrug"]],
		["do you wanna have a bad ti-", ["no-eyes", "fist"], "wait...", ["closed", "idle"], "wrong line...", ["side-grin", "idle"]], 
		["no. not today.", ["worried", "fist"]],
		["fun fact,", ["normal", "shrug"], "i am rapidly approaching.", ["no-eyes", "fist"]],

        ["what's that thing behind you?", ["shocked", "idle"], "oh, wait...", ["normal", "idle"], "that's just your shadow.", ["side-grin", "shrug"]],
        ["i know what you did...", ["scary", "fist"]],
        ["if it wasn't obvious by now...", ["normal", "idle"], "i do not condone what the other sanses are doing here.", ["serious", "idle"]],
        ["i drop children off of buildings.", ["normal", "idle"]],
        ["...", ["normal", "idle-ic"], "what, was i supposed to say something?", ["side-grin", "idle"]],
        ["big boner down the lane", ["eye-flash", "idle"]],

        ["nice gaming setup.", ["wink", "shrug"]], //by corth
        ["that sure was an undertale.", ["side-grin", "idle"]], //by serif
        ["now, im not gonna judge you for pausing,", ["wink", "idle"], "but my brother, on the other hand...", ["side-grin", "shrug"]], //by serif

        ["looks like you're experiencing some sins.", ["wink", "idle"]], //1-10 KR
        ["something's weighing on your mind, by the looks of it.", ["side-grin", "idle"]], //11-20 KR
        ["fun fact, KR stands for karma.", ["closed", "idle"], "the more you hurt others, the more pain you get back.", ["no-eyes", "shrug"]], //21-30 KR
        ["looks like death and karma made a pact against you.", ["no-eyes", "shrug"]], //31-40 KR
        ["mmm, ice cream so good, gang gang", ["normal", "idle-ic"]],
	];
    var headAnims:Array<Dynamic> = [["normal",[0]], ["no-eyes",[1]], ["eye-flash",[3,2], 15, true], ["wink", [4]], ["closed", [5]], ["worried", [6]], ["drifting", [0,7,13,14], 0.2], ["shocked", [8]], ["side-grin", [9]], ["confused", [10]], ["serious", [11]], ["scary", [12]]];
    var torsoAnims:Array<Dynamic> = [["idle", [0]], ["handmove", [0,1,2,3,4], 15], ["shrug", [5]], ["fist", [6]], ["idle-ic", [7]], ["idle-idrowsy", [8]], ["idle-isleep", [8]]];

    var excludeLines:Array<Int> = [];
    var curDia:Int = 0;
    var curLine:Int = 1;

    var idling:Bool = false;
    private var sleeping:Bool = false;
    var skipped:Bool = false;
    public var gone:Bool = false;
    var redundant:Bool = false;
    
    private var head:FlxSprite;
    private var torso:FlxSprite;
    private var legs:FlxSprite;
    private var speechBubble:FlxSprite;
    private var text:UTTypeText;

    var sleepTimer:FlxTimer;
    var zedTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
    var zedTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
    var zedSprites:Map<Int, FlxSprite> = [];

    public function new(x:Float, y:Float) {
        super(x,y);
        antialiasing = false;

        if (PlayState.deathCounter <= 0 || FlxG.sound.music.time < (FlxG.sound.music.length * 0.9)) multiExcludeLines([4,20]);
        if (PlayState.instance != null && PlayState.instance.songHasKR && PlayState.instance.karma != PlayState.instance.health)
            multiExcludeLines([23,24,25,26], [Std.int(FlxMath.bound(Math.ceil((PlayState.instance.karma - PlayState.instance.health) / 10), 1, 4)) + 22]);
        else 
            multiExcludeLines([23,24,25,26]);
        if (Paths.formatToSongPath(PlayState.SONG.song) != 'constipation') excludeLines.push(16);
        if (Paths.formatToSongPath(PlayState.SONG.song) != 'kidney-stone') excludeLines.push(21);
        curDia = FlxG.random.int(0, dialogue.length - 1, excludeLines);
        if (Paths.formatToSongPath(PlayState.SONG.song) == 'kidney-stone' && FlxG.random.int(1, 5) == 5) curDia = 8;
        if (curDia != 3) excludeLines.push(3);

        head = new FlxSprite(Std.int(9 * lescal), Std.int(-1.5 * lescal)).loadGraphic(Paths.image('pause/shitter/Heads', 'shared'),true,34,31);
        head.setGraphicSize(Std.int(head.width * lescal));
        head.updateHitbox();
        head.antialiasing = false;
        for (i in headAnims) head.animation.add(i[0], i[1], i[2] != null ? i[2] : 24, i[3] != null ? i[3] : false);
        head.animation.play(dialogue[curDia][1][0]);

        torso = new FlxSprite(Std.int(-1 * lescal), Std.int(22 * lescal)).loadGraphic(Paths.image('pause/shitter/Torsos', 'shared'),true,63,39);
        torso.setGraphicSize(Std.int(torso.width * lescal));
        torso.updateHitbox();
        torso.antialiasing = false;
        for (i in torsoAnims) torso.animation.add(i[0], i[1], i[2] != null ? i[2] : 24, false);
        torso.animation.play(dialogue[curDia][1][1]);

        legs = new FlxSprite(Std.int(7 * lescal) - (lescal / 2), Std.int(45 * lescal)).loadGraphic(Paths.image('pause/shitter/Pants', 'shared'));
        legs.setGraphicSize(Std.int(legs.width * lescal));
        legs.updateHitbox();
        legs.antialiasing = false;

        add(legs);
        add(torso);
        for (i in 0...3) {
            var zed:FlxSprite = new FlxSprite(head.width, Std.int(4 * lescal) - (lescal / 2)).loadGraphic(Paths.image('pause/shitter/Z', 'shared'));
            zed.setGraphicSize(Std.int(zed.width * 1.5));
            zed.updateHitbox();
            zed.antialiasing = false;
            zed.alpha = 0;
            zedSprites.set(i, zed);
            add(zed);
        }
        add(head);

        speechBubble = new FlxSprite(350, 0).loadGraphic(Paths.image('pause/bubble', 'shared'));
        speechBubble.setGraphicSize(Std.int(speechBubble.width * 2));
        speechBubble.updateHitbox();
        speechBubble.antialiasing = false;
        
        text = new UTTypeText(420, 20, 390, dialogue[curDia][0], "undertale-comic-sans-battle.ttf", 28, FlxColor.BLACK);
        text.sounds = [FlxG.sound.load(Paths.sound('dialogue/Sans Dialogue', 'overworld'), 0.8)];  
        add(speechBubble);
        add(text);
        
        if (curDia == 3) sleep();
        else rerollDialogue(curDia);
		if(!ClientPrefs.data.lowQuality) dance();
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (idling) {
            if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && !sleeping) {
                sleepTimer.cancel();
                playAnim(["normal", "idle"]);
                finish();
            }
        } else {
            if (controls.DIA_NEXT && skipped) finish();
            if (controls.DIA_SKIP) redundant = true;
        }
    }
    
    var torsoTimer:Null<FlxTimer>;
    public function playAnim(theAnims:Array<String>) {
        if (PlayState.instance.isSansGone || theAnims == null || theAnims.length < 1) return;

        if ((torso != null || torso.exists) && torso.animation.curAnim != null) {
            var wait:Bool = false;
            //if (theAnims[0] == 'drifting' && theAnims[1] == 'idle' && torso.animation.curAnim.name == 'idle-ic') theAnims[1] += '-idrowsy';
            /*else*/ if (theAnims[1] == 'idle' && (torso.animation.curAnim.name == 'idle-ic' || torso.animation.curAnim.name == 'idle-idrowsy')) theAnims[1] += sleeping ? '-isleep' : '-ic';
    
            if ((theAnims[1] == 'shrug' || theAnims[1] == 'fist') && torso.animation.curAnim.name == 'idle') {
                torso.animation.play('handmove');
                wait = true;
            } else if ((torso.animation.curAnim.name == 'shrug' || torso.animation.curAnim.name == 'fist') && theAnims[1] == 'idle') {
                torso.animation.play('handmove', false, true);
                wait = true;
            }
            torsoTimer = new FlxTimer().start(wait ? 0.33 : 0, function(tmr:FlxTimer) {torso.animation.play(theAnims[1]);});
        }

        if ((head != null || head.exists) && head.animation.curAnim != null) head.animation.play(theAnims[0]);
    }
    
    public function rerollDialogue(num:Int = -1) {
        if (idling) return;

        skipped = false;
        if (num == -1) curLine = 1;
        curDia = (num == -1 ? FlxG.random.int(0, dialogue.length - 1, excludeLines) : num);
        if (Paths.formatToSongPath(PlayState.SONG.song) == 'kidney-stone' && FlxG.random.int(1, 5) == 5) curDia = 8;
        excludeLines.push(curDia);

        var cooladd:Int = 2 * (curLine - 1);

        playAnim(dialogue[curDia][1 + cooladd]);
        text.resetText(dialogue[curDia][0 + cooladd]);
        text.start(function() {
            skipped = true;
            if ((curDia == 13 && curLine == 2) || ((curDia == 12 || curDia == 15) && curLine == 1)) gone = true;
        });
    }
    
    function finish() {
        if (dialogue[curDia].length / 2 > curLine) {
            curLine++;
            rerollDialogue(curDia);
            return;
        } else if (curDia == 11) {
            rerollDialogue();
            return; 
        }

        if (!redundant) {
            Trophies.pauseTracker[0]++;
            FlxG.save.data.pauseTracker = Trophies.pauseTracker;
            FlxG.save.flush();
        }

        idling = true;
        text.visible = text.active = speechBubble.visible = speechBubble.active = false;
        sleepTimer = new FlxTimer().start(20, function(tmr:FlxTimer) {sleep();});
        playAnim(["drifting", "idle"]);
    }
    
    function sleep() {
        sleeping = idling = true;
        remove(text);
        remove(speechBubble);
        playAnim(["closed", "idle"]);
        startZeds();
    }
    
    public function startZeds() {
        for (i in 0...3) {
            var leZed = zedSprites.get(i);
            zedTimers.set('going$i', new FlxTimer().start(0.5 * (i+1), function(tmr:FlxTimer) {
                leZed.setPosition(x + head.width, y + (Std.int(4 * lescal) - (lescal / 2)));
                zedTweens.set('${0+(4*i)}', FlxTween.tween(leZed, {y: leZed.y - 180}, 1.5, {ease: FlxEase.sineIn}));
                zedTweens.set('${1+(4*i)}', FlxTween.tween(leZed, {x: leZed.x + 135}, 1.5, {ease: FlxEase.sineOut}));
                zedTweens.set('${2+(4*i)}', FlxTween.tween(leZed, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut,onComplete: function(twn:FlxTween) {
                zedTweens.set('${3+(4*i)}', FlxTween.tween(leZed, {alpha: 0}, 1, {ease: FlxEase.cubeInOut,onComplete: function(twn:FlxTween) {
                    if (i == 2) startZeds();
                }}));
                }}));
            }));
        }
    }

    public function dance() {
        var headint:Int = 0;
        var headys:Array<Float> = [1.5, 1, 0.5, 0, -0.5, -0.5, -0.5, 0, 0.5, 1, 1.5];
        var torsoys:Array<Float> = [22, 22, 21.5, 21, 21, 21, 21, 21, 21.5, 22, 22];
        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            new FlxTimer().start(headint > 5 ? 0.05 : 0, function(tmr:FlxTimer) {head.y = y + Std.int((headys[headint] * lescal) - (lescal * 2));});
            new FlxTimer().start(headint > 5 ? 0 : 0.05, function(tmr:FlxTimer) {torso.y = y + Std.int((torsoys[headint] * lescal) - (lescal / 2));});
            headint++;
            if (headint >= 11) headint = 0;
        }, 11);
        new FlxTimer().start((0.3 * 11) + 0.3, function(tmr:FlxTimer) {
            dance();
        });        
    }

    function multiExcludeLines(ae:Array<Int>, ?exc:Array<Int>) {for (i in ae) {
        if (exc != null && exc.length >= 1 && exc.contains(i)) continue; //works like random int. useful for sorting out more complex dialogues, like the KR ones.
        excludeLines.push(i);
    }}

    override public function destroy() {//yeah
        text.skip();
        if (sleepTimer != null) sleepTimer.cancel();
        if (torsoTimer != null) torsoTimer.cancel();
        if ((torso != null || torso.exists) && torso.animation.curAnim != null) torso.animation.stop();
        if ((head != null || head.exists) && head.animation.curAnim != null) head.animation.stop();
        for (tween in zedTweens) tween.cancel();
        for (timer in zedTimers) timer.cancel();

        if ((curDia == 13 || curDia == 12 || curDia == 15) && PlayState.instance != null) PlayState.instance.isSansGone = true;

        super.destroy();
    }
}


class PausePisser extends FlxSpriteGroup {
	var dialogue:Array<Dynamic> = [//dialogue, head anim => repeat for multiple lines
		["HELLO, HUMAN! IT IS I, THE GREAT PAPYRUS!", "normal", "WHERE AM I..?", "sly"],
        ["I DISLIKE THIS MOD A GRAND AMOUNT!!", "mad", "IT PAINTS A BAD IMAGE OF ME AND MY BROTHER, SANS...", "sad"],
        ["STAY HYDRATED!!", "idle"],
        ["HAVE YOU SEEN MY BROTHER, SANS?", "normal", "HE BETTER NOT BE SLACKING OFF ON HIS INTERDIMENSIONAL PAUSE JOB!", "mad"],
        ["YOU'RE NOT HUNGRY, ARE YOU?", "idle", "WORRY NOT, FOR I ALWAYS CARRY A SPARE PLATE OF SPAGHETTI FOR ANY CONVENIENT PAUSING!!", "mad"],
        ["NYEH HEH HEH!!!", "normal"],
        ["DO YOU KNOW WHERE THE BATHROOM IS??", "idle"],
        ["EXCITED TO BE HERE!!", "normal", "THE GREAT PAPYRUS DOES NOT MISS OUT ON INGAME TIPS!!", "idle"],
        ["I CAN'T FEEL MY LEGS!!", "normal"],
        ["ARE YOU ENJOYING YOURSELF?", "normal"],
        ["WOWIE, THAT'S ME!!", "anime", "WHY AM I HOLDING A PIECE OF BURNING PAPER..?", "side"]
	];
    var headAnims:Array<Dynamic> = [["idle", [0]], ["normal",[1,2,3]], ["mad",[4,5,6]], ["sad",[7,8,9]], ["sweaty", [10,11,12]], ["sly", [13,14]], ["read", [13,14], 1.5], ["anime", [15,16]], ["mad-alt", [17]], ["shocked-up", [18]], ["blush-down", [19]], ["angry", [20]], ["eye-roll", [21]], ["sigh", [22]], ["side-smile", [23]], ["shocked", [24]], ["side", [25]], ["shocked-comical", [26]], ["blush-front", [27]], ["blush-closed", [28]], ["confident", [29]]];
    var bodyAnims:Array<Dynamic> = [["idle", [0]], ["grab-book", [0,1,2,3], 15], ["read", [4]], ["joy", [5]]];

    var excludeLines:Array<Int> = [];
    var curDia:Int = 0;
    var curLine:Int = 1;

    var idling:Bool = false;
    var skipped:Bool = false;
    static var papDiaLoop = false;
    var redundant:Bool = false;
    
    private var head:FlxSprite;
    private var body:FlxSprite;
    private var speechBubble:FlxSprite;
    private var text:UTTypeText;

    var readTimer:FlxTimer;

    public function new(x:Float, y:Float) {
        super(x,y);
        antialiasing = false;

        if (Paths.formatToSongPath(PlayState.SONG.song) != 'kidney-stone') excludeLines.push(10);
        curDia = FlxG.random.int(0, dialogue.length - 1, excludeLines);

        head = new FlxSprite(Std.int(20 * lescal), Std.int(1 * lescal)).loadGraphic(Paths.image('pause/pisser/Heads', 'shared'),true,23,34);
        head.setGraphicSize(Std.int(head.width * lescal));
        head.updateHitbox();
        head.antialiasing = false;
        for (i in headAnims) head.animation.add(i[0], i[1], i[2] != null ? i[2] : 8);
        head.animation.play(dialogue[curDia][1][0]);

        body = new FlxSprite(0, Std.int(7 * lescal)).loadGraphic(Paths.image('pause/pisser/Bodies', 'shared'), true, 75, 100);
        body.setGraphicSize(Std.int(body.width * lescal));
        body.updateHitbox();
        body.antialiasing = false;
        for (i in bodyAnims) body.animation.add(i[0], i[1], 15, false);
        body.animation.play(bodyAnims[0][0]);

        add(head);
        add(body);

        speechBubble = new FlxSprite(-380, 20).loadGraphic(Paths.image('pause/bubble', 'shared'));
        speechBubble.flipX = true;
        speechBubble.setGraphicSize(Std.int(speechBubble.width * 2));
        speechBubble.updateHitbox();
        speechBubble.antialiasing = false;
        
        text = new UTTypeText(speechBubble.x + 20, speechBubble.y + 20, 390, dialogue[curDia][0], "undertale-papyrus-battle.ttf",  28, FlxColor.BLACK);
        text.sounds = [FlxG.sound.load(Paths.sound('dialogue/Piss', 'overworld'), 0.8)];  
        add(speechBubble);
        add(text);
        
        rerollDialogue(curDia);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!idling) {
            if (controls.DIA_NEXT && skipped) finish();
            if (controls.DIA_SKIP) redundant = true;
        }
    }
    
    public function playAnim(theAnim:String) {
        if (PlayState.instance.isSansGone) return;

        if (head != null || head.exists) head.animation.play(theAnim);
        if (body != null || body.exists) {
            if (theAnim == "anime") body.animation.play("joy");
            else if (theAnim == "read") body.animation.play("read");
            else body.animation.play("idle");
        }
    }
    
    public function rerollDialogue(num:Int = -1) {
        if (idling) return;

        skipped = false;
        if (papDiaLoop) {
            num = 0;
            switch(PlayState.deathCounter) {
                case 0: dialogue = [["ARE YOU ENJOYING YOURSELF?", "normal"]];
                case 1: dialogue = [["NO ANSWER YET??", "normal", "THAT'S OKAY, TAKE YOUR TIME!!", "idle"]];
                case 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9: dialogue = [["GLAD TO HEAR!!", "normal"]];
                default: dialogue = [["ARE YOU SURE?? YOU DON'T LOOK VERY ENJOYING-YOURSELF-Y...", "sad"]];
            }
        }

        if (num == -1) curLine = 1;
        curDia = (num == -1 ? FlxG.random.int(0, dialogue.length - 1, excludeLines) : num);
        excludeLines.push(curDia);
        if (curDia == 9) papDiaLoop = true;

        var cooladd:Int = 2 * (curLine - 1);

        text.resetText(dialogue[curDia][0 + cooladd]);
        text.start(function() {
            skipped = true;
            if ((head != null || head.exists) && head.animation.curAnim != null) {
                head.animation.curAnim.curFrame = 0;
                head.animation.pause();
            }
        });
        playAnim(dialogue[curDia][1 + cooladd]);
    }
    
    function finish() {
        if (dialogue[curDia].length / 2 > curLine) {
            curLine++;
            rerollDialogue(curDia);
            return;
        }
        
        if (!redundant) {
            Trophies.pauseTracker[1]++;
            FlxG.save.data.pauseTracker = Trophies.pauseTracker;
            FlxG.save.flush();
        }

        idling = true;
        text.visible = text.active = speechBubble.visible = speechBubble.active = false;
        playAnim("idle");
        readTimer = new FlxTimer().start(30, function(tmr:FlxTimer) {read();});
    }

    function read() {
        head.animation.play("normal");
        head.animation.pause();

        body.animation.play("grab-book");
        readTimer = new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            playAnim("read");
        });
    }

    function multiExcludeLines(ae:Array<Int>, ?exc:Array<Int>) {for (i in ae) {
        if (exc != null && exc.length >= 1 && exc.contains(i)) continue;
        excludeLines.push(i);
    }}

    override public function destroy() {
        text.skip();
        if (readTimer != null) readTimer.cancel();
        if ((head != null || head.exists) && head.animation.curAnim != null) head.animation.stop();
        if ((body != null || body.exists) && head.animation.curAnim != null) body.animation.stop();

        super.destroy();
    }
}