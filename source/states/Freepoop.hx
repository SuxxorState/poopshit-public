package states;

import backend.*;
import backend.SongData;
import states.editors.MasterEditorMenu;
import substates.ResetScoreSubState;

class Freepoop extends MusicBeatState {
    public static var curSelected:Int = 0;
    public static var curSong:Int = 0;
    var intendedScr:Int = 0;
    var scr:Int = 0;

    var bg:FlxSprite;
    var btns:Array<FlxSprite> = [];
    var nameTxt:FlxText;
    var loveTxt:FlxText;
    var timeTxt:FlxText;
    var songtxt:FlxText;
    var leftTxt:FlxText;
    var rightTxt:FlxText;
    var char:NPC;
    var options:Array<Dynamic> = ['Song','Continue','Reset','Settings','Credits','Trophies'];
    var songs:Array<SongFile> = [];
    var exeMode:Bool = ClientPrefs.data.charName.toLowerCase() == 'exe';
    public static var prevMusic:String = "";
    override function create() {
        #if desktop
		DiscordClient.changePresence("Freeplay Menu", null);
		#end

        PlayState.isStoryMode = false;
        SongData.reloadSongFiles();
        
        if (exeMode && SongData.allSongs.exists('too-far')) songs = [SongData.allSongs.get('too-far')];
        else if (ClientPrefs.data.funVal == 69 && Highscore.getScore('BBG', 0) < 1 && Highscore.getScore('Constipation', 0) < 1) songs = [SongData.allSongs.get('bbg')];
        else {
            var freeLocked:Bool = true;
            for (song in SongData.songList) {
                songs.push(SongData.songsLoaded.get(song));
                if (Highscore.getScore(songs[songs.length - 1].song, 0) >= 1) freeLocked = false;
            }
            if (freeLocked) songs = [SongData.allSongs.get('constipation')];
        }

        bg = new FlxSprite(0, -375).loadGraphic(Paths.image('freeplayOW/room-' + songs[0].bgVariant));
        bg.setGraphicSize(Std.int(bg.width * 3));
        bg.updateHitbox();
        bg.screenCenter(X);
        bg.antialiasing = false;
		add(bg);

        char = new NPC(songs[0].songChar[0], 470, 440);
        char.playAnim(songs[0].songChar[1]);
        char.setGraphicSize(char.width * 3);
        add(char);

        nameTxt = new FlxText(270, 150, 0, songs[0].playerName != null && songs[0].playerName != '' ? songs[0].playerName : ClientPrefs.data.charName, 32);
        nameTxt.antialiasing = false;
        nameTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(nameTxt);  

        loveTxt = new FlxText(0, 150, 0, 'LV ${songs[0].level}', 32);
        loveTxt.antialiasing = false;
        loveTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        loveTxt.screenCenter(X);
        add(loveTxt);  

        timeTxt = new FlxText(610, 150, 0, "0", 32);
        timeTxt.antialiasing = false;
        timeTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(timeTxt);  

        var prevwidth:Float = 0;
        for (i in 0...options.length) {
            if (options[i] == 'Trophies') {
                var tph:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplayOW/sansTrophy'), true, 16,26);
                tph.animation.add('idle', [0]);
                tph.animation.add('selected', [1]);
                tph.animation.play(curSelected == 5 ? 'selected' : 'idle');
                tph.setGraphicSize(48);
                tph.updateHitbox();
                tph.setPosition(FlxG.width - (tph.width + 30), FlxG.height - (tph.height + 30));
                add(tph);
                btns.push(tph);
                tph.ID = i;
            } else if (options[i] != 'Song') {
                var btn:FlxText = new FlxText(300+(i % 2 != 1 ? 36 : 0), 280+(i > 2 ? 36 : 0), 0, options[i], 32);
                if (i % 2 != 1) btn.x += prevwidth + 20;
                btn.antialiasing = false;
                btn.setFormat(Paths.font("DTM-Mono.ttf"), 32, (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                btn.ID = i;
                add(btn);
                btns.push(btn);
                prevwidth = btn.width;
            }
        }

        songtxt = new FlxText(0, 200, 0, songs[0].song, 32);
        songtxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, (options[curSelected] == 'Song') ? FlxColor.YELLOW : FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songtxt.updateHitbox();
        songtxt.screenCenter(X);
        songtxt.antialiasing = false;
        add(songtxt);  

        leftTxt = new FlxText(0, 200, 0, "<", 32);
        leftTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        leftTxt.updateHitbox();
        leftTxt.screenCenter(X);
        leftTxt.x -= (songtxt.width / 2) + 20;
        leftTxt.visible = songs.length > 1;
        leftTxt.antialiasing = false;
        add(leftTxt); 

        rightTxt = new FlxText(0, 200, 0, ">", 32);
        rightTxt.setFormat(Paths.font("DTM-Mono.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        rightTxt.updateHitbox();
        rightTxt.screenCenter(X);
        rightTxt.x += (songtxt.width / 2) + 20;
        rightTxt.visible = songs.length > 1;
        rightTxt.antialiasing = false;
        add(rightTxt); 
        
        var uSuck:FlxText = new FlxText(0, 525, 0, InstMenu.copyright, 18);
        uSuck.setFormat(Paths.font("undertale-crypt-of-tommorow.ttf"), 18, FlxColor.WHITE, LEFT);
        uSuck.screenCenter(X);
        uSuck.antialiasing = false;
        uSuck.alpha = 0.5;
        uSuck.y = FlxG.height - uSuck.height - 7.5;
        add(uSuck);

        Trophies.loadTrophies();
		if (ClientPrefs.data.charName != '' && !Trophies.getTrophyStats('baptism', UNLOCKED)) {
            new FlxTimer().start(0.5, function(Tmr:FlxTimer) {
                Trophies.unlockTrophy('baptism');
                add(new TrophyPopup('baptism'));
            });
		}

        if (!Trophies.getTrophyStats('everything', UNLOCKED)) {
            var giveTroph:Bool = true;
            for (i in 0...Trophies.trophyStuff.length - 1) {
                var tromph = Trophies.trophyStuff[i];
                if (!Trophies.getTrophyStats(tromph[3], UNLOCKED)) giveTroph = false;
                //trace(tromph[0] + ' ' + Trophies.getTrophyStats(tromph[3], UNLOCKED));
            }
            if (giveTroph) {
                new FlxTimer().start(0.5, function(Tmr:FlxTimer) {
                    Trophies.unlockTrophy('everything');
                    add(new TrophyPopup('everything'));
                });
            }
        }

        super.create();
        
        weeking();
    }

    override function closeSubState() {
        intendedScr = Highscore.getScore(songs[curSong].song, 0);
        songtxt.alpha = (Highscore.getScore(songs[curSong].song, 0) < 1 && songs[curSong].overworld != '') ? 0.6 : 1;
        btns[0].alpha = (songs[curSong].overworld == '') ? 0.6 : 1;
        super.closeSubState();
    }
    
    override function update(elapsed:Float) {
        scr = Math.floor(FlxMath.lerp(scr, intendedScr, FlxMath.bound(elapsed * 18, 0, 1)));
		if (Math.abs(scr - intendedScr) <= 10) scr = intendedScr;
        timeTxt.text = '$scr';

        if (!controls.UI_LEFT && leftTxt.color != FlxColor.WHITE)
            leftTxt.color = FlxColor.WHITE;
        if (!controls.UI_RIGHT && rightTxt.color != FlxColor.WHITE)
            rightTxt.color = FlxColor.WHITE;
        if (options[curSelected] == 'Song') {
            if (songs.length > 1) {
            if (controls.UI_LEFT && leftTxt.color != FlxColor.YELLOW)
                leftTxt.color = FlxColor.YELLOW;
            if (controls.UI_RIGHT && rightTxt.color != FlxColor.YELLOW)
                rightTxt.color = FlxColor.YELLOW;
            if (controls.UI_LEFT_P) weeking(-1);
            if (controls.UI_RIGHT_P) weeking(1);
            }
        } else {
            if (controls.UI_LEFT_P) selecting('Left');
            if (controls.UI_RIGHT_P) selecting('Right');     
        }
        if (controls.UI_UP_P) selecting('Up');
        if (controls.UI_DOWN_P) selecting('Down');

        if (controls.RESET) {
            persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSong].song, songs[curSong].songChar, songs[curSong].charOffsets));
        } else if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('confirm'));
            new FlxTimer().start(0.2, function(tmr:FlxTimer) {
            switch (options[curSelected]) {
                case 'Song':
                    if (Highscore.getScore(songs[curSong].song, 0) >= 1 || songs[curSong].overworld == '') {
                        FlxG.sound.music.stop();
                        CoolUtil.reloadHP(songs[curSong].level, true);
                        PlayState.SONG = Song.loadFromJson(Paths.formatToSongPath(songs[curSong].song), Paths.formatToSongPath(songs[curSong].song));
                        LoadingState.loadAndSwitchState(new PlayState());
                        prevMusic = '';
                    }
                case 'Continue':
                    if (songs[curSong].overworld != '') {
                        FlxG.sound.music.stop();
                        CoolUtil.reloadHP(songs[curSong].level, true);
                        MusicBeatState.switchState(new Overworld());
                        Overworld.map = songs[curSong].overworld;
                        prevMusic = '';
                    }
                case 'Reset':
                    FlxG.sound.music.stop();
                    //ClientPrefs.resetPrefs();
                    ClientPrefs.data.charName = '';
                    LoadingState.loadAndSwitchState(new Upon());
                    prevMusic = '';
                case 'Settings': 
                    MusicBeatState.whatTransition = "settings";
                    MusicBeatState.doTransition = true;
                    LoadingState.loadAndSwitchState(new options.OptionsState());
                    prevMusic = '';
                case 'Credits': MusicBeatState.switchState(new Undercreds());
                case 'Trophies': MusicBeatState.switchState(new TrophyRoom());
            }
            }, 1);
        }
        /*#if desktop
        else if (controls.justPressed('debug_1')) {
            MusicBeatState.switchState(new MasterEditorMenu());
        }
        #end*/
        super.update(elapsed);
    }
    
    function selecting(huh:String = '') {
        switch (huh) {
            case 'Left' | 'Right':
                if (curSelected % 2 == 1 && curSelected != 5)
                    curSelected++;
                else
                    curSelected--;
            case 'Down':
                if (curSelected == 0)
                    curSelected++;
                else if (curSelected == 5)
                    curSelected = 0;
                else if (curSelected > 2)
                    curSelected = 5;
                else 
                    curSelected += 2;
            case 'Up':
                if (curSelected == 0)
                    curSelected = 7;
                if (curSelected == 1 || curSelected == 2)
                    curSelected = 0;
                else
                    curSelected -= 2;
            default:
        }

        FlxG.sound.play(Paths.sound('select'));

        for (i in btns) {
            if (i.ID == 5) i.animation.play((i.ID == curSelected) ? 'selected' : 'idle');
            else i.color = (i.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
        }

        songtxt.color = curSelected == 0 ? FlxColor.YELLOW : FlxColor.WHITE;
    }

    function weeking(huh:Int = 0) {
        FlxG.sound.play(Paths.sound('select'));

        curSong += huh;

        if (curSong >= songs.length) curSong = 0;
        if (curSong < 0) curSong = songs.length - 1;
                
        if (prevMusic == '' && (!FlxG.sound.music.playing || FlxG.sound.music == null)) {
            FlxG.sound.playMusic(Paths.music(songs[curSong].bgMusic));
            prevMusic = songs[curSong].bgMusic;
        } else if (songs[curSong].bgMusic != prevMusic) {
            FlxG.sound.music.fadeOut(0.5 * (prevMusic == "" ? 0.01 : 1), 0, function(twn:FlxTween) {
                FlxG.sound.music.stop();
                FlxG.sound.playMusic(Paths.music(songs[curSong].bgMusic), 0);
                FlxG.sound.music.fadeIn(0.5 * (prevMusic == "" ? 0.01 : 1), 0,1);
            });
            prevMusic = songs[curSong].bgMusic;
        } else if (FlxG.sound.music.volume < 1) FlxG.sound.music.fadeIn(0.5 * (1 - FlxG.sound.music.volume), FlxG.sound.music.volume,1);

        songtxt.text = songs[curSong].song;
        
        songtxt.alpha = (Highscore.getScore(songs[curSong].song, 0) < 1 && songs[curSong].overworld != '') ? 0.6 : 1;
        btns[0].alpha = (songs[curSong].overworld == '') ? 0.6 : 1;

        loveTxt.text = 'LV ${songs[curSong].level}';
        intendedScr = Highscore.getScore(songs[curSong].song, 0);
        songtxt.updateHitbox();
        songtxt.screenCenter(X);
        nameTxt.text = songs[curSong].playerName != null && songs[curSong].playerName != '' ? songs[curSong].playerName : ClientPrefs.data.charName;
        leftTxt.screenCenter(X);
        leftTxt.x -= (songtxt.width / 2) + 20;
        rightTxt.screenCenter(X);
        rightTxt.x += (songtxt.width / 2) + 20;
        char.current = songs[curSong].songChar[0];
        char.playAnim(songs[curSong].songChar[1]);

        bg.loadGraphic(Paths.image('freeplayOW/room-' + songs[curSong].bgVariant));
        bg.setGraphicSize(Std.int(bg.width * 3));
        bg.updateHitbox();
        bg.screenCenter(X);
        bg.antialiasing = false;
    }
}