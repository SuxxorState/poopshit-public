package options;

import options.Option;

class BaseOptionsMenu extends MusicBeatSubstate {
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var smoothMenu:Int = 0;
	private var optionsArray:Array<Option>;

	private var leMem:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var memX:Array<Null<Float>> = [];
	private var memTwns:Map<Int, FlxTween> = new Map<Int, FlxTween>();
	private var disableAll:Bool = false;
	private var closeTmr:FlxTimer;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var checkboxGroup:FlxTypedGroup<Checkbutton>;
	private var grpTexts:FlxTypedGroup<FlxText>;

	private var descText:FlxText;
	public static var flicker:FlxSprite;

	public var title:String;
	public var rpcTitle:String;

	public function new() {
		super();

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if (desktop && !neko)
		DiscordClient.changePresence(rpcTitle, null);
		#end

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<FlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<Checkbutton>();
		add(checkboxGroup);

		var title:FlxText = new FlxText(0, 30, 0, title.toUpperCase());
		title.setFormat(Paths.font("DTM-Mono.ttf"), 80, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		title.scrollFactor.set();
		title.screenCenter(X);
		title.borderSize = 2;
		title.antialiasing = false;
		leMem.add(title);
		add(title);

		descText = new FlxText(25, 400, 340, "", 32);
		descText.setFormat(Paths.font("DTM-Mono.ttf"), 36, FlxColor.WHITE, LEFT);
		descText.alpha = 0.5;
		descText.angle = 30;
		descText.antialiasing = false;
		leMem.add(descText);
		add(descText);

		for (i in 0...optionsArray.length) {
			var optionText:FlxText = new FlxText(50, 0, 0, optionsArray[i].name.toUpperCase(), 48);
			optionText.setFormat(Paths.font("DTM-Mono.ttf"), 40, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			optionText.setPosition(900, (i * 1.4 * 50) + 165);
			optionText.x -= optionText.width;
			optionText.borderSize = 2;
			optionText.antialiasing = false;
			optionText.ID = i;
			leMem.add(optionText);
			grpOptions.add(optionText);

			var valueText:FlxText = new FlxText(0, 0, 0, optionsArray[i].getValue(), 48);
			valueText.setFormat(Paths.font("DTM-Mono.ttf"), 40, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			valueText.setPosition(optionText.x - (valueText.width + 50), optionText.y);
			valueText.antialiasing = false;
			valueText.borderSize = 2;
			valueText.ID = i;
			leMem.add(valueText);
			grpTexts.add(valueText);
			optionsArray[i].child = valueText; //so that it can track correctly, shut up

			if(optionsArray[i].type == 'bool') {
				valueText.visible = valueText.active = false;
				var checkbox:Checkbutton = new Checkbutton(optionText.x - 105, optionText.y);
				checkbox.daValue = (optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				leMem.add(checkbox);
				checkboxGroup.add(checkbox);
			} 

			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

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

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;
	var startingOff = true;
	var qtangle:Float = 0;
	override function update(elapsed:Float) {
		if (descText != null) {
			qtangle -= 3 * elapsed;
			descText.offset.set(Math.cos(qtangle) * 3, Math.sin(qtangle) * 3);
		}

		for (item in grpOptions.members) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			if (grpOptions.members.length > 7) {
				item.y = FlxMath.lerp(item.y, ((item.ID + smoothMenu) * 1.4 * 50) + 165, lerpVal);
				for (texts in grpTexts.members) {if (item.ID == texts.ID) {
					texts.x = item.x - (texts.width + 50);
					texts.y = item.y;
				}}
			}
		}

		if (!disableAll) {
			if (controls.UI_UP_P) changeSelection(-1);
			else if (controls.UI_DOWN_P) changeSelection(1);

			if (controls.BACK) {
				disableAll = true;
				OptionsState.instance.twnBack();
				for (i in 0...leMem.members.length) {
					var member = leMem.members[i];
		
					memTwns.set(i*2, FlxTween.tween(member, {x: memX[i*2] + 615}, 1, {ease: FlxEase.sineOut}));
					memTwns.set((i*2) + 1, FlxTween.tween(member, {alpha: 0}, 1, {ease: FlxEase.sineOut}));
				}

				ClientPrefs.saveSettings();
				closeTmr = new FlxTimer().start(1, function(tmr:FlxTimer) {close();});
				FlxG.sound.play(Paths.sound('back'));
			}

			if(nextAccept <= 0) {
				var usesCheckbox = true;
				if(curOption.type != 'bool')
				{
					usesCheckbox = false;
				}

				if(usesCheckbox)
				{
					if(controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('confirm'));
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						reloadCheckboxes();
					}
				} else {
					if(controls.UI_LEFT || controls.UI_RIGHT) {
						var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
						if(holdTime > 0.5 || pressed) {
							if(pressed) {
								var add:Dynamic = null;
								if(curOption.type != 'string') {
									add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
								}

								switch(curOption.type)
								{
									case 'int' | 'float' | 'percent':
										holdValue = curOption.getValue() + add;
										if(holdValue < curOption.minValue) holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

										switch(curOption.type)
										{
											case 'int':
												holdValue = Math.round(holdValue);
												curOption.setValue(holdValue);

											case 'float' | 'percent':
												holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
												curOption.setValue(holdValue);
										}

									case 'string':
										var num:Int = curOption.curOption; //lol
										if(controls.UI_LEFT_P) --num;
										else num++;

										if(num < 0) {
											num = curOption.options.length - 1;
										} else if(num >= curOption.options.length) {
											num = 0;
										}

										curOption.curOption = num;
										curOption.setValue(curOption.options[num]); //lol
										//trace(curOption.options[num]);
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('select'));
							} else if(curOption.type != 'string') {
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

								switch(curOption.type)
								{
									case 'int':
										curOption.setValue(Math.round(holdValue));
									
									case 'float' | 'percent':
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
								}
								updateTextFrom(curOption);
								curOption.change();
							}
						}

						if(curOption.type != 'string') {
							holdTime += elapsed;
						}

						grpTexts.members[curSelected].x = grpOptions.members[curSelected].x - (grpTexts.members[curSelected].width + 50);
						for (i in 0...leMem.members.length) if (memX[i*2] != leMem.members[i].x) memX[i*2] = leMem.members[i].x;

					} else if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
						clearHold();
					}
				}

				if(controls.RESET)
				{
					for (i in 0...optionsArray.length)
					{
						var leOption:Option = optionsArray[i];
						leOption.setValue(leOption.defaultValue);
						if(leOption.type != 'bool')
						{
							if(leOption.type == 'string')
							{
								leOption.curOption = leOption.options.indexOf(leOption.getValue());
							}
							updateTextFrom(leOption);
						}
						leOption.change();
					}
					FlxG.sound.play(Paths.sound('cancelMenu'));
					reloadCheckboxes();
				}
			}

			if(nextAccept > 0) {
				nextAccept -= 1;
			}
		}

		super.update(elapsed);
	}

	function updateTextFrom(option:Option) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == 'percent') val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if(holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('select'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		if (curSelected > optionsArray.length - 8)
			smoothMenu = curSelected - (optionsArray.length - 7);
		else
			smoothMenu = 0;

		descText.text = optionsArray[curSelected].description.toLowerCase().replace(', ', '\n').replace('.', '').replace('!', '').replace('?', '');

		var bullShit:Int = 0;
		var secondBullshit:Int = 0;

		for (item in grpOptions.members) {
			item.ID = bullShit - curSelected;
			item.visible = true;
			bullShit++;

			if (item.ID == 0) item.color = FlxColor.YELLOW;
			else if (((item.ID < -(7 - (optionsArray.length - curSelected)) && curSelected > optionsArray.length - 9) || ((item.ID < 0 || item.ID > 6) && curSelected <= optionsArray.length - 7)) && grpOptions.members.length > 7) item.visible = false;
			else item.color = FlxColor.WHITE;
		}

		for (text in grpTexts.members) {
			text.ID = secondBullshit - curSelected;
			text.visible = text.active;
			secondBullshit++;

			if (text.ID == 0) text.color = FlxColor.YELLOW;
			else if (((text.ID < -(7 - (optionsArray.length - curSelected)) && curSelected > optionsArray.length - 9) || ((text.ID < 0 || text.ID > 6) && curSelected <= optionsArray.length - 7)) && grpOptions.members.length > 7) text.visible = false;
			else text.color = FlxColor.WHITE;
		}

		curOption = optionsArray[curSelected]; //shorter lol
		if (change != 0) FlxG.sound.play(Paths.sound('select'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}


class Checkbutton extends FlxSprite {
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public function new(x:Float = 0, y:Float = 0, ?checked = false) {
		super(x, y);

		loadGraphic(Paths.image('settings/checkbutton'), true, 15, 18);
		animation.add('unchecked', [0], 18, false);
		animation.add('unchecking', [2,3,0], 18, false);
		animation.add('checking', [0,1,2], 18, false);
		animation.add('checked', [2], 18, false);

		antialiasing = false;
		setGraphicSize(Std.int(3 * width));
		updateHitbox();

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x - (width + 50), sprTracker.y + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
			visible = sprTracker.visible;
		}
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