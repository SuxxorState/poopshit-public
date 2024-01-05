package states;

import objects.*;
import flixel.util.FlxSort;
import backend.Song;
import backend.Dialogue;
import substates.InventoryMenu;
import objects.TrophyPopup;
import backend.SongData;

using StringTools;

class Overworld extends MusicBeatState {
    public static var nextmap:String = '';
    public static var map:String = 'Last Corridor';
    var worldData:Array<String>;
    var player:Player;
    static var playerH:PlayerHitbox;
    static var colHitbox:FlxSprite;
    static var bounds:FlxSpriteGroup;
    var fakeDiaBox:FlxSprite;
    var diaBox:DialogueBox;
    var canDeleteBox:Bool = false;
    var theDiaTimer:FlxTimer;
    var campoint:FlxSprite;
    var bg:FlxSprite;
    public static var fled:Bool = false;
    public static var fromSong:Bool = false;
    public static var startMult:Int = 0;
    var shitter:NPC;
    var eatCone:Bool = false;
    var characters:FlxTypedGroup<FlxSprite>;
    var songLoading = false;

	public var camGame:FlxCamera;
    public var camHUD:FlxCamera;
    var notStartedYet:Bool = true;
    var escapeTxt:FlxText;
    var escTween:FlxTween;

    var finishsoul:Soul;

    override function create() {
        if (nextmap != '') {
            map = nextmap;
            nextmap = '';
        }
        #if desktop
		DiscordClient.changePresence("Overworld - " + map, null);
		#end

        camGame = new FlxCamera();
		camHUD = new FlxCamera();

        camHUD.bgColor.alpha = 0;
        
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
        
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

        this.persistentUpdate = true;
        PlayState.isStoryMode = true;

        loadMap();
        FlxG.camera.zoom = 3;
        super.create();
        
        escapeTxt = new FlxText(10,10,0, 'Quitting', 48);
        escapeTxt.setFormat('Mars Needs Cunnilingus', 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        escapeTxt.borderSize = 3;
        escapeTxt.alpha = 0;
        escapeTxt.cameras = [camHUD];
        escapeTxt.antialiasing = false;
        add(escapeTxt);

        doneFunValues.set('dttb', ClientPrefs.data.funVal == 0);
        for (i in 0...Trophies.trophyStuff.length - 1) {
            var tromph = Trophies.trophyStuff[i];
            if (tromph[3] == 'down-to-the-bone_fc') continue;
            if (!Trophies.getTrophyStats(tromph[3], UNLOCKED)) doneFunValues.set('dttb', false);
        }
    }

    var escapeTimer:FlxTimer;
    var quittingTimer:FlxTimer;
    var leave:Bool = false;

    public static var completedSongs:Map<String, Bool> = [];
    public static var doneFunValues:Map<String, Bool> = [];

    override function update(elapsed:Float) {
        if (!songLoading) {
            if (player.movingVer) {   
                var sortbyyheight = function(Order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int{
                    return FlxSort.byValues(Order, Obj1.y + Obj1.height, Obj2.y + Obj2.height);
                }

                characters.sort(sortbyyheight, FlxSort.ASCENDING);
            }

            switch (map) {
                case 'Throne Hallway':  
                    if (!player.inCutscene) {
                        campoint.x = player.x + (player.width / 2);
                        if (player.y < 530) campoint.y = player.y + (player.height / 2);
                        else campoint.y = bg.height - 125;

                        if ((controls.ACCEPT || controls.DIA_NEXT) && player.y <= 102 && player.curDir == 2) {
                            if (player.x > 125 && player.x < 175) {
                                player.inCutscene = true;
                                diaBox = new DialogueBox(Dialogue.get(map, INTERACT, 0), {player: player, onComplete: function() {
                                    player.idle();
                                    player.inCutscene = false;
                                }});
                                diaBox.cameras = [camHUD];
                                insert(0, diaBox);
                            } else if (player.x > 260 && player.x < 275) {
                                player.inCutscene = true;
                                diaBox = new DialogueBox(Dialogue.get(map, INTERACT, 1), {player: player, onComplete: function() {
                                    player.idle();
                                    player.inCutscene = false;
                                }});
                                diaBox.cameras = [camHUD];
                                insert(0, diaBox);
                            }
                        } else if (player.y < 200 && !doneEvent('dttb')) {
                            player.inCutscene = true;

                            var lenum:Null<Int> = null;
                            if (CoolUtil.checkFUNRange(9,20)) lenum = 0;
                            else if (CoolUtil.checkFUNRange(48,56)) lenum = 1;
                            else if (CoolUtil.checkFUNRange(58,64)) lenum = 2;
                        
                            diaBox = new DialogueBox(Dialogue.get(map, lenum != null ? FUN : REGULAR, lenum), {player: player, phoneCall: true, boxPos: BOTTOM, onComplete: function() {
                                var explosion:FlxSprite = new FlxSprite().loadGraphic(Paths.image('explosion', 'overworld'), true, 71, 100);
                                explosion.setPosition(player.x + ((player.width - explosion.width) / 2), player.y + ((player.height - explosion.height) / 2));
                                explosion.animation.add('yeah', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17], 12, false);
                                add(explosion);
                                FlxG.sound.play(Paths.sound('bad_explosion', 'overworld'));
                                explosion.animation.play('yeah');
                                new FlxTimer().start(1, function(tmr:FlxTimer){
                                    completedSongs.clear();
                                    fled = false;
                                    InstMenu.creditsMode = true;
                                    MusicBeatState.switchState(new InstMenu());
                                });
                            }});
                            diaBox.cameras = [camHUD];
                            insert(0, diaBox);
                        }

                        if (player.y >= 640 && player.curDir == 1) {
                            if (player.x < 100) {
                                startMult = 1;
                                nextRoom('Last Corridor');
                            } else if (player.x > 500) {
                                if (doneEvent('dttb'))
                                    loadSong('down-to-the-bone');
                                //else
                            }
                        }
                    }
                case 'Gaster Room':
                    if (colHitbox.overlaps(shitter) && controls.ACCEPT && !player.inInv) {
                        songLoading = true;
                        shitter.playAnim('disappear');
                        FlxG.sound.play(Paths.sound('mystery_go', 'overworld'));
                        new FlxTimer().start(1, function(tme:FlxTimer) {
                            loadSong('eggster');
                        });
                    }
                    if ((player.y >= 208 && player.curDir == 1)) {nextRoom('Last Corridor');}

                case 'Last Corridor':
                    if (player.x > 50 && player.x < bg.width - 10 && !player.inCutscene) campoint.x = player.x + (player.width / 2);
                    if (!player.inCutscene) {
                        if (player.x > 1000 && player.y <= 99) {
                            nextRoom('Throne Hallway'); 
                        } else if (player.x < 100 && player.y <= 99 && CoolUtil.checkFUNRange(65,66)) {
                            if (ClientPrefs.data.funVal == 66) {nextRoom('Gaster Room');
                            } else {
                                if(FlxG.sound.music != null) FlxG.sound.music.stop();
                                MusicBeatState.switchState(new SoundTest());
                            }
                        }

                        if (fromSong && !doneSong('constipation') && (diaBox == null || !diaBox.exists)) {
                            player.inCutscene = true;
                            player.x -= 2;
                            campoint.x = 800;
                            diaBox = new DialogueBox(Dialogue.get(map, COMPLETE), {player: player, onComplete: function() {
                                completedSongs.set('constipation', true);
                                player.idle();
                                FlxTween.tween(campoint, {x: player.x + (player.width / 2)}, 2, {onComplete: function(twn:FlxTween) {player.inCutscene = false;}});
                            }});
                            diaBox.cameras = [camHUD];
                            insert(0, diaBox);
                        } else if (fled && (diaBox == null || !diaBox.exists) && !doneEvent('fleeShit')) {
                            player.inCutscene = true;
                            player.x -= 2;
                            campoint.x = 800;
                            diaBox = new DialogueBox(Dialogue.get(map, FLEE, 0), {player: player, onComplete: function() {
                                doneFunValues.set('fleeShit', true);
                                player.idle();
                                FlxTween.tween(campoint, {x: player.x + (player.width / 2)}, 1, {onComplete: function(twn:FlxTween) {player.inCutscene = false;}});
                            }});
                            diaBox.cameras = [camHUD];
                            insert(0, diaBox);
                        } else if (player.x > 500 && ClientPrefs.data.funVal == 30 && !doneEvent('whireCall')) {
                            player.inCutscene = true;
                            diaBox = new DialogueBox(Dialogue.get(map, FUN, 0), {phoneCall: true, player: player, onComplete: function() {
                                player.idle();
                                player.inCutscene = false;
                                doneFunValues.set('whireCall', true);
                            }});
                            diaBox.cameras = [camHUD];
                            insert(0, diaBox);
                        } else if (player.x > 697 && !doneSong('constipation')) {
                            player.inCutscene = true;
                            new FlxTimer().start(1, function(tmr:FlxTimer) {
                                FlxTween.tween(campoint, {x: 800}, PlayState.deathCounter > 0 || fled ? 1 : 2, {onComplete: function(twn:FlxTween) {
                                    if (player.y < 120 && !doneEvent('behindJudgePillar')) {
                                        diaBox = new DialogueBox(Dialogue.get(map, FUN, 5), {player: player, onComplete: function() {
                                            doneFunValues.set('behindJudgePillar', true);
                                            loadSong('constipation');
                                        }});
                                    } else if (CoolUtil.checkFUNRange(9,20) && !doneEvent('sansCone')) {
                                        diaBox = new DialogueBox(Dialogue.get(map, FUN, 3), {onNextDia: function() {
                                            if (diaBox.curLmao == 2) {
                                                if(FlxG.sound.music != null) FlxG.sound.music.stop();
                                                shitter.color = FlxColor.WHITE;
                                                shitter.playAnim('icecream');
                                                shitter.animation.pause();
                                            }
                                        }, onComplete: function() {
                                            eatCone = true;
                                            Conductor.changeBPM(80);
                                            FlxG.sound.playMusic(Paths.music('Ice_Cream', 'overworld'));
                                            shitter.animation.curAnim.curFrame = 3;
                                        }});
                                    } else if (CoolUtil.checkFUNRange(48,56) && !doneEvent('noSans')) {
                                        diaBox = new DialogueBox(Dialogue.get(map, FUN, 2), {phoneCall: true, player: player, onComplete: function() {
                                            completedSongs.set('constipation', true);
                                            doneFunValues.set('noSans', true);
                                            player.idle();
                                            FlxTween.tween(campoint, {x: player.x + (player.width / 2)}, 2, {onComplete: function(twn:FlxTween) {
                                                player.inCutscene = false;
                                                doTrophyShit('unlucky');
                                            }});
                                        }});
                                    } else if (CoolUtil.checkFUNRange(58,64) && !doneEvent('nutScratch')) {
                                        diaBox = new DialogueBox(Dialogue.get(map, FUN, 1), {player: player, onComplete: function() {
                                            if (!diaBox.curChoice) {
                                                completedSongs.set('constipation', true);
                                                player.idle();
                                                FlxTween.tween(campoint, {x: player.x + (player.width / 2)}, 2, {onComplete: function(twn:FlxTween) {
                                                    player.inCutscene = false;
                                                    doTrophyShit('nut_scratch');
                                                }});
                                            } else loadSong('constipation');
                                            doneFunValues.set('nutScratch', true);
                                        }});
                                    } else if (fled)
                                        diaBox = new DialogueBox(Dialogue.get(map, FLEE, 1), {player: player, onComplete: function() {
                                            fled = false;
                                            doneFunValues.set('fleeShit', false);
                                            loadSong('constipation');
                                        }});
                                    else if (PlayState.deathCounter >= 1) 
                                        diaBox = new DialogueBox(Dialogue.get(map, DEATH, PlayState.deathCounter - 1), {player: player, onComplete: function() {loadSong('constipation');}});   
                                    else 
                                        diaBox = new DialogueBox(Dialogue.get(map, REGULAR), {player: player, onComplete: function() {loadSong('constipation');}});   
                                    
                                    diaBox.cameras = [camHUD];
                                    insert(0, diaBox);
                                }});
                            });
                        }
                    }
                    
                    if ((fled || doneSong('constipation')) && campoint.x < 745 && shitter.y != -100) shitter.y = -100;
                    else if (campoint.x > 745 && !doneSong('constipation')) shitter.y = player.y + 2;

                case 'Scary Skeleton House':
                    if (controls.ACCEPT && player.char == 'sans-exe' && !canDeleteBox) {
                        player.interact();
                        if ((player.y < 38 && player.x < 100 && player.curDir == 2) || (player.y >= 208 && player.curDir == 1)) {
                            sansEXEfakeDiaBox(0);
                        } else if (player.y < 38 && player.x > 100 && player.curDir == 2) {nextRoom('Scary Sans Room');}
                    }
                    
                    if ((FlxG.keys.justPressed.SPACE || controls.DIA_NEXT) && canDeleteBox) {
                        theDiaTimer.cancel();
                        remove(fakeDiaBox);
                        canDeleteBox = false;
                    }

                case 'Scary Sans Room':
                    if (notStartedYet){
                        notStartedYet = false;
                        FlxG.sound.play(Paths.sound('door_close', 'overworld'));
                        new FlxTimer().start(6, function(tmr:FlxTimer) {sansEXEfakeDiaBox(1);});
                        new FlxTimer().start(9, function(tmr:FlxTimer) {
                            sansEXEfakeDiaBox(2);
                            player.shocked();
                        });
                        new FlxTimer().start(12, function(tmr:FlxTimer) {
                            var facing:String = '';
                            if (player.x <= shitter.x + shitter.width && player.x >= shitter.x && player.y >= shitter.y + shitter.height) {
                                facing = 'down';
                            } else if (player.x <= shitter.x + shitter.width && player.x >= shitter.x && player.y < shitter.y + shitter.height) {
                                facing = 'up';
                            } else if (player.x > shitter.x + shitter.width) {
                                facing = 'right';
                            } else if (player.x < shitter.x) {
                                facing = 'left';
                            }
                            shitter.playAnim('idle', facing);
                            FlxG.sound.play(Paths.sound('spear_rise', 'overworld'));
                            FlxTween.tween(shitter, {alpha: 1}, 1, {onComplete: function(twn:FlxTween) {
                                shitter.playAnim('laugh', facing);
                            }});
                        });
                        new FlxTimer().start(18.5, function(tmr:FlxTimer) {
                            var blackAss:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                            blackAss.cameras = [camHUD];
                            add(blackAss);
                        });
                        new FlxTimer().start(19, function(tmr:FlxTimer) {loadSong('too-far');});
                    }
                                    
                    if (FlxG.keys.justPressed.SPACE && canDeleteBox) {
                        theDiaTimer.cancel();
                        remove(fakeDiaBox);
                        canDeleteBox = false;
                    }

                    if (controls.ACCEPT && player.char == 'sans-exe' && !canDeleteBox) player.interact();

                default:
            }

            if (controls.MENU && !player.inInv && player.char != 'sans-exe' && !player.inCutscene) {    
                openSubState(new InventoryMenu(camHUD, player, player.y >= campoint.y));
                player.inInv = true;
            }

            if (FlxG.keys.justReleased.ESCAPE && leave) {
                escTween.cancel();
                escTween = null;
                escapeTxt.alpha = 0;
                escapeTimer.cancel();
                escapeTimer = null;
                quittingTimer.cancel();
                quittingTimer = null;
                escapeTxt.text = 'Quitting';
                leave = false;
            }
            if (FlxG.keys.pressed.ESCAPE && !leave) {
                leave = true;
                escTween = FlxTween.tween(escapeTxt, {alpha: 1}, 0.25);
                quittingTimer = new FlxTimer().start(1 / 3, function(tmr:FlxTimer) {if (FlxG.keys.pressed.ESCAPE) escapeTxt.text += '.';}, 3);
                escapeTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
                    if (FlxG.keys.pressed.ESCAPE) {
                        completedSongs.clear();
                        fled = false;
                        doneFunValues.set('fleeShit', false);
                        fromSong = false;
                        FlxG.sound.music.stop();
                        MusicBeatState.switchState(new Freepoop());
                    }
                });
            } 
        }

        finishsoul.setPosition(campoint.x - (finishsoul.actual.width / 2), campoint.y - (finishsoul.actual.height / 2));
        if(FlxG.sound.music != null && Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);
    }

    override public function stepHit() {
        super.stepHit();
        if (CoolUtil.checkFUNRange(9,20) && eatCone && !doneEvent('sansCone') && shitter != null) {
            switch(curStep) {
                case 0 | 8 | 16 | 24 | 32 | 40 | 48 | 56 | 64 | 72: shitter.animation.curAnim.curFrame = 3;
                case 4 | 12 | 20 | 28 | 36 | 44 | 52 | 59 | 68 | 76: shitter.animation.curAnim.curFrame = 2;
                case 80 | 88 | 96 | 104 | 112 | 118 | 128 | 136 | 144 | 150 | 158 | 165 | 173 | 189 | 237 | 245 | 253 | 261 | 269 | 277 | 285 | 292: shitter.animation.curAnim.curFrame = 5;
                case 84 | 92 | 100 | 108 | 116 | 122 | 132 | 140 | 148 | 154 | 161 | 169 | 181 | 233 | 241 | 249 | 257 | 265 | 273 | 281 | 289 | 296: shitter.animation.curAnim.curFrame = 4;
                case 300: shitter.animation.curAnim.curFrame = 7;
                case 304: shitter.animation.curAnim.curFrame = 6;
                case 319:
                    shitter.playAnim('idle-left');
                    shitter.color = FlxColor.BLACK;
                case 328:
                    FlxG.sound.music.stop();
                    doTrophyShit('ice_cream');                                    
                    diaBox = new DialogueBox(Dialogue.get(map, FUN, 4), {onComplete: function() {loadSong('constipation');}});
                    diaBox.cameras = [camHUD];
                    insert(0, diaBox);
                    doneFunValues.set('sansCone', true);
            }
        }
    }

    function loadSong(songName:String) {
        player.inCutscene = true;
        songLoading = true;
        player.rememberPos();
        PlayState.SONG = Song.loadFromJson(songName, songName);
        Transition.nextCamera = camHUD;
        if (songName != 'too-far') {
            MusicBeatState.doTransition = true;
            MusicBeatState.whatTransition = "soul";
            Transition.player = player;
            var point:FlxPoint = new FlxPoint(FlxG.camera.x, FlxG.camera.y);
            FlxG.camera.follow(null);
            FlxG.camera.setPosition(point.x, point.y);
            Transition.finishsoul = finishsoul;
        }
        LoadingState.loadAndSwitchState(new PlayState());
        fled = false; 
        doneFunValues.set('fleeShit', false);
        fromSong = false;
        completedSongs.set(songName, false);
    }

    function nextRoom(room:String) {
        player.inCutscene = true;
        nextmap = room;
        for (s in SongData.allSongs.keys()) if (SongData.allSongs.get(s).overworld == room) CoolUtil.reloadHP(SongData.allSongs.get(s).level);
        fled = false; 
        doneFunValues.set('fleeShit', false);
        fromSong = false;
        if (room == 'Scary Sans Room') FlxG.sound.play(Paths.sound('door_open', 'overworld'));
        FlxG.sound.music.stop();
        Transition.nextCamera = camHUD;
        MusicBeatState.doTransition = true;
        var point:FlxPoint = new FlxPoint(FlxG.camera.x, FlxG.camera.y);
        FlxG.camera.follow(null);
        FlxG.camera.setPosition(point.x, point.y);
        MusicBeatState.switchState(new Overworld());
    }

    function doneEvent(event:String):Bool return doneFunValues.exists(event) && doneFunValues.get(event);
    function doneSong(song:String):Bool return completedSongs.exists(song) && completedSongs.get(song);
    
    public static function checkForCollision(curDir:Int) {
        colHitbox.setPosition(playerH.x,playerH.y);
        switch (curDir) {
            case 0: colHitbox.x -= Player.speed; //left
            case 1: colHitbox.y += Player.speed; //down
            case 2: colHitbox.y -= Player.speed; //up
            case 3: colHitbox.x += Player.speed; //right
        }
        return colHitbox.overlaps(bounds);
    }

    function loadMap() {
        var realmap:String = Paths.formatToSongPath(map);
        var realroom:String = Paths.formatToSongPath(map);
        if (CoolUtil.checkFUNRange(65,66) && realmap == 'last-corridor') realroom = 'gast-corridor';

        var roomData:Array<String> = loadTable(realroom, realmap);
        bg = new FlxSprite().loadGraphic(Paths.image('rooms/${realmap}/${realroom}', 'overworld'));
        bg.antialiasing = false;
        add(bg);
        campoint = new FlxSprite((bg.width/2)-1,((bg.height/2)-1)).makeGraphic(1,1);
        campoint.alpha = 0;
        add(campoint);
        if (getVar(roomData,'music') != 'none' && getVar(roomData,'music') != '')
        FlxG.sound.playMusic(Paths.music(getVar(roomData,'music'), 'overworld'), 0.7);

        bounds = new FlxSpriteGroup();
        add(bounds);
        for (boxReal in getVar(roomData,'worldbounds').split('|')) //bound blocks
        {
            var bndDef:Array<Float> = toFloats(boxReal.split(','));
            var bound = new FlxSprite(bndDef[0],bndDef[1]).makeGraphic(Std.int(bndDef[2]),Std.int(bndDef[3]));
            bound.alpha = 0;
            bounds.add(bound);
        }

        characters = new FlxTypedGroup<FlxSprite>();
        add(characters);

        player = new Player(getVar(roomData,'player'), Std.parseFloat(getVar(roomData,'spawn').split(',')[0 + (2 * startMult)]), Std.parseFloat(getVar(roomData,'spawn').split(',')[1 + (2 * startMult)]), Std.parseInt(getVar(roomData,'startingdir')));
        if (startMult > 0) startMult = 0;
        player.antialiasing = false;
        switch (realmap) {
            case 'last-corridor':
                shitter = new NPC('sans', 819, -100);
                shitter.playAnim('idle-left');
                shitter.color = FlxColor.BLACK;
                if (CoolUtil.checkFUNRange(48,56) && !doneEvent('noSans')) shitter.visible = false;
                player.color = FlxColor.BLACK;
                characters.add(shitter);
            case 'gaster-room':
                if (fromSong && !doneSong('eggster')) completedSongs.set('eggster', true);

                shitter = new NPC('gaster', 150, doneSong('eggster') ? -500 : 77);
                shitter.playAnim('idle');
                characters.add(shitter);
            case 'scary-sans-room':
                shitter = new NPC('papyrus-exe', 40,60);
                shitter.playAnim('idle', 0);
                shitter.alpha = 0;
                characters.add(shitter);
                FlxG.sound.play(Paths.sound('door_close', 'overworld'));
            case 'scary-skeleton-house':
                FlxG.sound.play(Paths.sound('exe_snap', 'overworld'));
        }

        characters.add(player);
        FlxG.camera.follow(campoint, null, 1);
        playerH = new PlayerHitbox(player);
        add(playerH);
        colHitbox = new FlxSprite().makeGraphic(Std.int(playerH.width),Std.int(playerH.height));
        colHitbox.visible = false;
        add(colHitbox);

        for (i in roomData[getID(roomData,'objects')].split(':')) {
            if (i != 'objects') {
                var p:Array<String> = i.split(',');
                var curObj:Array<String> = getPage(roomData,p[0]);
                //var anims:Array<String> = [];
                //for (i in getVar(curObj,'animations').split(',')) {
                //    anims.push(curObj[getID(curObj,i)]);
                //}
                    
                var obj:FlxSprite = new FlxSprite();
                obj.loadGraphic(Paths.image('rooms/${realmap}/${getVar(curObj,'image')}', 'overworld'));
                obj.x = Std.parseFloat(getVar(curObj,'x'));
                obj.y = Std.parseFloat(getVar(curObj,'y'));
                obj.scrollFactor.x = Std.parseFloat(getVar(curObj,'scrollx'));
                obj.scrollFactor.y = Std.parseFloat(getVar(curObj,'scrolly'));
                obj.antialiasing = false;
                add(obj);
                switch (getVar(curObj,'overlayType')) {
                    default:
                        insert(members.indexOf(bg) + 1, obj);
                    case 'foreground':
                        insert(members.indexOf(colHitbox) + 1, obj);
                }
                //rpgObjs.push(obj);
            }
        }
        var judgePillars:FlxSprite = new FlxSprite();
        judgePillars.loadGraphic(Paths.image('rooms/${realmap}/Pillars', 'overworld'));
        judgePillars.setPosition(-420,0);
        judgePillars.scrollFactor.x = 2;
        judgePillars.scrollFactor.y = bg.scrollFactor.y;
        judgePillars.antialiasing = false;
        if (realmap == 'last-corridor') add(judgePillars);

        finishsoul = new Soul(0,0,true);
    }

    function doTrophyShit(thing:String) {
        if (!Trophies.getTrophyStats(thing, UNLOCKED)) {
            Trophies.unlockTrophy(thing);
            add(new TrophyPopup(thing, camHUD));
		}
    }
    
    function sansEXEfakeDiaBox(theBox:Int) {
        if (theDiaTimer != null) theDiaTimer.cancel();
        remove(fakeDiaBox);
        fakeDiaBox = new FlxSprite().loadGraphic(Paths.image('dialogue/papyrus-exe', 'overworld'), true, 960, 277);
        fakeDiaBox.animation.add('box', [theBox * 2]);
        fakeDiaBox.animation.add('comp', [(theBox * 2) + 1]);
        fakeDiaBox.animation.play('box');
        FlxG.sound.play(Paths.sound('dialogue/sans-exe/$theBox', 'overworld'));
        fakeDiaBox.y += (FlxG.height) - fakeDiaBox.height;
        fakeDiaBox.cameras = [camHUD];
        fakeDiaBox.antialiasing = false;
        add(fakeDiaBox);
        theDiaTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
            canDeleteBox = true;
            fakeDiaBox.animation.play('comp');
        }, 1);
    }

    // > point code
    function loadTable(roomFile:String, roomFolder:String) {
        return CoolUtil.coolTextFile('assets/overworld/images/rooms/${roomFolder}/${roomFile}-data.txt');
    }

    function toFloats(leTable:Array<String>) {
        var returnVal:Array<Float> = [];
        for (i in leTable) {
            returnVal.push(Std.parseFloat(i));
        }
        return returnVal;
    }

    function trimFromSplit(leString:String,amt:Int,?separator:String = ':') {
        var returnVal:String = '';
        var leTable:Array<String> = leString.split(separator);
        for (i in 0...amt) {
            leTable.remove(leTable[0]);
        }
        for (i in leTable) {
            returnVal += '${i}:';
        }
        return returnVal;
    }

    function getPage(leTable:Array<String>,leVar:String,?prefix:String = '>') {
        var startingPnt:Int = getID(leTable,leVar,'',prefix)+1;
        var cont:Bool = true;
        var returnVal:Array<String> = [];
        for (i in startingPnt...leTable.length) {
            if (leTable[i].charAt(0) == prefix)
                cont = false;
            if (cont) {
                returnVal.push(leTable[i]);
            }
        }
        return returnVal;
    }

    function getID(leTable:Array<String>,leVar:String,?separator:String = ':',?prefix:String = '') {
        var returnVal:Int = 0;
        if (prefix != '') {
            for (i in 0...leTable.length) {
                if (leTable[i].split('>')[1] == leVar)
                    returnVal = i;
            }
        } else {
            for (i in 0...leTable.length) {
                if (leTable[i].split(separator)[0] == leVar)
                    returnVal = i;
            }
        }
        return returnVal;
    }

    function getVar(leTable:Array<String>,leVar:String,?separator:String = ':') {
        var returnVal:String = '';
        for (i in leTable) {
            if (i.split(separator)[0] == leVar)
                returnVal = i.split(separator)[1];
        }
        return returnVal;
    }
}