package options;

import backend.InputFormatter;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import objects.AttachedSprite;
import objects.MenuText;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;

	//Show on gamepad - Display name - Save file key - Rebind display name
	var options:Array<Dynamic> = [
		[true, 'NOTES'],
		[true, 'Left', 'note_left', 'Note Left', true],
		[true, 'Down', 'note_down', 'Note Down', true],
		[true, 'Up', 'note_up', 'Note Up', true],
		[true, 'Right', 'note_right', 'Note Right', true],
		[true],
		[true, 'OVERWORLD'],
		[true, 'Left', 'overworld_left', 'OvrWld Left', true],
		[true, 'Down', 'overworld_down', 'OvrWld Down', true],
		[true, 'Up', 'overworld_up', 'OvrWld Up', true],
		[true, 'Right', 'overworld_right', 'OvrWld Right', true],
		[true],
		[true, 'UI'],
		[true, 'Left', 'ui_left', 'UI Left', true],
		[true, 'Down', 'ui_down', 'UI Down', true],
		[true, 'Up', 'ui_up', 'UI Up', true],
		[true, 'Right', 'ui_right', 'UI Right', true],
		[true],
		[true, 'Reset', 'reset', 'Reset', true],
		[true, 'Accept', 'accept', 'Accept', true],
		[true, 'Back', 'back', 'Back', true],
		[true, 'Menu', 'menu', 'Menu', true],
		[true, 'Pause', 'pause', 'Pause', true],
		[true],
		[true, 'DIALOGUE'],
		[true, 'Next', 'dia_next', 'Dia Next', false],
		[true, 'Skip', 'dia_skip', 'Dia Skip', false],
		[false],
		[false, 'VOLUME'],
		[false, 'Mute', 'volume_mute', 'Volume Mute', false],
		[false, 'Up', 'volume_up', 'Volume Up', false],
		[false, 'Down', 'volume_down', 'Volume Down', false]
	];
	var curOptions:Array<Int>;
	var curOptionsValid:Array<Int>;
	static var defaultKey:String = 'RESET TO DEFAULT';

	var soul:Soul;
	private var descText:FlxText;
	var grpDisplay:FlxTypedGroup<MenuText>;
	var grpOptions:FlxTypedGroup<MenuText>;
	var grpBinds:FlxTypedGroup<MenuText>;

	var gamepadColor:FlxColor = 0xfffff0b6;
	var keyboardColor:FlxColor = 0xff00ddff;
	var onKeyboardMode:Bool = true;
	
	var controllerSpr:FlxSprite;
	
	private var leMem:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var memX:Array<Null<Float>> = [];
	private var memTwns:Map<Int, FlxTween> = new Map<Int, FlxTween>();
	private var disableAll:Bool = false;
	private var closeTmr:FlxTimer;
	
	public function new() {
		super();

		options.push([true]);
		options.push([true, defaultKey]);

		grpDisplay = new FlxTypedGroup<MenuText>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<MenuText>();
		add(grpOptions);
		grpBinds = new FlxTypedGroup<MenuText>();
		add(grpBinds);
		
        soul = new Soul(900,0, true);
        soul.scale.set(3.111, 3.111);
        soul.updateHitbox();
		//leMem.add(soul);
        //add(soul);

		controllerSpr = new FlxSprite(90, 55).loadGraphic(Paths.image('settings/type'), true, 18, 16);
		controllerSpr.scale.set(3.5,3.5);
		controllerSpr.updateHitbox();
		controllerSpr.antialiasing = false;
		controllerSpr.animation.add('keyboard', [1], 1, false);
		controllerSpr.animation.add('gamepad', [0], 1, false);
		controllerSpr.animation.play('keyboard');
		leMem.add(controllerSpr);
		add(controllerSpr);

		var title:FlxText = new FlxText(0, 30, 0, '  CONTROL CONFIG');
		title.setFormat(Paths.font("DTM-Mono.ttf"), 80, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		title.screenCenter(X);
		title.borderSize = 2;
		title.antialiasing = false;
		leMem.add(title);
		add(title);
		
		descText = new FlxText(25, 400, 340, "press ctrl to swap keybinds", 32);
		descText.setFormat(Paths.font("DTM-Mono.ttf"), 36, FlxColor.WHITE, LEFT);
		descText.alpha = 0.5;
		descText.angle = 30;
		descText.antialiasing = false;
		leMem.add(descText);
		add(descText);
		
		createTexts();

		var grps:Array<FlxTypedGroup<Dynamic>> = [leMem, grpDisplay, grpOptions, grpBinds];
		var leg:Int = 0;
		for (h in grps) {
			for (i in 0...h.members.length) {
				var member = h.members[i];
				var j:Int = (i+leg) * 2;

				if (memX[j] == null) memX[j] = member.x;
				member.x += 615;
				if (memX[j+1] == null) memX[j+1] = member.alpha;
				member.alpha = 0;
				memTwns.set(j, FlxTween.tween(member, {x: memX[j]}, 1, {ease: FlxEase.sineOut}));
				memTwns.set(j+1, FlxTween.tween(member, {alpha: memX[j+1]}, 1, {ease: FlxEase.sineOut}));
			}
			leg += h.length;
		}
	}

	var lastID:Int = 0;
	function createTexts()
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:MenuText) text.destroy());
		grpOptions.forEachAlive(function(text:MenuText) text.destroy());
		grpBinds.forEachAlive(function(text:MenuText) text.destroy());
		grpDisplay.clear();
		grpOptions.clear();
		grpBinds.clear();

		var myID:Int = 0;

		for (i in 0...options.length)
		{
			var option:Array<Dynamic> = options[i];
			if(option[0] || onKeyboardMode)
			{
				if(option.length > 1)
				{
					var isCentered:Bool = (option.length < 3);
					var isDefaultKey:Bool = (option[1] == defaultKey);
					var isDisplayKey:Bool = (isCentered && !isDefaultKey);
					var isDualKeys:Bool = option[4];

					var text:MenuText = new MenuText(850, 300, 0, option[1].toUpperCase(), 32);
					text.antialiasing = false;
					text.x -= text.width;
					//text.isMenuItem = true;
					text.changeX = false;
					text.distancePerItem.y = 45;
					text.targetY = myID;
					if(isDisplayKey)
						grpDisplay.add(text);
					else {
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					text.ID = myID;
					lastID = myID;

					if(isCentered) addCenteredText(text, option, myID);
					else addKeyText(text, option, myID, isDualKeys);

					text.snapToPosition();
					//text.y += FlxG.height * 2;
				}
				myID++;
			}
		}
		updateText();
	}

	function addCenteredText(text:MenuText, option:Array<Dynamic>, id:Int) {
		text.x += 50;
		text.startPosition.x += 50;
		/*text.y -= 55;
		text.startPosition.y -= 55;*/
	}
	function addKeyText(text:MenuText, option:Array<Dynamic>, id:Int, dual:Bool = false)
	{
		for (n in 0...2) {
			var textX:Float = 250 + (n + (dual ? 0 : 1)) * 300;

			var key:String = null;
			if(onKeyboardMode) {
				var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option[2]);
				key = InputFormatter.getKeyName((savKey[n] != null) ? savKey[n] : NONE);
			} else {
				var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option[2]);
				key = InputFormatter.getGamepadName((savKey[n] != null) ? savKey[n] : NONE);
			}

			var attach:MenuText = new MenuText(textX + 110, 300, 0, key.toUpperCase(), 32);
			attach.antialiasing = false;
			attach.x -= attach.width;
			attach.changeX = false;
			attach.distancePerItem.y = 45;
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length / 2);
			attach.snapToPosition();
			//attach.y += FlxG.height * 2;
			grpBinds.add(attach);
			if (!dual && n == 1) attach.visible = attach.active = false;

			playstationCheck(attach);
			//attach.scaleX = Math.min(1, 230 / attach.width);
			//attach.text = key;

			// spawn black bars at the right of the key name
			/*var black:AttachedSprite = new AttachedSprite();
			black.makeGraphic(250, 78, FlxColor.BLACK);
			black.alphaMult = 0.4;
			black.sprTracker = text;
			black.yAdd = -6;
			black.xAdd = textX;
			grpBlacks.add(black);*/
		}
	}

	function playstationCheck(alpha:MenuText)
	{
		if(onKeyboardMode) return;

		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;
		/*var letter = alpha.letters[0];
		if(model == PS4)
		{
			switch(alpha.text)
			{
				case '[', ']': //Square and Triangle respectively
					//letter.image = 'alphabet_playstation';
					letter.updateHitbox();
					
					letter.offset.x += 4;
					letter.offset.y -= 5;
			}
		}*/
	}

	function updateBind(num:Int, text:String) {
		var bind:MenuText = grpBinds.members[num];
		var attach:MenuText = new MenuText(360 + ((num % 2) + (options[curSelected][4] ? 0 : 1)) * 300, 300, 0, text.toUpperCase(), 32);
		attach.startPosition.x -= attach.width;
		attach.antialiasing = false;
		attach.changeX = false;
		attach.distancePerItem.y = 45;
		attach.targetY = bind.targetY;
		attach.ID = bind.ID;
		attach.x = (bind.x + bind.width) - attach.width;
		attach.y = bind.y;
		attach.visible = attach.active = bind.active;
		
		playstationCheck(attach);
		//attach.scaleX = Math.min(1, 230 / attach.width);
		//attach.text = text;

		bind.kill();
		grpBinds.remove(bind);
		grpBinds.insert(num, attach);
		bind.destroy();

		updateAlt();
	}

	var binding:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:MenuText;
	var bindingText2:MenuText;

	var timeForMoving:Float = 0.1;
	var qtangle:Float = 0;
	override function update(elapsed:Float) {
		if (descText != null) {
			qtangle -= 3 * elapsed;
			descText.offset.set(Math.cos(qtangle) * 3, Math.sin(qtangle) * 3);
		}

		if(timeForMoving > 0) {//Fix controller bug
			timeForMoving = Math.max(0, timeForMoving - elapsed);
			super.update(elapsed);
			return;
		}

		if (!disableAll) {
		var upPress:Bool = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP || FlxG.gamepads.anyJustPressed(DPAD_UP) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP);
		var downPress:Bool = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN || FlxG.gamepads.anyJustPressed(DPAD_DOWN) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN);
		var leftPress:Bool = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT || FlxG.gamepads.anyJustPressed(DPAD_LEFT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT);
		var rightPress:Bool = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT || FlxG.gamepads.anyJustPressed(DPAD_RIGHT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT);
		var accPress:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A);
		var bckPress:Bool = FlxG.keys.justPressed.ESCAPE || FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyJustPressed(B);
		var ctrlPress:Bool = FlxG.keys.justPressed.CONTROL || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) || FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER);
		
		if(!binding) {
			if(bckPress) {
				disableAll = true;
				OptionsState.instance.twnBack();
				var grps:Array<FlxTypedGroup<Dynamic>> = [leMem, grpDisplay, grpOptions, grpBinds];
				var leg:Int = 0;
				for (h in grps) {
					for (i in 0...h.members.length) {
						var member = h.members[i];
						var j:Int = (i+leg) * 2;

						memTwns.set(j, FlxTween.tween(member, {x: memX[j] + 615}, 1, {ease: FlxEase.sineOut}));
						memTwns.set(j+1, FlxTween.tween(member, {alpha: 0}, 1, {ease: FlxEase.sineOut}));
					}
					leg += h.length;
				}

				ClientPrefs.saveSettings();
				closeTmr = new FlxTimer().start(1, function(tmr:FlxTimer) {close();});
				FlxG.sound.play(Paths.sound('back'));
			}

			if(ctrlPress) swapMode();
			if (leftPress || rightPress) updateAlt(true);
			if(upPress) updateText(-1);
			else if(downPress) updateText(1);

			if(accPress) {
				if(options[curOptions[curSelected]][1] != defaultKey) {
					descText.text = "rebinding " + options[curOptions[curSelected]][3].toLowerCase() + "\nhold esc to cancel";

					binding = true;
					holdingEsc = 0;
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('select'));
				} else {
					// Reset to Default
					ClientPrefs.resetKeys(!onKeyboardMode);
					ClientPrefs.reloadVolumeKeys();
					var lastSel:Int = curSelected;
					createTexts();
					curSelected = lastSel;
					updateText();
					FlxG.sound.play(Paths.sound('back'));
					//grpOptions.members[curSelected].color = FlxColor.RED;
				}
			}
		} else {
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B)) {
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					FlxG.sound.play(Paths.sound('back'));
					closeBinding();
				}
			} else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK)) {
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					ClientPrefs.keyBinds.get(curOption[2])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[2]);
					updateBind(Math.floor(curSelected * 2) + altNum, onKeyboardMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
					FlxG.sound.play(Paths.sound('back'));
					closeBinding();
				}
			} else {
				holdingEsc = 0;
				var changed:Bool = false;
				var curKeys:Array<FlxKey> = ClientPrefs.keyBinds.get(curOption[2]);
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[2]);

				if(onKeyboardMode)
				{
					if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
					{
						var keyPressed:Int = FlxG.keys.firstJustPressed();
						var keyReleased:Int = FlxG.keys.firstJustReleased();
						if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
						{
							curKeys[altNum] = keyPressed;
							changed = true;
						}
						else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
						{
							curKeys[altNum] = keyReleased;
							changed = true;
						}
					}
				} else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY)) {
					var keyPressed:Null<FlxGamepadInputID> = NONE;
					var keyReleased:Null<FlxGamepadInputID> = NONE;
					if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)) keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
					else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)) keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
					else
					{
						for (i in 0...FlxG.gamepads.numActiveGamepads)
						{
							var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
							if(gamepad != null)
							{
								keyPressed = gamepad.firstJustPressedID();
								keyReleased = gamepad.firstJustReleasedID();

								if(keyPressed == null) keyPressed = NONE;
								if(keyReleased == null) keyReleased = NONE;
								if(keyPressed != NONE || keyReleased != NONE) break;
							}
						}
					}

					if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
					{
						curButtons[altNum] = keyPressed;
						changed = true;
					}
					else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
					{
						curButtons[altNum] = keyReleased;
						changed = true;
					}
				}

				if(changed)
				{
					if (onKeyboardMode)
					{
						if(curKeys[altNum] == curKeys[1 - altNum])
							curKeys[1 - altNum] = FlxKey.NONE;
					}
					else
					{
						if(curButtons[altNum] == curButtons[1 - altNum])
							curButtons[1 - altNum] = FlxGamepadInputID.NONE;
					}

					var option:String = options[curOptions[curSelected]][2];
					ClientPrefs.clearInvalidKeys(option);
					for (n in 0...2)
					{
						var key:String = null;
						if(onKeyboardMode)
						{
							var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
							key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
						}
						else
						{
							var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
							key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
						}
						updateBind(Math.floor(curSelected * 2) + n, key);
					}
					FlxG.sound.play(Paths.sound('confirm'));
					closeBinding();
				}
			}
		}
		}

		super.update(elapsed);
	}

	function closeBinding() {
		binding = false;
		descText.text = "press ctrl to swap keybinds";
		ClientPrefs.reloadVolumeKeys();
	}

	function updateText(?move:Int = 0)
	{
		if(move != 0)
		{
			//var dir:Int = Math.round(move / Math.abs(move));
			curSelected += move;

			if(curSelected < 0) curSelected = curOptions.length - 1;
			else if (curSelected >= curOptions.length) curSelected = 0;
		}

		var num:Int = curOptionsValid[curSelected];
		var addNum:Int = 0;
		if(num < 3) addNum = 3 - num;
		else if(num > lastID - 4) addNum = (lastID - 4) - num;

		grpDisplay.forEachAlive(function(item:MenuText) {
			item.targetY = item.ID - num - addNum;
		});

		grpOptions.forEachAlive(function(item:MenuText)
		{
			item.targetY = item.ID - num - addNum;
			item.color = (item.ID - num == 0 && item.text == defaultKey) ? FlxColor.YELLOW : FlxColor.WHITE;
			if (item.ID - num == 0 && item.text != defaultKey) {
				soul.visible = true;
				soul.sprTracker = item;
			} else if (item.ID - num == 0 && item.text == defaultKey) soul.visible = false;
		});
		grpBinds.forEachAlive(function(item:MenuText)
		{
			var parent:MenuText = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			item.alpha = parent.alpha;
		});

		updateAlt();
		FlxG.sound.play(Paths.sound('select'));
	}

	function swapMode()
	{
		onKeyboardMode = !onKeyboardMode;

		curSelected = 0;
		curAlt = false;
		controllerSpr.animation.play(onKeyboardMode ? 'keyboard' : 'gamepad');
		createTexts();
	}

	function updateAlt(?doSwap:Bool = false) {
		if (grpBinds.members[Math.floor(curSelected * 2) + 1] != null) {
			if(doSwap && grpBinds.members[Math.floor(curSelected * 2) + 1].active) {
				curAlt = !curAlt;
				FlxG.sound.play(Paths.sound('select'));
			} else if (!grpBinds.members[Math.floor(curSelected * 2) + 1].active && curAlt) curAlt = false;
		}
		
		grpDisplay.forEachAlive(function(item:MenuText) {
			var shit = (item.targetY * 1.3 * item.distancePerItem.y) + item.startPosition.y;
			if (shit < 100) item.alpha = 0.5;
			else item.alpha = 1;
		});
		grpOptions.forEachAlive(function(item:MenuText) {
			var shit = (item.targetY * 1.3 * item.distancePerItem.y) + item.startPosition.y;
			if (shit < 100) item.alpha = 0.5;
			else item.alpha = 1;
		});
		grpBinds.forEachAlive(function(item:MenuText) {
			var parent:MenuText = grpOptions.members[item.ID];
			item.alpha = parent.alpha;
			item.color = (item == grpBinds.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)]) ? FlxColor.YELLOW : FlxColor.WHITE;
		});
	}
}