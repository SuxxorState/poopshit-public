package options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;
import lime.system.Clipboard;
import flixel.util.FlxGradient;
import objects.StrumNote;
import objects.Note;
import backend.InputFormatter;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class NotesSubState extends MusicBeatSubstate
{
	var onModeColumn:Bool = true;
	var curSelectedMode:Int = 0;
	var curSelectedNote:Int = 0;
	var onPixel:Bool = false;
	var dataArray:Array<Array<FlxColor>>;

	var hexTypeLine:FlxSprite;
	var hexTypeNum:Int = -1;
	var hexTypeVisibleTimer:Float = 0;

	var copyButton:FlxSprite;
	var pasteButton:FlxSprite;

	var colorGradient:FlxSprite;
	var colorGradientSelector:FlxSprite;
	var colorPalette:FlxSprite;
	var colorWheel:FlxSprite;
	var colorWheelSelector:FlxSprite;

	var alphabetR:FlxText;
	var alphabetG:FlxText;
	var alphabetB:FlxText;
	var alphabetHex:FlxText;

	// controller support
	var controllerPointer:FlxSprite;
	var _lastControllerMode:Bool = false;
	var tipTxt:FlxText;

	private var leMem:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var memX:Array<Null<Float>> = [];
	private var memTwns:Map<Int, FlxTween> = new Map<Int, FlxTween>();
	private var disableAll:Bool = false;
	private var closeTmr:FlxTimer;

	public function new() {
		super();
		
		tipTxt = new FlxText(0, 690, 0, '', 16);
		tipTxt.setFormat(Paths.font("Mars_Needs_Cunnilingus.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		tipTxt.alpha = 0.5;
		tipTxt.antialiasing = false;
		leMem.add(tipTxt);
		add(tipTxt);
		updateTip();

		modeNotes = new FlxTypedGroup<FlxSprite>();
		add(modeNotes);

		myNotes = new FlxTypedGroup<NoteButton>();
		add(myNotes);

		copyButton = new FlxSprite(580, 35).loadGraphic(Paths.image('settings/copy'));
		copyButton.setGraphicSize(Std.int(copyButton.width * 2));
		copyButton.updateHitbox();
		copyButton.antialiasing = false;
		leMem.add(copyButton);
		add(copyButton);

		pasteButton = new FlxSprite(830, 35).loadGraphic(Paths.image('settings/paste'));
		pasteButton.setGraphicSize(Std.int(pasteButton.width * 2));
		pasteButton.updateHitbox();
		pasteButton.antialiasing = false;
		leMem.add(pasteButton);
		add(pasteButton);

		colorPalette = new FlxSprite(120, 600).loadGraphic(Paths.image('settings/palette', false));
		colorPalette.scale.set(20, 20);
		colorPalette.updateHitbox();
		colorPalette.antialiasing = false;
		var outline:FlxSprite = new FlxSprite(colorPalette.x - 3, colorPalette.y - 3).makeGraphic(Std.int(colorPalette.width + 6), Std.int(colorPalette.height + 6), FlxColor.WHITE);
		//add(outline);
		//add(colorPalette);
		
		colorWheel = new FlxSprite(560, 200).loadGraphic(Paths.image('settings/colorWheel'));
		colorWheel.setGraphicSize(360, 360);
		colorWheel.updateHitbox();
		colorWheel.antialiasing = false;
		var outline:FlxSprite = new FlxShapeCircle(colorWheel.x - 4, colorWheel.y - 4, (colorWheel.width / 2) + 4, {thickness: 0}, FlxColor.WHITE);
		outline.antialiasing = false;
		leMem.add(outline);
		leMem.add(colorWheel);
		add(outline);
		add(colorWheel);

		colorGradient = FlxGradient.createGradientFlxSprite(360, 60, [FlxColor.WHITE, FlxColor.BLACK], 1, 180);
		colorGradient.setPosition(560, colorWheel.y + colorWheel.height + 50);
		colorGradient.antialiasing = false;
		var outline:FlxSprite = new FlxSprite(colorGradient.x - 3, colorGradient.y - 3).makeGraphic(Std.int(colorGradient.width + 6), Std.int(colorGradient.height + 6), FlxColor.WHITE);
		leMem.add(outline);
		leMem.add(colorGradient);
		add(outline);
		add(colorGradient);

		colorGradientSelector = new FlxSprite(colorGradient.x, colorGradient.y - 10).makeGraphic(10, 80, FlxColor.WHITE);
		colorGradientSelector.antialiasing = false;
		colorGradientSelector.offset.x = 5;
		leMem.add(colorGradientSelector);
		add(colorGradientSelector);

		colorWheelSelector = new FlxShapeCircle(0, 0, 8, {thickness: 0}, FlxColor.WHITE);
		colorWheelSelector.antialiasing = false;
		colorWheelSelector.offset.set(8, 8);
		colorWheelSelector.alpha = 0.6;
		leMem.add(colorWheelSelector);
		add(colorWheelSelector);

		var txtX = 740;
		var txtY = 120;
		alphabetR = makeColorAlphabet(txtX - 100, txtY);
		leMem.add(alphabetR);
		add(alphabetR);
		alphabetG = makeColorAlphabet(txtX, txtY);
		leMem.add(alphabetG);
		add(alphabetG);
		alphabetB = makeColorAlphabet(txtX + 100, txtY);
		leMem.add(alphabetB);
		add(alphabetB);
		alphabetHex = makeColorAlphabet(txtX, txtY - 55);
		leMem.add(alphabetHex);
		add(alphabetHex);
		hexTypeLine = new FlxSprite(0, 20).makeGraphic(5, 62, FlxColor.WHITE);
		hexTypeLine.visible = false;
		leMem.add(hexTypeLine);
		add(hexTypeLine);

		spawnNotes();
		updateNotes(true);
		FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);

		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.antialiasing = false;
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		leMem.add(controllerPointer);
		add(controllerPointer);
		
		FlxG.mouse.visible = !controls.controllerMode;
		controllerPointer.visible = controls.controllerMode;
		_lastControllerMode = controls.controllerMode;
		
		for (i in 0...leMem.members.length) {
			var member = leMem.members[i];

			if (memX[i*2] == null) memX[i*2] = member.x;
			member.x += 615;
			if (memX[(i*2)+1] == null) memX[(i*2)+1] = member.alpha;
			member.alpha = 0;
			memTwns.set(i*2, FlxTween.tween(member, {x: memX[i*2]}, 1, {ease: FlxEase.sineOut}));
			memTwns.set((i*2) + 1, FlxTween.tween(member, {alpha: memX[(i*2)+1]}, 1, {ease: FlxEase.sineOut}));
		}
	}

	function updateTip() {
		var rel:String = controls.controllerMode ? InputFormatter.getGamepadName(ClientPrefs.gamepadBinds.get('reset')[0]) : InputFormatter.getKeyName(ClientPrefs.keyBinds.get('reset')[0]);
		if (rel == null || rel.length < 1) rel = 'RESET';
		rel = rel.toUpperCase();

		var shft:String = controls.controllerMode ? 'LEFT SHOULDER BUTTON' : 'SHIFT';

		tipTxt.text = 'Press $rel to reset the selected part.   Press $shft + $rel to reset the entire note.';
		tipTxt.screenCenter(X);
	}

	var _storedColor:FlxColor;
	var changingNote:Bool = false;
	var holdingOnObj:FlxSprite;
	var allowedTypeKeys:Map<FlxKey, String> = [
		ZERO => '0', ONE => '1', TWO => '2', THREE => '3', FOUR => '4', FIVE => '5', SIX => '6', SEVEN => '7', EIGHT => '8', NINE => '9',
		NUMPADZERO => '0', NUMPADONE => '1', NUMPADTWO => '2', NUMPADTHREE => '3', NUMPADFOUR => '4', NUMPADFIVE => '5', NUMPADSIX => '6',
		NUMPADSEVEN => '7', NUMPADEIGHT => '8', NUMPADNINE => '9', A => 'A', B => 'B', C => 'C', D => 'D', E => 'E', F => 'F'];

	override function update(elapsed:Float) {
		if (controls.BACK) {
			disableAll = true;
			OptionsState.instance.twnBack();
			for (i in 0...leMem.members.length) {
				var member = leMem.members[i];
	
				memTwns.set(i*2, FlxTween.tween(member, {x: memX[i*2] + 615}, 1, {ease: FlxEase.sineOut}));
				memTwns.set((i*2) + 1, FlxTween.tween(member, {alpha: 0}, 1, {ease: FlxEase.sineOut}));
			}

			ClientPrefs.saveSettings();
			FlxG.mouse.visible = false;
			closeTmr = new FlxTimer().start(1, function(tmr:FlxTimer) {close();});
			FlxG.sound.play(Paths.sound('back'));
		}

		super.update(elapsed);

		if (!disableAll) {
			// Early controller checking
			if(FlxG.gamepads.anyJustPressed(ANY)) controls.controllerMode = true;
			else if(FlxG.mouse.justPressed || FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0) controls.controllerMode = false;
			//
			
			var changedToController:Bool = false;
			if(controls.controllerMode != _lastControllerMode)
			{
				//trace('changed controller mode');
				FlxG.mouse.visible = !controls.controllerMode;
				controllerPointer.visible = controls.controllerMode;

				// changed to controller mid state
				if(controls.controllerMode)
				{
					controllerPointer.x = FlxG.mouse.x;
					controllerPointer.y = FlxG.mouse.y;
					changedToController = true;
				}
				// changed to keyboard mid state
				/*else
				{
					FlxG.mouse.x = controllerPointer.x;
					FlxG.mouse.y = controllerPointer.y;
				}
				// apparently theres no easy way to change mouse position that i know, oh well
				*/
				_lastControllerMode = controls.controllerMode;
				updateTip();
			}

			// controller things
			var analogX:Float = 0;
			var analogY:Float = 0;
			var analogMoved:Bool = false;
			if(controls.controllerMode && (changedToController || FlxG.gamepads.anyInput()))
			{
				for (gamepad in FlxG.gamepads.getActiveGamepads())
				{
					analogX = gamepad.getXAxis(LEFT_ANALOG_STICK);
					analogY = gamepad.getYAxis(LEFT_ANALOG_STICK);
					analogMoved = (analogX != 0 || analogY != 0);
					if(analogMoved) break;
				}
				controllerPointer.x = Math.max(0, Math.min(FlxG.width, controllerPointer.x + analogX * 1000 * elapsed));
				controllerPointer.y = Math.max(0, Math.min(FlxG.height, controllerPointer.y + analogY * 1000 * elapsed));
			}
			var controllerPressed:Bool = (controls.controllerMode && controls.ACCEPT);
			//

			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V)
			{
				var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
				var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
				//trace('#${Clipboard.text.trim().toUpperCase()}');
				if(newColor != null && formattedText.length == 6)
				{
					setShaderColor(newColor);
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
					_storedColor = getShaderColor();
					updateColors();
				}
				else //errored
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
				/*onPixel = !onPixel;
				spawnNotes();
				updateNotes(true);
				FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);*/
			}

			if(hexTypeNum > -1)
			{
				var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
				hexTypeVisibleTimer += elapsed;
				var changed:Bool = false;
				if(changed = FlxG.keys.justPressed.LEFT)
					hexTypeNum--;
				else if(changed = FlxG.keys.justPressed.RIGHT)
					hexTypeNum++;
				else if(allowedTypeKeys.exists(keyPressed))
				{
					//trace('keyPressed: $keyPressed, lil str: ' + allowedTypeKeys.get(keyPressed));
					var curColor:String = alphabetHex.text;
					var newColor:String = curColor.substring(0, hexTypeNum) + allowedTypeKeys.get(keyPressed) + curColor.substring(hexTypeNum + 1);

					var colorHex:FlxColor = FlxColor.fromString('#' + newColor);
					setShaderColor(colorHex);
					_storedColor = getShaderColor();
					updateColors();
					
					// move you to next letter
					hexTypeNum++;
					changed = true;
				}
				else if(FlxG.keys.justPressed.ENTER)
					hexTypeNum = -1;
				
				var end:Bool = false;
				if(changed)
				{
					if (hexTypeNum > 5) //Typed last letter
					{
						hexTypeNum = -1;
						end = true;
						hexTypeLine.visible = false;
					}
					else
					{
						if(hexTypeNum < 0) hexTypeNum = 0;
						else if(hexTypeNum > 5) hexTypeNum = 5;
						centerHexTypeLine();
						hexTypeLine.visible = true;
					}
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
				}
				if(!end) hexTypeLine.visible = Math.floor(hexTypeVisibleTimer * 2) % 2 == 0;
			}
			else
			{
				var add:Int = 0;
				if(analogX == 0 && !changedToController) {
					if(controls.UI_LEFT_P) add = -1;
					else if(controls.UI_RIGHT_P) add = 1;
				}

				if(analogY == 0 && !changedToController && (controls.UI_UP_P || controls.UI_DOWN_P)) {
					onModeColumn = !onModeColumn;
					updateNotes();
				}
		
				if(add != 0) {
					if(onModeColumn) changeSelectionMode(add);
					else changeSelectionNote(add);
				}
				hexTypeLine.visible = false;
			}

			/*if (controls.NOTE_LEFT_P) changeSelectionNote(0, 0);
			if (controls.NOTE_DOWN_P) changeSelectionNote(0, 1);
			if (controls.NOTE_UP_P) changeSelectionNote(0, 2);
			if (controls.NOTE_RIGHT_P) changeSelectionNote(0, 3);*/

			// Copy/Paste buttons
			var generalMoved:Bool = (FlxG.mouse.justMoved || analogMoved);
			var generalPressed:Bool = (FlxG.mouse.justPressed || controllerPressed);
			if(generalMoved) {
				copyButton.color = FlxColor.WHITE;
				pasteButton.color = FlxColor.WHITE;
			}

			if(pointerOverlaps(copyButton)) {
				copyButton.color = FlxColor.YELLOW;
				if(generalPressed)
				{
					Clipboard.text = getShaderColor().toHexString(false, false);
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
					trace('copied: ' + Clipboard.text);
				}
				hexTypeNum = -1;
			} else if (pointerOverlaps(pasteButton)) {
				pasteButton.color = FlxColor.YELLOW;
				if(generalPressed)
				{
					var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
					var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
					//trace('#${Clipboard.text.trim().toUpperCase()}');
					if(newColor != null && formattedText.length == 6)
					{
						setShaderColor(newColor);
						FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
						_storedColor = getShaderColor();
						updateColors();
					}
					else //errored
						FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
				}
				hexTypeNum = -1;
			}

			// Click
			if(generalPressed)
			{
				hexTypeNum = -1;
				if (pointerOverlaps(modeNotes))
				{
					modeNotes.forEachAlive(function(note:FlxSprite) {
						if (curSelectedMode != note.ID && pointerOverlaps(note))
						{
							curSelectedMode = note.ID;
							onModeColumn = true;
							updateNotes();
							FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
						}
					});
				}
				else if (pointerOverlaps(myNotes))
				{
					myNotes.forEachAlive(function(note:NoteButton) {
						if (curSelectedNote != note.ID && pointerOverlaps(note))
						{
							curSelectedNote = note.ID;
							onModeColumn = false;
							updateNotes();
							FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
						}
					});
				}
				else if (pointerOverlaps(colorWheel)) {
					_storedColor = getShaderColor();
					holdingOnObj = colorWheel;
				}
				else if (pointerOverlaps(colorGradient)) {
					_storedColor = getShaderColor();
					holdingOnObj = colorGradient;
				}
				/*else if (pointerOverlaps(colorPalette)) {
					setShaderColor(colorPalette.pixels.getPixel32(
						Std.int((pointerX() - colorPalette.x) / colorPalette.scale.x), 
						Std.int((pointerY() - colorPalette.y) / colorPalette.scale.y)));
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
					updateColors();
				}*/
				else if(pointerY() >= hexTypeLine.y && pointerY() < hexTypeLine.y + hexTypeLine.height &&
						Math.abs(pointerX() - 1000) <= 84)
				{
					hexTypeNum = 0;
					if(alphabetHex.x - alphabetHex.offset.x + alphabetHex.width <= pointerX()) hexTypeNum++;
					if(hexTypeNum > 5) hexTypeNum = 5;
					hexTypeLine.visible = true;
					centerHexTypeLine();
				}
				else holdingOnObj = null;
			}
			// holding
			if(holdingOnObj != null)
			{
				if (FlxG.mouse.justReleased || (controls.controllerMode && controls.justReleased('accept')))
				{
					colorGradientSelector.color = FlxColor.WHITE;
					holdingOnObj = null;
					_storedColor = getShaderColor();
					updateColors();
					FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
				}
				else if (generalMoved || generalPressed)
				{
					if (holdingOnObj == colorGradient) {
						colorGradientSelector.color = FlxColor.YELLOW;
						var newBrightness = FlxMath.bound((pointerX() - colorGradient.x) / colorGradient.width, 0, 1);
						_storedColor.alpha = 1;
						if(_storedColor.brightness == 0) //prevent bug
							setShaderColor(FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness));
						else
							setShaderColor(FlxColor.fromHSB(_storedColor.hue, _storedColor.saturation, newBrightness));
						updateColors(_storedColor);
					} else if (holdingOnObj == colorWheel) {
						var center:FlxPoint = new FlxPoint(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
						var mouse:FlxPoint = pointerFlxPoint();
						var hue:Float = FlxMath.wrap(FlxMath.wrap(Std.int(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
						var sat:Float = FlxMath.bound(mouse.dist(center) / colorWheel.width*2, 0, 1);
						//trace('$hue, $sat');
						if(sat != 0) setShaderColor(FlxColor.fromHSB(hue, sat, _storedColor.brightness));
						else setShaderColor(FlxColor.fromRGBFloat(_storedColor.brightness, _storedColor.brightness, _storedColor.brightness));
						updateColors();
					}
				} 
			}
			else if(controls.RESET && hexTypeNum < 0)
			{
				if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER))
				{
					for (i in 0...3)
					{
						var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
						var color:FlxColor = ClientPrefs.defaultData.arrowRGB[curSelectedNote][i];
						switch(i)
						{
							case 0:
								getShader().r = strumRGB.r = color;
							case 1:
								getShader().g = strumRGB.g = color;
							case 2:
								getShader().b = strumRGB.b = color;
						}
						dataArray[curSelectedNote][i] = color;
					}
				}
				setShaderColor(ClientPrefs.defaultData.arrowRGB[curSelectedNote][curSelectedMode]);
				FlxG.sound.play(Paths.sound('snd_squeak'), 0.6);
				updateColors();
			}
		}
	}

	function pointerOverlaps(obj:Dynamic)
	{
		if (!controls.controllerMode) return FlxG.mouse.overlaps(obj);
		return FlxG.overlap(controllerPointer, obj);
	}

	function pointerX():Float
	{
		if (!controls.controllerMode) return FlxG.mouse.x;
		return controllerPointer.x;
	}
	function pointerY():Float
	{
		if (!controls.controllerMode) return FlxG.mouse.y;
		return controllerPointer.y;
	}
	function pointerFlxPoint():FlxPoint
	{
		if (!controls.controllerMode) return FlxG.mouse.getScreenPosition();
		return controllerPointer.getScreenPosition();
	}

	function centerHexTypeLine()
	{
		//trace(hexTypeNum);
		/*if(hexTypeNum > 0)
		{
			var letter = alphabetHex.letters[hexTypeNum-1];
			hexTypeLine.x = letter.x - letter.offset.x + letter.width;
		}
		else
		{
			var letter = alphabetHex.letters[0];
			hexTypeLine.x = letter.x - letter.offset.x;
		}*/
		hexTypeLine.x += hexTypeLine.width;
		hexTypeVisibleTimer = 0;
	}

	function changeSelectionMode(change:Int = 0) {
		curSelectedMode += change;
		if (curSelectedMode < 0)
			curSelectedMode = 2;
		if (curSelectedMode >= 3)
			curSelectedMode = 0;

		updateNotes();
		FlxG.sound.play(Paths.sound('snd_squeak'));
	}
	function changeSelectionNote(change:Int = 0, set:Int = -1) {
		if (set > -1) curSelectedNote = set;
		else curSelectedNote += change;
		if (curSelectedNote < 0)
			curSelectedNote = dataArray.length-1;
		if (curSelectedNote >= dataArray.length)
			curSelectedNote = 0;
		
		updateNotes();
		FlxG.sound.play(Paths.sound('snd_squeak'));
	}

	// alphabets
	function makeColorAlphabet(x:Float = 0, y:Float = 0):FlxText {
		var text:FlxText = new FlxText(x, y, 0, '');
		text.setFormat(Paths.font("Mars_Needs_Cunnilingus.ttf"), 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 2;
		text.antialiasing = false;
		add(text);
		return text;
	}

	// notes sprites functions
	var modeNotes:FlxTypedGroup<FlxSprite>;
	var myNotes:FlxTypedGroup<NoteButton>;
	public function spawnNotes() {
		dataArray = !onPixel ? ClientPrefs.data.arrowRGB : ClientPrefs.data.arrowRGBPixel;
		if (onPixel) PlayState.stageUI = "pixel";

		// clear groups
		modeNotes.forEachAlive(function(note:FlxSprite) {
			leMem.remove(note);
			note.kill();
			note.destroy();
		});
		myNotes.forEachAlive(function(note:NoteButton) {
			leMem.remove(note);
			note.kill();
			note.destroy();
		});
		modeNotes.clear();
		myNotes.clear();

		for (i in 0...3) {
			var newNote:FlxSprite = new FlxSprite(130 + (100 * i), 125).loadGraphic(Paths.image('settings/notemode'), true, 26, 26);
			newNote.antialiasing = false;
			newNote.setGraphicSize(85);
			newNote.updateHitbox();
			newNote.animation.add('anim', [i], 24, true);
			newNote.animation.play('anim', true);
			newNote.ID = i;
			leMem.add(newNote);
			modeNotes.add(newNote);
		}

		Note.globalRgbShaders = [];
		for (i in 0...dataArray.length) {
			Note.initializeGlobalRGBShader(i);
			var newNote:NoteButton = new NoteButton(50 + (480 / dataArray.length * i), 225, i, false);
			leMem.add(newNote);
			myNotes.add(newNote);
		}

		_storedColor = getShaderColor();
		PlayState.stageUI = "normal";
	}

	function updateNotes(?instant:Bool = false) {
		for (note in modeNotes) {
			note.color = (curSelectedMode == note.ID) ? FlxColor.YELLOW : FlxColor.WHITE;
			note.alpha = onModeColumn ? 1 : 0.5;
		}

		for (note in myNotes) {
			note.daValue = (curSelectedNote == note.ID && !onModeColumn);
			if(instant) note.animation.curAnim.finish();
		}
		updateColors();
	}

	function updateColors(specific:Null<FlxColor> = null)
	{
		var color:FlxColor = getShaderColor();
		var wheelColor:FlxColor = specific == null ? getShaderColor() : specific;
		alphabetR.text = Std.string(color.red);
		alphabetR.offset.x = alphabetR.width / 2;
		alphabetG.text = Std.string(color.green);
		alphabetG.offset.x = alphabetG.width / 2;
		alphabetB.text = Std.string(color.blue);
		alphabetB.offset.x = alphabetB.width / 2;
		alphabetHex.text = color.toHexString(false, false);
		alphabetHex.offset.x = alphabetHex.width / 2;
		alphabetHex.color = color;
		alphabetHex.borderColor = color.brightness > 0.5 ? FlxColor.BLACK : FlxColor.WHITE;

		colorWheel.color = FlxColor.fromHSB(0, 0, color.brightness);
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
		if(wheelColor.brightness != 0)
		{
			var hueWrap:Float = wheelColor.hue * Math.PI / 180;
			colorWheelSelector.x += Math.sin(hueWrap) * colorWheel.width/2 * wheelColor.saturation;
			colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height/2 * wheelColor.saturation;
		}
		colorGradientSelector.x = colorGradient.x + colorGradient.width * (color.brightness);

		var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
		switch(curSelectedMode)
		{
			case 0:
				getShader().r = strumRGB.r = color;
			case 1:
				getShader().g = strumRGB.g = color;
			case 2:
				getShader().b = strumRGB.b = color;
		}
	}

	function setShaderColor(value:FlxColor) dataArray[curSelectedNote][curSelectedMode] = value;
	function getShaderColor() return dataArray[curSelectedNote][curSelectedMode];
	function getShader() return Note.globalRgbShaders[curSelectedNote];
}


class NoteButton extends FlxSprite {
	public var daValue(default, set):Bool;
	public var rgbShader:RGBShaderReference;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var data:Int = 0;
	public function new(x:Float = 0, y:Float = 0, data:Int = 0, ?checked = false) {
		super(x, y);
		this.data = data;

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(data));
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[data];
		@:bypassAccessor {
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}

		loadGraphic(Paths.image('settings/notebuttons'), true, 33, 40);
		var fr:Array<Int> = [0+(data*4), 1+(data*4), 2+(data*4), 3+(data*4)];
		animation.add('unchecked', [fr[0]], 18, false);
		animation.add('unchecking', [fr[2],fr[3],fr[0]], 18, false);
		animation.add('checking', [fr[0],fr[1],fr[2]], 18, false);
		animation.add('checked', [fr[2]], 18, false);

		antialiasing = false;
		setGraphicSize(102);
		updateHitbox();
		ID = data;

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool {
		if(check) {
			if(animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking') {
				animation.play('checking', true);
			}
		} else if(animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking') {
			animation.play("unchecking", true);
		}
		return check;
	}

	private function animationFinished(name:String) {
		switch(name) {
			case 'checking': animation.play('checked', true);
			case 'unchecking': animation.play('unchecked', true);
		}
	}
}
