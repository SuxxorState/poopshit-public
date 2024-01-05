package states;

import backend.InputFormatter;

class InstMenu extends MusicBeatState {
    public static var gameLaunched:Bool = false;
    public static var creditsMode:Bool = false;
    var logo:FlxSprite;
    var whatToDo:FlxText;
    var uSuck:FlxText;
    public static var copyright:String = 'POOPSHITTERS V0.91 (C) FIREATWHIRE 2013';
    override function create() {
        #if desktop
		DiscordClient.changePresence("In The Menus", null);
		#end
        whatToDo = new FlxText(225, 60, 0, '--- Instruction ---\n\n[${getKeyByName('accept')}] - Confirm\n[${getKeyByName('back')}] - Cancel\n[${getKeyByName('menu')}] - Menu (In-game)\n[${getKeyByName('dia_next')}] - Dialogue Next\n[${getKeyByName('dia_skip')}] - Dialogue Skip\n[F4] - Fullscreen\n[Hold ESC] - Quit\nWhen you kys, you die.', 48);
        whatToDo.setFormat(Paths.font("8bitoperator_jve.ttf"), 48, FlxColor.WHITE, LEFT);
        whatToDo.alpha = gameLaunched ? 0.8 : 0.00001;
        whatToDo.antialiasing = false;
        add(whatToDo);

        uSuck = new FlxText(0, 525, 0, '[PRESS ${getKeyByName('accept')}]', 18);
        uSuck.setFormat(Paths.font("undertale-crypt-of-tommorow.ttf"), 18, FlxColor.WHITE, LEFT);
        uSuck.screenCenter(X);
        uSuck.antialiasing = false;
        uSuck.alpha = 0;
        add(uSuck);

        if (!gameLaunched)
        {
            FlxG.sound.play(Paths.sound('logo_appear'));

            logo = new FlxSprite().loadGraphic(Paths.image('logo'));
            logo.antialiasing = false;
            logo.setGraphicSize(Std.int(logo.width * 1.5));
            logo.updateHitbox();
            logo.screenCenter();
            add(logo);

            if (creditsMode) {
                new FlxTimer().start(4, function(tmr:FlxTimer) {
                    FlxG.sound.play(Paths.sound('logo_appear'));
                    logo.visible = false;
                    new FlxTimer().start(4, function(tmr:FlxTimer) {
                        creditsMode = false;
                        MusicBeatState.switchState(new Undercreds());
                        FlxG.sound.playMusic(Paths.music('PoopshittersMainMenu'));
                        Freepoop.prevMusic = 'PoopshittersMainMenu';
                    });
                });
            } else {
                new FlxTimer().start(3, function(tmr:FlxTimer) {
                    uSuck.alpha = 0.5;
                });   
            }
        } else {
            uSuck.alpha = 0.5;
            uSuck.text = copyright;
            uSuck.screenCenter(X);
            uSuck.y = FlxG.height - uSuck.height - 7.5;
        }

        super.create();
    }
    
    function getKeyByName(leStr:String):String {
        var length:String = InputFormatter.getKeyName(ClientPrefs.keyBinds.get(leStr)[0]).toUpperCase();
        var width:String = InputFormatter.getKeyName(ClientPrefs.keyBinds.get(leStr)[1]).toUpperCase();
        var height:String = '';
        if (length.length < 1 || length == null || length == '---') height = width;
        else if (width.length < 1 || width == null || width == '---') height = length;
        else height = length + ' or ' + width;

        return height;
    }

    override function update(elapsed:Float) {
        if (!creditsMode) {
            if (ClientPrefs.data.charName == '') {
                if (controls.ACCEPT && !gameLaunched)
                {
                    remove(logo);
                    uSuck.alpha = 0.5;
                    uSuck.text = copyright;
                    uSuck.screenCenter(X);
                    uSuck.y = FlxG.height - uSuck.height - 7.5;
                    whatToDo.alpha = 0.7;
                    gameLaunched = true;
                }
                else if (controls.ACCEPT && gameLaunched) {
                    gameLaunched = false;
                    MusicBeatState.switchState(new NameYourLittleShit());    
                }
            } else if (controls.ACCEPT) {
                MusicBeatState.switchState(new Freepoop());
            }
        }
        super.update(elapsed);
    }
}