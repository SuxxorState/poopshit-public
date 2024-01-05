package substates;

import backend.MusicBeatSubstate;
import backend.Dialogue;
import objects.DialogueBox;
import states.Overworld;

using StringTools;

class InventoryMenu extends MusicBeatSubstate {
    var diabox:DialogueBox;
    var curSelectedMain:Int = 0;
    var mainList:Array<String> = ['ITEM', 'STAT', 'CELL'];
    var mainItems:FlxTypedGroup<FlxSprite>;
    var curSelectedSub:Int = 0;
    static var subLists:Array<Array<String>> = [[/*'Bravery'*/],[],['CUTIEPIE <3', 'PAPI', 'Saul', 'Goat Mama'/*, 'Skeletor'*/]];
    var subItems:FlxTypedGroup<FlxSprite>;
    var inSubMenu:Bool = false;
    var camHUD:FlxCamera;
    var player:Player;
    var diaBoxOnTop:Bool = true;
    var soul:Soul;
    var pressedMenu:Bool = true;
    var room:Int = 0;

    public function new(cam:FlxCamera, player:Player, top:Bool = true) {
        super();
        camHUD = cam;
        this.player = player;
        diaBoxOnTop = top;

        var statBoxB:FlxSprite = new FlxSprite(50, diaBoxOnTop ? FlxG.height - (Std.int(56 * DialogueBox.dasize) + 80) : 40).makeGraphic(Std.int(80 * DialogueBox.dasize), Std.int(56 * DialogueBox.dasize), FlxColor.WHITE);
        var statBoxF:FlxSprite = new FlxSprite(statBoxB.x + (3 * DialogueBox.dasize), statBoxB.y + (3 * DialogueBox.dasize)).makeGraphic(Std.int(74 * DialogueBox.dasize), Std.int(50 * DialogueBox.dasize), FlxColor.BLACK);
        statBoxB.cameras = [cam];
        statBoxF.cameras = [cam];
        add(statBoxB);
        add(statBoxF);

        var nameTxt:FlxText = new FlxText(statBoxB.x + 15, statBoxB.y + 7, 0, ClientPrefs.data.charName);
        nameTxt.setFormat(Paths.font('8bitoperator_jve.ttf'), 48);
        nameTxt.cameras = [cam];
        add(nameTxt);

        var lvTxt:FlxText = new FlxText(statBoxB.x + 15, statBoxB.y + 67, 0, 'LV  ' + CoolUtil.plrlevel);
        lvTxt.setFormat(Paths.font('undertale-crypt-of-tommorow.ttf'), 14);
        lvTxt.cameras = [cam];
        lvTxt.antialiasing = false;
        add(lvTxt);
        var hpTxt:FlxText = new FlxText(statBoxB.x + 15, statBoxB.y + 92, 0, 'HP  ' + CoolUtil.formatDigits(CoolUtil.plrhealth) + '/' + CoolUtil.formatDigits(CoolUtil.plrmaxhealth));
        hpTxt.setFormat(Paths.font('undertale-crypt-of-tommorow.ttf'), 14);
        hpTxt.cameras = [cam];
        hpTxt.antialiasing = false;
        add(hpTxt);
        var gdTxt:FlxText = new FlxText(statBoxB.x + 15, statBoxB.y + 117, 0, 'G   poor');
        gdTxt.setFormat(Paths.font('undertale-crypt-of-tommorow.ttf'), 14);
        gdTxt.cameras = [cam];
        gdTxt.antialiasing = false;
        add(gdTxt);
        
        var mainBoxB:FlxSprite = new FlxSprite(50, diaBoxOnTop ? 210 + 35 : 210).makeGraphic(Std.int(80 * DialogueBox.dasize), Std.int(81 * DialogueBox.dasize), FlxColor.WHITE);
        var mainBoxF:FlxSprite = new FlxSprite(mainBoxB.x + (3 * DialogueBox.dasize), mainBoxB.y + (3 * DialogueBox.dasize)).makeGraphic(Std.int(74 * DialogueBox.dasize), Std.int(75 * DialogueBox.dasize), FlxColor.BLACK);
        mainBoxB.cameras = [cam];
        mainBoxF.cameras = [cam];
        add(mainBoxB);
        add(mainBoxF);
        
        mainItems = new FlxTypedGroup<FlxSprite>();
        add(mainItems);
        
        subItems = new FlxTypedGroup<FlxSprite>();
        add(subItems);

        for (i in 0...mainList.length) {
            var leText:FlxText = new FlxText(mainBoxB.x + 85, mainBoxB.y + 25 + (58 * i), 0, mainList[i]);
            if (i == 0 && subLists[0].length < 1) {
                leText.active = false;
                leText.alpha = 0.6;
                curSelectedMain++;
            }
            leText.setFormat(Paths.font('8bitoperator_jve.ttf'), 48);
            leText.cameras = [cam];
            leText.antialiasing = false;
            leText.ID = i;
            mainItems.add(leText);
        }

        soul = new Soul(mainBoxB.x + 30, mainBoxB.y + 11 + (58 * curSelectedMain), true);
        soul.scale.set(3.111, 3.111);
        soul.updateHitbox();
        soul.cameras = [cam];
        add(soul);

        changeSelectionMain();

        new FlxTimer().start(0.1, function(tmr:FlxTimer) {pressedMenu = false;});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if ((diabox == null || !diabox.exists)) {
            if (!inSubMenu) {
                if (controls.UI_UP_P) changeSelectionMain(-1);
                if (controls.UI_DOWN_P) changeSelectionMain(1);
            } else {
                if (controls.UI_UP_P) changeSelectionSub(-1);
                if (controls.UI_DOWN_P) changeSelectionSub(1);
            }
        }

        if (controls.ACCEPT) {
            if (!inSubMenu && (diabox == null || !diabox.exists)) {
                FlxG.sound.play(Paths.sound('confirm'));
                makeBox(mainList[curSelectedMain]);
                inSubMenu = true;
                changeSelectionSub();
            } else if (diabox == null || !diabox.exists) {
                switch (curSelectedMain) {
                    case 0:
                        FlxG.sound.play(Paths.sound('confirm'));
                        //ClientPrefs.data.soulColor = 'orange';
                    case 2:
                        FlxG.sound.play(Paths.sound('confirm'));
                        diabox = new DialogueBox(Dialogue.getCall(subLists[2][curSelectedSub], Overworld.map), {boxPos: diaBoxOnTop ? TOP : BOTTOM, phoneCall: true, player: player, onComplete: function() {
                            player.idle();
                            Dialogue.setCall(subLists[2][curSelectedSub], Overworld.map);
                            var what:String = subLists[2][curSelectedSub];
                            subLists[2].remove(what);
                            subLists[2].insert(0, what);
                            close();
                        }});
                        diabox.cameras = [camHUD];
                        add(diabox);
                        inSubMenu = false;
                        subItems.clear(); 
                        soul.visible = false; 
                }
            }
        }

        if (controls.BACK && (diabox == null || !diabox.exists)) {
            if (!inSubMenu) {
                close();
                player.idle();
            } else {
                inSubMenu = false;
                subItems.clear(); 
                changeSelectionMain(); 
                soul.visible = true;
            }
        }

        if (controls.MENU && (diabox == null || !diabox.exists) && !pressedMenu) {
            close();
            player.idle();
        }
    }

    function makeBox(sub:String = 'ITEM') {
        switch (sub) {
            case 'ITEM':
                var itemBoxB:FlxSprite = new FlxSprite(300, 40).makeGraphic(Std.int(80 * DialogueBox.dasize), Std.int(56 * DialogueBox.dasize), FlxColor.WHITE);
                var itemBoxF:FlxSprite = new FlxSprite(itemBoxB.x + (3 * DialogueBox.dasize), itemBoxB.y + (3 * DialogueBox.dasize)).makeGraphic(Std.int(74 * DialogueBox.dasize), Std.int(50 * DialogueBox.dasize), FlxColor.BLACK);
                itemBoxB.cameras = [camHUD];
                itemBoxF.cameras = [camHUD];
                subItems.add(itemBoxB);
                subItems.add(itemBoxF);
            case 'STAT':
                soul.visible = false;
                var statBoxB:FlxSprite = new FlxSprite(300, 40).makeGraphic(Std.int(185 * DialogueBox.dasize), Std.int(234 * DialogueBox.dasize), FlxColor.WHITE);
                var statBoxF:FlxSprite = new FlxSprite(statBoxB.x + (3 * DialogueBox.dasize), statBoxB.y + (3 * DialogueBox.dasize)).makeGraphic(Std.int(179 * DialogueBox.dasize), Std.int(228 * DialogueBox.dasize), FlxColor.BLACK);
                statBoxB.cameras = [camHUD];
                statBoxF.cameras = [camHUD];
                subItems.add(statBoxB);
                subItems.add(statBoxF);

                var leText:FlxText = new FlxText(345, 82, 0, '"${ClientPrefs.data.charName}"\n\nLV ${CoolUtil.plrlevel}\nHP ${CoolUtil.formatDigits(CoolUtil.plrhealth, CoolUtil.plrmaxhealth)}\n\nAT 36 (99)\nDF 4 (99)\n\nWEAPON: Microphone\nARMOR: Ignorance\n\nGOLD: poor');
                leText.setFormat(Paths.font('8bitoperator_jve.ttf'), 48);
                leText.cameras = [camHUD];
                subItems.add(leText);
                
                var leText:FlxText = new FlxText(575, 82, 0, '\n\n\n\n\nEXP: 5\nNext: 1\n\n\n\n\nKILLS: a lot');
                leText.setFormat(Paths.font('8bitoperator_jve.ttf'), 48);
                leText.cameras = [camHUD];
                subItems.add(leText);

            case 'CELL':
                var cellBoxB:FlxSprite = new FlxSprite(300, diaBoxOnTop ? 70 : 40).makeGraphic(Std.int(185 * DialogueBox.dasize), Std.int(148 * DialogueBox.dasize), FlxColor.WHITE);
                var cellBoxF:FlxSprite = new FlxSprite(cellBoxB.x + (3 * DialogueBox.dasize), cellBoxB.y + (3 * DialogueBox.dasize)).makeGraphic(Std.int(179 * DialogueBox.dasize), Std.int(142 * DialogueBox.dasize), FlxColor.BLACK);
                cellBoxB.cameras = [camHUD];
                cellBoxF.cameras = [camHUD];
                subItems.add(cellBoxB);
                subItems.add(cellBoxF);
        }
        
        for (i in 0...subLists[2].length) {
            var leText:FlxText = new FlxText(375, 112 + (50 * i) - (diaBoxOnTop ? 0 : 30), 0, subLists[curSelectedMain][i]);
            leText.setFormat(Paths.font('8bitoperator_jve.ttf'), 48);
            leText.cameras = [camHUD];
            leText.ID = i;
            subItems.add(leText);
        }
    }

    function changeSelectionMain(huh:Int = 0) {
        curSelectedMain += huh;

        if (curSelectedMain >= mainList.length) curSelectedMain = 0;
        for (item in mainItems.members) if (curSelectedMain == item.ID && !item.active) curSelectedMain += huh;
        if (curSelectedMain < 0) curSelectedMain = mainList.length - 1;

        FlxG.sound.play(Paths.sound('select'));
        curSelectedSub = 0;

        for (item in mainItems.members) if (curSelectedMain == item.ID) soul.setPosition(80, item.y - 2);
    }
    
    function changeSelectionSub(huh:Int = 0) {
        curSelectedSub += huh;

        if (huh != 0 && subLists[curSelectedMain].length > 1) FlxG.sound.play(Paths.sound('select'));

        if (curSelectedSub < 0) curSelectedSub = subLists[curSelectedMain].length - 1;
        if (curSelectedSub >= subLists[curSelectedMain].length) curSelectedSub = 0;

        for (item in subItems.members) if (curSelectedSub == item.ID) soul.setPosition(326, item.y - 2);
        switch (curSelectedMain) {
            case 0:

            case 2:

        }
    }
}