package objects;

import states.Overworld;

private var controls(get, never):Controls;
private function get_controls() return Controls.instance;

class Player extends FlxSpriteGroup {
    public var curDir:Int = 0;
    public var char:String = 'bf';
    var character:FlxSprite;
    public var movingVer:Bool = true;
    public var movingHor:Bool = true;
    var defFps:Int = 6;
    var slpElapsed:Float = 0;
    var animArray:Array<String> = ['left','down','up','right'];
    var animIndex:Array<Array<Int>> = [[10,9,11,9], [1,0,2,0], [4,3,5,3], [7,6,8,6]];
    public static var speed:Float = 1.2;
    static var storedshit:Array<Dynamic> = [];

    var prevpos:FlxPoint;
    var popup:FlxSprite;
    public var inInv:Bool = false;
    public var inCutscene:Bool = false;
    public function new(char:String = 'bf', x:Float, y:Float, startDir:Int = 0) {
        if (storedshit.length >= 1) {
            super(storedshit[0],storedshit[1]);
            prevpos = new FlxPoint(storedshit[0],storedshit[1]);
            this.char = storedshit[2];
            curDir = storedshit[3];
            storedshit = [];
        } else {
            super(x,y);
            prevpos = new FlxPoint(x,y);
            this.char = char;
            curDir = startDir;
        }

        character = new FlxSprite();
        switch(char) {
            case 'sans-exe':
                character.loadGraphic(Paths.image('characters/sans', 'overworld'),true,25,32);

                var specIndex:Array<Array<Int>> = [[17,17,9], [15,15,0], [3], [16,16,6], [14,12,3,13]];
                for (i in 0...animArray.length) {
                    character.animation.add(animArray[i], animIndex[i], defFps, false);
                    character.animation.add('w${animArray[i]}', [animIndex[i][1]], defFps, false);  
                    character.animation.add('i${animArray[i]}', specIndex[i], defFps, false);
                    character.animation.add('s${animArray[i]}', [specIndex[4][i]], defFps, false);
                }

            default:
                character.loadGraphic(Paths.image('characters/bf', 'overworld'),true,23,32);
                for (i in 0...animArray.length) {
                    character.animation.add(animArray[i], animIndex[i], defFps, false);
                    character.animation.add('w${animArray[i]}', [animIndex[i][1]], defFps, false);  
                }

                character.animation.add("inv", [12, 13, 14], defFps / 4, false);
                character.animation.add("call", [14, 15, 16, 17], defFps, false);
                character.animation.add("hangup", [17, 16, 15, 14], defFps, false);
                character.animation.add("bored", [18], defFps, false);
                character.animation.add("sleep", [19, 20], defFps / 4);     
        }
        character.antialiasing = false;
        add(character);

        popup = new FlxSprite(6.5, -10).loadGraphic(Paths.image('characters/effects', 'overworld'),true,12,11);
        popup.animation.add('encounter', [0]);
        popup.animation.play('encounter');
        popup.visible = false;
        popup.antialiasing = false;
        add(popup);

        idle();
    }
    override function update(elapsed:Float) {
        if (!movingVer && !movingHor && !inInv) slpElapsed += elapsed;
        else slpElapsed = 0;

        if (slpElapsed > 30 && character.animation.curAnim.name != 'sleep') playAnim('sleep');
        else if (slpElapsed > 15 && character.animation.curAnim.name != 'bored' && character.animation.curAnim.name != 'sleep') playAnim('bored');

        if (!inInv && !inCutscene) {
            if (controls.OVERWORLD_LEFT && !controls.OVERWORLD_RIGHT) moveHor(0);
            if (controls.OVERWORLD_DOWN && !controls.OVERWORLD_UP) moveVer(1);
            if (controls.OVERWORLD_UP && !controls.OVERWORLD_DOWN) moveVer(2);
            if (controls.OVERWORLD_RIGHT && !controls.OVERWORLD_LEFT) moveHor(3);
            if ((movingVer || movingHor) && !controls.OVERWORLD_RIGHT && !controls.OVERWORLD_DOWN && !controls.OVERWORLD_LEFT && !controls.OVERWORLD_UP) {
                character.animation.play('w${animArray[curDir]}', false);
                movingVer = movingHor = false;
            }
            if (controls.OVERWORLD_LEFT_R || controls.OVERWORLD_RIGHT_R || controls.OVERWORLD_DOWN_R || controls.OVERWORLD_UP_R) {
                moveHor();
                moveVer();
            }   
        } else if (!inCutscene && character.animation.curAnim.name != 'call' && character.animation.curAnim.name != 'hangup') {
            character.animation.play('inv', false);
            movingVer = movingHor = false;    
        }
        
		super.update(elapsed);
    }

    public function interact() {
        FlxG.sound.play(Paths.sound('encounter', 'overworld'));
        character.animation.play("i" + animArray[curDir], true);
    }

    public function shocked() {
        character.animation.play('s${animArray[curDir]}', true);
        popup.visible = true;
    }

    public function playAnim(anim:String) {
        character.animation.play(anim, true);
    }

    public function rememberPos() storedshit = [x,y,char,curDir];
    public static function forgetPos() storedshit = [];

    public function idle() {
        character.animation.play('w${animArray[curDir]}', false);
        movingVer = movingHor = true;
        inInv = false;
    }

    function moveHor(activeMoveKey:Int = -1) {
        if (activeMoveKey >= 0) curDir = activeMoveKey;
        if (character.animation.curAnim == null || character.animation.curAnim.finished) {
            character.animation.play('w${animArray[curDir]}');
            character.animation.stop();
        }

        if (!Overworld.checkForCollision(curDir)) {// collision
            movingHor = true;
            switch (curDir) {
                case 0: //left
                    x -= speed;
                case 3: //right
                    x += speed;
            }
            x = Math.round(x * Math.pow(10, 1)) / Math.pow(10, 1); // makes the players x pos not have crazy long decimals due to the move speed being a decimal
            //trace('x:$x');
        } else if (x != prevpos.x && y == prevpos.y && ((controls.OVERWORLD_LEFT && !controls.OVERWORLD_RIGHT) || (!controls.OVERWORLD_LEFT && controls.OVERWORLD_RIGHT))) {
            movingHor = true;
            movingVer = false;
        }
        
        if (x == prevpos.x) movingHor = false;
        prevpos.x = x;

        if (movingHor) {
            if (controls.OVERWORLD_LEFT && !controls.OVERWORLD_RIGHT)
                character.animation.play(animArray[0], false);
            else if (controls.OVERWORLD_RIGHT && !controls.OVERWORLD_LEFT)
                character.animation.play(animArray[3], false);
        }
        popup.visible = false;
    }

    function moveVer(activeMoveKey:Int = -1) {
        if (activeMoveKey >= 1) curDir = activeMoveKey;
        if (character.animation.curAnim == null || character.animation.curAnim.finished) {
            character.animation.play('w${animArray[curDir]}');
            character.animation.stop();
        }

        if (!Overworld.checkForCollision(curDir)) {// collision
            movingVer = true;
            switch (curDir) {
                case 1: //down
                    y += speed;
                case 2: //up
                    y -= speed;
            }
            y = Math.round(y * Math.pow(10, 1)) / Math.pow(10, 1);
            //trace('y:$y');
        } else if (x == prevpos.x && y != prevpos.y && ((controls.OVERWORLD_DOWN && !controls.OVERWORLD_UP) || (!controls.OVERWORLD_DOWN && controls.OVERWORLD_UP))) {
            movingVer = true;
            movingHor = false;
        }
        
        if (y == prevpos.y) movingVer = false;
        prevpos.y = y;

        if (movingVer && !movingHor) {
            if (controls.OVERWORLD_DOWN && !controls.OVERWORLD_UP)
                character.animation.play(animArray[1], false);
            else if (controls.OVERWORLD_UP && !controls.OVERWORLD_DOWN)
                character.animation.play(animArray[2], false);
        }
        popup.visible = false;
    }
}

class PlayerHitbox extends FlxSprite
{
    var lePlayer:Player;
    var lastDir:Int = -1;
    var playerOffset:Array<Float> = [0,0];
    public function new(player:Player)
        {
            super();
            alpha = 0.4;
            //visible = false;
            lePlayer = player;
            makeGraphic(lePlayer.char == 'sans-exe' ? 25 : 22,15,0x0000FF00);
            playerOffset = [0,15];
        }
    override function update(elapsed:Float)
        {
            x = lePlayer.x+playerOffset[0];
            y = lePlayer.y+playerOffset[1];

            super.update(elapsed);
        }
}