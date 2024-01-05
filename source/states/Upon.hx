package states;

using StringTools;

class Upon extends MusicBeatState {

	var shitDia:Array<String> = [
        'My nuts itch',
        'Sussy Balls',
        'Many years later, Something cool happened...',
        'I don\'t remember',
        'Not Associated With Newgrounds or Toby Fox',
        '',
        'Kinda looks like a tiddie lmfao',
        'what the actual fuck ',
        'man this place sucks',
        ':Trollface:',
        'gok',
        '',
        ''
	];
    var curCard:Int = 0;
    var cards:Array<FlxSprite> = [];
    var nar:UTTypeText;

    override function create() {       
        if (!CoolUtil.initialized) CoolUtil.initialize();
        
        #if desktop
        DiscordClient.changePresence("In The Menus", null);
        #end

        FlxG.sound.playMusic(Paths.music('Some Time Ago'));
        for (i in 1...shitDia.length)
        {
            var panel:FlxSprite;
            if (i == 3 || i == 6)
                panel = new FlxSprite(180, 84).makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2), FlxColor.BLACK);
            else
                panel = new FlxSprite(180, 84).loadGraphic(Paths.image('upon/Panel$i'));
            panel.alpha = (i == 1)? 1 : 0;
            panel.setGraphicSize(Std.int((panel.width * 2 * 1.5)));
            panel.updateHitbox();
            panel.antialiasing = false;
            panel.ID = i - 1;
            add(panel);
            cards.push(panel);
        }

        var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('upon/stupidoverlay'));
        overlay.setGraphicSize(Std.int((overlay.width * 2) * 1.5));
        overlay.updateHitbox();
        overlay.alpha = 0;
        add(overlay);

        nar = new UTTypeText(173, 477, 660, '', "DTM-Mono.ttf", 42);
        add(nar);
        nar.resetText(shitDia[curCard]);
        nar.start(0.07, true);

        new FlxTimer().start(5, function(tmr:FlxTimer) {
        new FlxTimer().start(curCard == 11 ? 6 : 0, function(tmr:FlxTimer) {
            curCard++;
            if (cards[curCard] == null) {
                if(FlxG.sound.music != null) FlxG.sound.music.stop();
                MusicBeatState.switchState(new InstMenu());
            } else
            for (i in cards)
            {
                FlxTween.tween(i, {alpha: 0}, tmr.elapsedLoops == 0 ? 0 : 0.7, {onComplete: 
                    function(twn:FlxTween)
                    {
                        if (i.ID == curCard) {
                            FlxTween.tween(i, {alpha: 1}, tmr.elapsedLoops == 0 ? 0 : 0.7);
                            if (i.ID == 11) {
                                overlay.alpha = 1;
                                new FlxTimer().start(2, function(tmr:FlxTimer) {
                                    FlxTween.tween(i, {y: i.y - Std.int(470 * 1.5)}, 6);
                                });
                            }
                        }
                    }
                });
            }
            nar.resetText(shitDia[curCard]);
            new FlxTimer().start(0.7, function(tmr:FlxTimer) {
                nar.start(0.07, true);
            },1);
        },1);
        },0);

        var theblack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(theblack);
        FlxTween.tween(theblack, {alpha: 1}, 0.25, {onComplete: function(twn:FlxTween) {remove(theblack);}});
        

        super.create();
    }

    var shit:Bool = false;
    override function update(elapsed:Float) {
        if (controls.ACCEPT && !shit) {
            shit = true;
            FlxG.sound.music.fadeOut(1,0);
            FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
                if(FlxG.sound.music != null) FlxG.sound.music.stop();
                MusicBeatState.switchState(new InstMenu());
            });
        }

        super.update(elapsed);
    }
}