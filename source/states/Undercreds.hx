package states;

class Undercreds extends MusicBeatState {
    public static var curSel:Int = 0;
    var quitting:Bool = false;
	var holdTime:Float = 0;
    var stupid:Array<Array<String>> = [ //Name - description - link
        ['FireAtWhire',		'Created and Directed this stupid ass mod, voiced poopshitter n peepisser, charted some songs, edited a bunch of shit',					        'https://twitter.com/FireAtWhire'],
        ['George',		    'Co-Directed the mod, one of the artists for sexy sans and pause sans , composed main menu songs, made pause song for papyrus',					'https://twitter.com/george_d6d6d7a6'],
        ['SnowmanJoe',		'Literally just the animated torso part of pause menu sans',					                                                                'https://twitter.com/SnowmanJoe_'],
        ['Savour',		    'Composted Constipation and Summer Settings',					                                                                                'https://twitter.com/savour_official'],
        ['Doguy',		    'Composed Kidney Stones, BBG, Remixed most of the sound test songs, made pause song for sans',					                                'https://twitter.com/Doguy_D'],
        ['Vruzzen',		    'Composted Eggster, Quandale Dingle sound test song, made pause song for gaster',					                                            'https://twitter.com/razmusician_'],
        ['SuxxorState',	    'Programmer',							                                                                                                        'https://www.youtube.com/watch?v=Y0jjTnrDCXY&ab_channel=SimGretina'],
        ['Kofv',		    'Sprites for 1st phase sexy sans, the gf hands in sexy sans and first sprite of gaster',					                                    'https://twitter.com/kofvyumi'],
        ['Ray',		        'Sprites for Gangster Gaster (so cool)',					                                                                                    'https://twitter.com/Ray_Ray478'],
        ['Sodapop',		    'all the overworld sprites (not bgs pls dont copyright)',					                                                                    'https://twitter.com/cherryF1zzz'],
        ['Julio',		    'Most sprites in songs (poopshitters, peepissers, eggster)',					                                                                'https://twitter.com/ImJulioX'],
        ['Jay',		        'icons for bf n gf thats it lmao',					                                                                                            'https://twitter.com/JJjaythecoil'],
        ['Vanilla',		    'Made the normal and christmas boyfriend sprites (quite smelly)',					                                                            'https://twitter.com/Vanillanomas'],
        ['Brick',		    'Promo art (quite awesome)',					                                                                                                'https://twitter.com/ABrickToTheHead'],
        ['Croomie',		    'Background for constipation lmao',					                                                                                            'https://twitter.com/Croomie4'],
        ['Piggy',		    'background artist for papyrus and gaster',					                                                                                    'https://twitter.com/piggyfriend1792'],       
        ['4Axion',		    'Former programmer (left the code they had when they left)',					                                                                        ''],
        ['AprilTheCoder',   'Ported shaders',					                                                                                                            ''],
    ]; 
    var titleTxt:FlxText;
    var devImage:FlxSprite;
    var descTxt:FlxText;
    var leftArrow:FlxText;
    var rightArrow:FlxText;
    
    override function create() {
        #if desktop
		DiscordClient.changePresence("Credits", null);
		#end
        devImage = new FlxSprite().loadGraphic(Paths.image('credits/' + stupid[curSel][0]));
        devImage.setGraphicSize(300, 300);
        devImage.updateHitbox();
        devImage.screenCenter();
        devImage.y -= 50;
		add(devImage);

        titleTxt = new FlxText(50, 0, 940, stupid[curSel][0], 44);
		titleTxt.setFormat(Paths.font("monster-friend-back-pro.ttf"), 44, FlxColor.WHITE, CENTER);
        titleTxt.y = titleTxt.height - 70;
        titleTxt.screenCenter(X);
        titleTxt.antialiasing = false;
		add(titleTxt);

		descTxt = new FlxText(50, 0, 920, stupid[curSel][1], 32);
		descTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER);
        descTxt.y = FlxG.height - descTxt.height - 30;
        descTxt.screenCenter(X);
        descTxt.antialiasing = false;
		add(descTxt);

        leftArrow = new FlxText(0, 0, 0, "<", 128);
		leftArrow.setFormat(Paths.font("DTM-Mono.ttf"), 128, FlxColor.WHITE, CENTER);
        leftArrow.screenCenter();
        leftArrow.x -= 240;
        leftArrow.y -= 55;
        leftArrow.antialiasing = false;
		add(leftArrow);

        rightArrow = new FlxText(0, 0, 0, ">", 128);
		rightArrow.setFormat(Paths.font("DTM-Mono.ttf"), 128, FlxColor.WHITE, CENTER);
        rightArrow.screenCenter();
        rightArrow.x += 240;
        rightArrow.y -= 55;
        rightArrow.antialiasing = false;
		add(rightArrow);

        changeSelection();
        super.create();
    }

    override public function update(elapsed:Float) {
        if(!quitting) {
            if (controls.UI_LEFT && leftArrow.color != FlxColor.YELLOW)
                leftArrow.color = FlxColor.YELLOW;
            else if (!controls.UI_LEFT && leftArrow.color != FlxColor.WHITE)
                leftArrow.color = FlxColor.WHITE;
            if (controls.UI_RIGHT && rightArrow.color != FlxColor.YELLOW)
                rightArrow.color = FlxColor.YELLOW;
            else if (!controls.UI_RIGHT && rightArrow.color != FlxColor.WHITE)
                rightArrow.color = FlxColor.WHITE;

            if(stupid.length > 1) {
                var shiftMult:Int = 1;
                if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

                var upP = controls.UI_LEFT_P;
                var downP = controls.UI_RIGHT_P;

                if (upP) {
                    changeSelection(-shiftMult);
                    holdTime = 0;
                }
                if (downP) {
                    changeSelection(shiftMult);
                    holdTime = 0;
                }

                if(controls.UI_LEFT || controls.UI_RIGHT) {
                    var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                    holdTime += elapsed;
                    var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

                    if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                    {
                        changeSelection((checkNewHold - checkLastHold) * (controls.UI_RIGHT ? -shiftMult : shiftMult));
                    }
                }
            }

            if(controls.ACCEPT && stupid[curSel][2] != '' && (stupid[curSel][2] == null || stupid[curSel][2].length > 4)) {
                CoolUtil.browserLoad(stupid[curSel][2]);
            }
            if (controls.BACK) {
                //FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new Freepoop());
                quitting = true;
            }
        }
        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
        FlxG.sound.play(Paths.sound('select'));
        curSel += change;
        if (curSel < 0)
            curSel = stupid.length - 1;
        if (curSel >= stupid.length)
            curSel = 0;

        titleTxt.text = stupid[curSel][0];
        titleTxt.y = titleTxt.height - 70;

        descTxt.text = stupid[curSel][1];
        descTxt.y = FlxG.height - descTxt.height - (30 + (descTxt.height < 50 ? 20 : 0));

        remove(devImage);
        devImage = new FlxSprite().loadGraphic(Paths.image('credits/' + stupid[curSel][0]));
        devImage.setGraphicSize(300, 300);
        devImage.updateHitbox();
        devImage.screenCenter();
        devImage.y -= 50;
        add(devImage);
    }
}