package states;

import objects.*;

using StringTools;

enum NameMods {
	LOCKED;
	CRASH;
    HARD;
    RAREBLIN;
    TROLL;
}

class NameYourLittleShit extends MusicBeatState
{
    var nameOutputs:Array<Dynamic> = [
        [[""], "Very fuckin funny.", LOCKED],
        [["suxxor", "xor"], "Please krill yourself", LOCKED],
        [["april", "iris"], "sample text"],
        [["necoar", "vruzze", "raz", "razmus"], "The finale guy"],
        [["fireat"], "Not that one", LOCKED],
        [["whire"], "That's better"],
        [["ink"], "hell nah.", LOCKED],
        [["cross"], "Caca"],
        [["red"], "Morning wood"],
        [["gypsy"], "ba cine esti tu ma ba baga-mi-as pu-"],
        [["d", "doguy", "doogai"], "Doogai"],
        [["sheewa"], "balls"],
        [["julio"], "please help mre lewis has me in their basemetn asn KIDDING!!!!!!!jampackedjumble"],
        [["croomi"], "bitch, youre gay. and you know it"],
        [["sodapo"], "Who?"],
        [["muggo"], "I will munt you"],
        [["george"], "117"],
        [["jorcla"], "Are you absolutely positively super duper sure you wanna pick this?"],
        [["quarin"], "I am a starving child and this is the last thing i am going to see, gootbye."],
        [["rareb", "rarebl"], "vs. him coming soon", RAREBLIN],
        [['rocky'], "fuck you stupid ass name"],
        /*[["vanila"], "Goofy aah forehead"],
        [["kofv"], "I be suckin my dick n shit bro :weary:"],
        [["axion", "4axion"], "", CAT],*/

        [["gf", "Poopshitterswap???"]],
        [["boyfri"], "end FNF"],
        [["girlfr"], "iend FNF"],
        [["merg"], "What's up guys, welcome back to the Poopshitters Demo"],
        [["cmgame", "commun", "comgam"], "Poopshitter lens flare"],
        [["ironds", "ironde", "iron", "sagita"], "hola"],
        [["poop", "shit", "crap"], "shut the fuck up.", LOCKED],
        [["pee", "piss", "urine"], "NO NAME SHALL BE GREATER THAN MINE!!!", LOCKED],
        [["cum", "jizz", "nut"], "what did bro mean by this"],
        [["bf", "frisk"], "WARNING: This name will make your life hell. Oh, wait, it's locked.", LOCKED],

        [["sans"], "nope.", LOCKED],
        [["papyru"], "I'LL ALLOW IT!!!!"],
        [["gaster"], "", CRASH],
        [["toriel"], "It would be better if you chose your own name, my child.", LOCKED],
        [["flowey"], "I already CHOSE that name!", LOCKED],
        [["chara"], "The true name."],
        [["napsta"], "... They are powerless to stop you."],
        [["temmie"], "hOI!"],
        [["asgore"], "you cannot.", LOCKED],
        [["asriel"], "...", LOCKED],
        [["alphys"], "D-Dont do that.", LOCKED],
        [["alphy"], "Uh.. ok."],
        [["murder", "mercy", "rap", "sing"], "That's a little on-the-nose, isn't it?"],
        [["metta"], "OOOH!!! ARE YOU PROMOTING MY BRAND?"],
        [["gerson"], "Wah hah hah! Why not?"],
        [["catty"], "Bratty! Bratty! That's MY name!"],
        [["bratty"], "Like, ok I guess."],
        [["bpants"], "You really are scraping the bottom of the barrel."],
        [["aaaaaa"], "Not very creative..?"],
        [["jerry"], "Jerry."],
        [["woshua"], "Clean name."],
        [["shyren"], "...?"],
        [["aaron"], "Is this name correct? ;)"],

        [["corth", "corthy", "cortho", "korth", "korthy", "kortho", "sorth", "sorthy", "sortho"], "TF2 Spy in the sense that you're french and that's it", TROLL],
        [["serif", "serifo", "jolyne"], "Poopshitters X SSM when", TROLL],
        [["tempot", "tempo", "ashley"], "Rizz sfx", TROLL],
        [["agenta"], "#1 Poopshitters fan", TROLL],
        [["lino", "steve"], "Is this 16 OC im talking to?"],
        [["a", "b", "c", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "y", "z"], "How original."],
        [["fucku"], "well fuck you too ig", CRASH],
        [["fuck", "bitch", "ass", "dick", "pussy", "cunt", "bastar"], "someone's got a potty mouth."],
        [["name"], "Okay smartass."],
        [["x"], "are you fucking stupid? who names themselves or anything related to them this? go back to the drawing board, you're genuinely a blemish to our society.", LOCKED]
    ];

    var curSelected:Int = 0;
    var name:String = '';
    var bts:Array<String> = [
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','','',
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','','',
        'Quit','','Backspace','','','Done',''
    ];
    var btns:Array<ShakeText> = [];
    var nametxt:FlxText;
    var fntSize:Int = 42;
    var toptxt:FlxText;

    var ynPhase:Bool = false;
    var yn:Bool = false;
    var yes:FlxText;
    var no:FlxText;
    var disall:Bool = false;
    var locked:Bool = false;
    override function create() {
        #if desktop
		DiscordClient.changePresence("Naming Their Character", null);
		#end
        FlxG.sound.playMusic(Paths.music('PoopshittersMainMenu'));
        toptxt = new FlxText(0, 75, 700, 'Name your little shit.', fntSize);
        toptxt.antialiasing = false;
        toptxt.setFormat(Paths.font("DTM-Mono.ttf"), fntSize, FlxColor.WHITE, CENTER);
        toptxt.screenCenter(X);
        add(toptxt);

        nametxt = new FlxText(0, 60, 0, '', fntSize);
        nametxt.antialiasing = false;
        nametxt.setFormat(Paths.font("DTM-Mono.ttf"), fntSize*4, FlxColor.WHITE, CENTER);
        nametxt.screenCenter(X);
        nametxt.scale.set(0.27,0.27);
        add(nametxt);

        var stQ:Bool = false;
        var leInt = 0;
        for (i in bts)
        {
            var btn:ShakeText = new ShakeText(177+((leInt-(Math.floor(leInt/7)*7))*96), 233+(Math.floor(leInt/7)*48), 0, i, fntSize);
            btn.setFormat(Paths.font("DTM-Mono.ttf"), fntSize,(curSelected == leInt) ? FlxColor.YELLOW : FlxColor.WHITE, CENTER);
            btn.ID = leInt;
            add(btn);
            if (i == 'Quit')
                stQ = true;
            if (stQ)
                {
                    btn.shakeIt = false;
                    btn.y += 27;
                }
            btns.push(btn);
            leInt++;
        }

        no = new FlxText(150, 600, 0, 'No', fntSize);
        no.antialiasing = false;
        no.setFormat(Paths.font("DTM-Mono.ttf"), fntSize, !yn ? FlxColor.YELLOW : FlxColor.WHITE, CENTER);
        no.alpha = 0.00001;
        add(no);

        yes = new FlxText(600, 600, 0, 'Yes', fntSize);
        no.antialiasing = false;
        yes.setFormat(Paths.font("DTM-Mono.ttf"), fntSize, yn ? FlxColor.YELLOW : FlxColor.WHITE, CENTER);
        yes.alpha = 0.00001;
        add(yes);

        super.create();
    }

    var trollTimer:FlxTimer;
    var trollTween:FlxTween;
    var trollTween2:FlxTween;
    override function update(elapsed:Float) {
		nametxt.y = FlxMath.lerp(nametxt.y, ynPhase ? 200 : 60, CoolUtil.boundTo(elapsed * (ynPhase ?0.2:8), 0, 1));
		nametxt.scale.x = FlxMath.lerp(nametxt.scale.x, ynPhase ? 1 : 0.27, CoolUtil.boundTo(elapsed * (ynPhase ?0.2:8), 0, 1));
		nametxt.scale.y = FlxMath.lerp(nametxt.scale.y, ynPhase ? 1 : 0.27, CoolUtil.boundTo(elapsed * (ynPhase ?0.2:8), 0, 1));
        if (ynPhase) nametxt.angle = FlxMath.lerp(nametxt.angle, (Math.sin(FlxG.sound.music.time)*10), CoolUtil.boundTo(elapsed * 9, 0, 1));
        
        if (!ynPhase && !disall) {
            if (controls.UI_UP_P) selecting(-7);
            if (controls.UI_DOWN_P) selecting(7);
            if (controls.UI_LEFT_P) selecting(-1);
            if (controls.UI_RIGHT_P) selecting(1);

            if (FlxG.keys.justPressed.BACKSPACE || controls.BACK) backSpace();
        }
        
        if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && ynPhase && !disall && !locked) updYn();

        if (controls.ACCEPT && ynPhase && !disall) {
            if (yn && !locked) {
                ClientPrefs.data.charName = name;
                ClientPrefs.data.fps = ClientPrefs.data.funVal = FlxG.random.int(0,99);
                
                FlxG.sound.music.volume = 0;
                FlxG.sound.play(Paths.sound('fade_white'));
                yes.alpha = 0;
                no.alpha = 0;
                toptxt.alpha = 0;
                disall = true;
                FlxG.camera.fade(FlxColor.WHITE,5,false, function() {
                    MusicBeatState.switchState(new Freepoop());
                    ClientPrefs.saveSettings();
                });
            } else if (!yn) {
                for (i in btns) i.alpha = 1;
                nametxt.angle = 0;
                yes.alpha = 0.00001;
                yes.acceleration.x = 0;
                yes.acceleration.y = 0;
                yes.setPosition(600,600);
                yes.angle = 0;
                if (trollTimer != null) trollTimer.cancel();
                if (trollTween != null) trollTween.cancel();
                if (trollTween2 != null) trollTween2.cancel();
                no.alpha = 0.00001;
                no.text = "No";
                toptxt.text = 'Name your little shit.';
                ynPhase = false;
            }
        } else if (controls.ACCEPT && !ynPhase && !disall) {
            switch(bts[curSelected]) {
                default:
                    if (6 > name.length)
                    name += bts[curSelected];
                    nametxt.text = name;
                    nametxt.screenCenter(X);
                case 'Backspace':
                    backSpace();
                case 'Quit':
                    FlxG.sound.music.stop();
                    MusicBeatState.switchState(new InstMenu());
                case 'Done':
                    if (name.toLowerCase() == 'exe') {
                        ClientPrefs.data.charName = name;
                        ClientPrefs.saveSettings();
                        FlxG.sound.music.stop();
                        MusicBeatState.switchState(new Freepoop());
                    }

                    yn = false;
                    locked = false;
                    yes.alpha = 1;

                    var afterTxt:String = 'Is this name correct?';
                    for (i in nameOutputs) {
                        if (i[0].contains(name.toLowerCase())) {
                            afterTxt = i[1];
                            if (i[2] != null) {
                            switch (i[2]) {
                                case LOCKED:
                                    locked = true;
                                    no.text = "Go back";
                                    yes.alpha = 0.00001;
                                case CRASH:
                                    #if sys
                                    Sys.exit(0);
                                    #end
                                case HARD:
                                case RAREBLIN:
                                    CoolUtil.browserLoad('https://gamebanana.com/mods/409854');
                                    locked = true;
                                    no.text = "Go back";
                                    yes.alpha = 0.00001;
                                case TROLL:
                                    locked = true;
                                    trollTimer = new FlxTimer().start(0.75, function(tmr:FlxTimer) {
                                        toptxt.text = "Whoops, dropped the 'yes' button.";
                                        FlxG.sound.play(Paths.sound('fall', 'overworld'));
                                        no.text = "Go back";
                                        trollTween2 = FlxTween.tween(yes, {x: yes.x + FlxG.random.int(-20,20), y: 900}, 2, {ease: FlxEase.sineIn});
                                        trollTween = FlxTween.tween(yes, {angle: FlxG.random.int(-20, 20)}, 3);
                                    });
                                default:
                            }
                            }
                        }
                    }
                    ynPhase = true;
                    toptxt.text = afterTxt;   
                    for (i in btns) i.alpha = 0.00001;
                    no.alpha = 1;  
            }
        }
        super.update(elapsed);
    }

    function updYn()
    {
        yn = !yn;
        yes.color = yn ? FlxColor.YELLOW : FlxColor.WHITE;
        no.color = !yn ? FlxColor.YELLOW : FlxColor.WHITE;
    }

    function backSpace()
    {
        name = shorten(name,name.length-1);
        nametxt.text = name;
        nametxt.screenCenter(X);
    }

	function shorten(leText:String,nums:Int)
	{
        var returnVal:String = '';
        for (letterNum in 0...nums)
        {
            returnVal += leText.charAt(letterNum);
        }
		return returnVal;
	}

    function selecting(huh:Int = 0)
    {
        //FlxG.sound.play(Paths.sound('scrollMenu'));
        var gayButton:Bool = true;
        var beforBtn:String = bts[curSelected];
        var beforHuh:Int = huh;
        switch (bts[curSelected])
        {
            case 'Quit' | 'Backspace' | 'Done':
                gayButton = false;
        }
        curSelected += huh;
        if (curSelected >= bts.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = bts.length - 1;
        if (bts[curSelected] == '' && gayButton)
            if (Math.abs(huh) == 1)
                huh = (huh > 0) ? 7 : -7;
            else
                huh = (huh > 0) ? 1 : -1;
        while (bts[curSelected] == '')
        {
            curSelected += huh;
            if (curSelected >= bts.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = bts.length - 1;
        }
        switch (beforBtn)// i hate ddddddddddddddddddddddddddddddddddddddddddddd sorry i fell asleep
        {
            case 'x' | 'y' | 'z':
                if (beforHuh == 7)
                    selectBtnByString('Backspace');
            case 'w':
                if (beforHuh == 7)
                    selectBtnByString('Quit');
        }
        for (i in btns)
        i.color = (i.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
    }

    function selectBtnByString(leStr:String)
    {
        for (i in btns)
        if (i.text == leStr)
        curSelected = i.ID;
    }
}