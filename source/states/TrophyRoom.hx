package states;

import objects.TrophyItem;

class TrophyRoom extends MusicBeatState {
	var trphList:Array<Array<String>> = [];
	private var grpTrophies:FlxTypedGroup<TrophyItem>;
	private static var curSelected:Int = 0;
	var grass:FlxSprite;
	var sans:NPC;
	var papyrus:NPC;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Trophies Menu", null);
		#end

		grass = new FlxSprite(0,FlxG.height).loadGraphic(Paths.image('grass'));
		grass.setGraphicSize(Std.int(grass.width * 2));
		grass.updateHitbox();
		grass.screenCenter(X);
		grass.antialiasing = false;
		add(grass);

		sans = new NPC('sans-lounge', 0, FlxG.height);
		sans.playRandomAnim();
		sans.setGraphicSize(sans.width * 2);
		sans.screenCenter(X);
		sans.x -= 34;
		add(sans);
		
		papyrus = new NPC('papyrus', 0, FlxG.height);
		papyrus.playRandomAnim();
		papyrus.setGraphicSize(papyrus.width * 2);
		papyrus.screenCenter(X);
		papyrus.x += 48;
		add(papyrus);

		grpTrophies = new FlxTypedGroup<TrophyItem>();
		add(grpTrophies);

		Trophies.loadTrophies();

		for (i in Trophies.trophyStuff) trphList.push(i);
		for (i in 0...trphList.length) {
			var trophy:TrophyItem = new TrophyItem(trphList[i], 30, 260, i - curSelected);
			trophy.snapToPosition();
			grpTrophies.add(trophy);
		}

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1);
		if (controls.BACK) MusicBeatState.switchState(new Freepoop());
		if (controls.ACCEPT) 
			for (item in grpTrophies.members) if (item.num == 0) item.playTrophyAudio();

		super.update(elapsed);

		var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
		grass.y = FlxMath.lerp(grass.y, curSelected == trphList.length - 1 ? 580 : 780, lerpVal);
		sans.y = grass.y + 8;
		papyrus.y = grass.y;
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = trphList.length - 1;
		if (curSelected >= trphList.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpTrophies.members) {
			item.num = bullShit - curSelected;
			bullShit++;
			item.changeSelected(item.num == 0);
		}

		FlxG.sound.play(Paths.sound('select'));
	}
}
