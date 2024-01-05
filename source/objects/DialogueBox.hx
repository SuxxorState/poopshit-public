package objects;

import objects.UTTypeText;
import backend.Dialogue;

private var controls(get, never):Controls;
private function get_controls() return Controls.instance;

enum abstract BoxPos(Int) from Int to Int {
	var TOP = 10;
	var BOTTOM = 237;
    var ADAPTIVE = -1;
}

class DialogueBox extends FlxSpriteGroup {
    var boxWhite:FlxSprite;
    var boxBlack:FlxSprite;
    var char:FlxSprite;
    var soul:Soul;
    var text:UTTypeText;
    var asterisk:UTTypeText;
    var list:Array<Dynamic> = [];
    public var curLmao:Int = 0;
    public var finishedLine:Bool = false;

    public var choiceMode:Bool = false;
    public var curChoice:Bool = false;
    var path1:Array<Dynamic> = [];
    var path2:Array<Dynamic> = [];

    public static var dasize:Float = 2.8;
    public var onNextDia:Void->Void;
    public var onComplete:Void->Void;
    public var phoneCall:Bool = false;
    var player:Player;
    var shitass:FlxTimer;

    public function new(dialogue:Array<Dynamic>, ?options:BoxOptions) {
        options = fixBoxOptions(options);
        super();
        setPosition(25,options.boxPos);
        scrollFactor.set();

        list = dialogue;
        this.onNextDia = options.onNextDia;
        this.onComplete = options.onComplete;
        this.player = options.player;
        this.phoneCall = options.phoneCall;

        boxWhite = new FlxSprite(x, y).makeGraphic(Std.int(309 * dasize), Std.int(76 * dasize), FlxColor.WHITE);
        boxBlack = new FlxSprite(boxWhite.x + (3 * dasize), boxWhite.y + (3 * dasize)).makeGraphic(Std.int(303 * dasize), Std.int(70 * dasize), FlxColor.BLACK);

        add(boxWhite);
        add(boxBlack);

        if (phoneCall) {
            FlxG.sound.play(Paths.sound('phone_ring', 'overworld'));
            if (player != null) player.playAnim('call');
        }

        newtext(list[0][0], list[0][1], list[0][2]);
    }

    function newtext(charc:String, expression:Int, dialogue:String) {
        var charOptions:CharOptions = Dialogue.getCharData(charc);
        var soundbs:Array<FlxSound> = [];

        if (charOptions.sbAmt > 1) for (i in 0...charOptions.sbAmt) soundbs.push(new FlxSound().loadEmbedded(Paths.sound('dialogue/$charc/$i', 'overworld')));
        else soundbs.push(new FlxSound().loadEmbedded(Paths.sound('dialogue/${charOptions.soundByte}', 'overworld')));

        if (charc != '') {
            if (charOptions.gridSize == [0,0]) char = new FlxSprite().loadGraphic(Paths.image('dialogue/$charc', 'overworld'));
            else {
                char = new FlxSprite().loadGraphic(Paths.image('dialogue/$charc', 'overworld'), true, charOptions.gridSize[0], charOptions.gridSize[1]);
                char.animation.add(charc, [Std.int(Math.max(0, expression))]);
                if (charc == 'bf') char.animation.add('jackoff', [7,1], 20);
                else if (charc == 'poopshitter') char.animation.add('evileye', [9,8], 15);
                if (list[curLmao][3] != null) char.animation.play(list[curLmao][3]);
                else char.animation.play(charc);
            }
            char.setGraphicSize(Std.int(64 * dasize), Std.int(64 * dasize));
            char.updateHitbox();
            char.setPosition(x + (5 * dasize), y + (6 * dasize));
            char.antialiasing = false;
            if (expression >= 0) add(char);
        }

        finishedLine = false;
        asterisk = new UTTypeText(x + ((70 - ((charc == '' || expression == -1) ? 54 : 0)) * dasize), y + (10 * dasize), Std.int((230 + ((charc == '' || expression == -1) ? 60 : 0)) * dasize), '*', charOptions.typeFont, Std.int(12 * dasize * charOptions.fontSizeMult));
        if (charOptions.asterisk) add(asterisk);
        asterisk.start();
        asterisk.skip();

        text = new UTTypeText(x + ((85 - ((charc == '' || expression == -1) ? 54 : 0)) * dasize), y + (10 * dasize), Std.int((215 + ((charc == '' || expression == -1) ? 60 : 0)) * dasize), dialogue, charOptions.typeFont, Std.int(12 * dasize * charOptions.fontSizeMult));
        add(text);
        text.sounds = soundbs;
        if (dialogue == '') finishedLine = true;
        else {
            text.start(function() {            
                finishedLine = true;
                if (dialogue.endsWith("-")) {
                    shitass = new FlxTimer().start(0.1, function(tmr:FlxTimer) {nextBox();});
                }
            });
        }

        if (list[curLmao][4] != null) FlxG.sound.play(Paths.sound('dialogue/${list[curLmao][4]}', 'overworld'));
    }
    
    function newchoice(opt1:String, opt2:String) {
        var charOptions:CharOptions = Dialogue.getCharData('');
        var soundbs:Array<FlxSound> = [];
        soundbs.push(new FlxSound().loadEmbedded(Paths.sound('dialogue/${charOptions.soundByte}', 'overworld')));

        choiceMode = true;
        asterisk = new UTTypeText(x, y + (10 * dasize), 0, opt1, charOptions.typeFont, Std.int(12 * dasize * charOptions.fontSizeMult));
        asterisk.screenCenter(X);
        asterisk.x -= 270;
        add(asterisk);
        asterisk.sounds = soundbs;
        asterisk.start();

        text = new UTTypeText(x, y + (10 * dasize), 0, opt2, charOptions.typeFont, Std.int(12 * dasize * charOptions.fontSizeMult));
        text.screenCenter(X);
        text.x += 90;
        add(text);
        text.sounds = soundbs;
        text.start();

        soul = new Soul(0, y + (3 * dasize) + 18, true);
        soul.scale.set(3.111, 3.111);
        soul.updateHitbox();
        soul.x = (asterisk.x) - (soul.actual.width + 64);
        add(soul);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (choiceMode) {
            if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
                FlxG.sound.play(Paths.sound('select'));
                curChoice = !curChoice;
                soul.x = ((!curChoice ? asterisk.x : text.x) - (soul.actual.width + 44));
            }
            if (controls.ACCEPT || controls.DIA_NEXT) {
                FlxG.sound.play(Paths.sound('confirm'));
                curLmao--;
                for (i in 0...3) list.pop();
                for (i in (!curChoice ? path1 : path2)) list.push(i);
                choiceMode = false;
                remove(soul);
                nextBox();
            }
        } else {
            if (controls.DIA_NEXT && finishedLine) {
                nextBox();
                if (player != null && phoneCall && curLmao == list.length - 1) player.playAnim('hangup');
            }
        }
    }
    
    public function nextBox() {
        if (list[curLmao][0] != '') remove(char);
        remove(asterisk);
        remove(text);
        
        curLmao++;
        if (curLmao < list.length) {
            if (list[curLmao][0] == true) {
                newchoice(list[curLmao][1], list[curLmao][2]);
                path1 = list[curLmao+1];
                path2 = list[curLmao+2];
            } else newtext(list[curLmao][0], list[curLmao][1], list[curLmao][2]);
            if (onNextDia != null) onNextDia();
        } else {     
            if (onComplete != null) onComplete();
            destroy();
        }
    }

    override public function destroy() {
        onComplete = null;
        onNextDia = null;
        asterisk.skip();
        text.skip();
        if (shitass != null) shitass.cancel();

        super.destroy();
    }
    
    function fixBoxOptions(options:BoxOptions):BoxOptions {
        if (options == null) options = {boxPos: TOP, phoneCall: false};
        if (options.boxPos == null) options.boxPos = TOP;
        if (options.phoneCall == null) options.phoneCall = false;

        return options;
    }
}

typedef BoxOptions = {
    @:optional var boxPos:BoxPos;
    @:optional var phoneCall:Bool;
    @:optional var player:Player;
    @:optional var onNextDia:Void->Void;
    @:optional var onComplete:Void->Void;
}