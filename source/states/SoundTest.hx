package states;

import backend.InputFormatter;

class SoundTest extends MusicBeatState {
    var starterTxt:FlxText;
    var nameTxt:FlxText;
    var titleTxt:FlxText;
    var leftArrow:FlxText;
    var rightArrow:FlxText;

    var names:Array<String> = ["Glad City", "Vegan Facility", "Quandale Dingle", "Gaster's Theme"];
    var started:Bool = false;
    var finished:Bool = false;
    var curSelected:Int = -1;
    var curShown:Int = 0;

    override function create() {
        super.create();

        starterTxt = new FlxText(0, 75, 0, 'Welcome to the Sound Test!\nListen to all your favorites.\nPress ${getKeyByName('ui_left',1)} or ${getKeyByName('ui_right',1)} to select.\nPress ${getKeyByName('accept',1)} to play a song.');
        starterTxt.setFormat(Paths.font('DTM-Mono.ttf'), 36, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
        starterTxt.screenCenter(X);
        starterTxt.antialiasing = false;
        add(starterTxt);

        leftArrow = new FlxText(10,0,0, "<<");
        leftArrow.setFormat(Paths.font('DTM-Mono.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
        leftArrow.screenCenter(Y);
        leftArrow.visible = false;
        leftArrow.antialiasing = false;
        add(leftArrow);
        
        rightArrow = new FlxText(0,0,0, ">>");
        rightArrow.setFormat(Paths.font('DTM-Mono.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
        rightArrow.x = FlxG.width - (rightArrow.width + 10);
        rightArrow.screenCenter(Y);
        rightArrow.visible = false;
        rightArrow.antialiasing = false;
        add(rightArrow);
        
        titleTxt = new FlxText(0,75,0, "SOUND TEST");
        titleTxt.setFormat(Paths.font('DTM-Mono.ttf'), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
        titleTxt.screenCenter(X);
        titleTxt.visible = false;
        titleTxt.antialiasing = false;
        add(titleTxt);
        
        nameTxt = new FlxText(0,0,0, names[0]);
        nameTxt.setFormat(Paths.font('DTM-Mono.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
        nameTxt.screenCenter();
        nameTxt.visible = false;
        nameTxt.antialiasing = false;
        add(nameTxt);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (curSelected == curShown) nameTxt.color = FlxColor.YELLOW;
        else nameTxt.color = FlxColor.WHITE;
        if (controls.UI_RIGHT) rightArrow.color = FlxColor.YELLOW;
        else rightArrow.color = FlxColor.WHITE;
        if (controls.UI_RIGHT_P && started) {
            curShown++;
            if (curShown >= names.length) curShown = 0;

            nameTxt.text = names[curShown];
            nameTxt.screenCenter();
        }
        if (controls.UI_LEFT) leftArrow.color = FlxColor.YELLOW;
        else leftArrow.color = FlxColor.WHITE;
        if (controls.UI_LEFT_P && started) {
            curShown--;
            if (curShown <= 0) curShown = names.length - 1;

            nameTxt.text = names[curShown];
            nameTxt.screenCenter();
        }

        if (controls.ACCEPT) {
            if (!finished && !started) {
                starterTxt.visible = false;
                leftArrow.visible = true;
                rightArrow.visible = true;
                titleTxt.visible = true;
                nameTxt.visible = true;
                started = true;
                new FlxTimer().start(50, function(tmr:FlxTimer) {
                    finished = true;
                    starterTxt.text = "Thanks for your feedback!\nBe seeing you soon!";
                    starterTxt.visible = true;
                    leftArrow.visible = false;
                    rightArrow.visible = false;
                    titleTxt.visible = false;
                    nameTxt.visible = false;
                    new FlxTimer().start(5, function(tmr:FlxTimer) {#if sys Sys.exit(0); #end});
                });
            }
            if (!finished && curSelected != curShown && names[curSelected] != "Gaster's Theme") {
                curSelected = curShown;

                if(FlxG.sound.music != null) FlxG.sound.music.stop();
                FlxG.sound.playMusic(Paths.music(names[curSelected], 'overworld'), 0.7);
            }
        }
    }

    function getKeyByName(leStr:String,leNum:Int) return InputFormatter.getKeyName(ClientPrefs.keyBinds.get(leStr)[leNum]);
}