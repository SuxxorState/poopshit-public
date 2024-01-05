package objects;

import flixel.system.FlxAssets;
import flixel.math.FlxRandom;
import openfl.media.Sound;

private var controls(get, never):Controls;
private function get_controls() return Controls.instance;

enum Alignment {
	LEFT;
	CENTERED;
	RIGHT;
}

class UnderText extends FlxSpriteGroup {
	public var text(default, set):String;
	public var letters:Array<TxtLetter> = [];

	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;

	public var shakeEntire:Bool = false;
	public var shakeLetters:Bool = false;

	public var letterSpacing:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

    public var sprTracker:FlxSprite;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(x:Float, y:Float, text:String = "") {
		super(x, y);
		
		this.startPosition.set(x,y);
		this.text = text;
	}

	public function setAlignmentFromString(align:String) {
		switch(align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(align:Alignment) {
		alignment = align;
		updateAlignment();
		return align;
	}

	private function updateAlignment() {
		for (letter in letters) {
			var newOffset:Float = 0;
			switch(alignment) {
				case CENTERED:
					newOffset = letter.rowWidth / 2;
				case RIGHT:
					newOffset = letter.rowWidth;
				default:
					newOffset = 0;
			}
	
			letter.offset.x -= letter.alignOffset;
			letter.alignOffset = newOffset * scale.x;
			letter.offset.x += letter.alignOffset;
		}
	}

	private function set_text(newText:String) {
		newText = newText.replace('\\n', '\n');
		clearLetters();
		createLetters(newText);
		updateAlignment();
		this.text = newText;
		return newText;
	}

	public function clearLetters() {
		var i:Int = letters.length;
		while (i > 0) {
			--i;
			var letter:AlphaCharacter = letters[i];
			if(letter != null) {
				letter.kill();
				letters.remove(letter);
				remove(letter);
			}
		}
		letters = [];
		rows = 0;
	}

	public function setScale(newX:Float, newY:Null<Float> = null) {
		var lastX:Float = scale.x;
		var lastY:Float = scale.y;
		if(newY == null) newY = newX;
		@:bypassAccessor
			scaleX = newX;
		@:bypassAccessor
			scaleY = newY;

		scale.x = newX;
		scale.y = newY;
		softReloadLetters(newX / lastX, newY / lastY);
	}

	private function set_scaleX(value:Float) {
		if (value == scaleX) return value;

		var ratio:Float = value / scale.x;
		scale.x = value;
		scaleX = value;
		softReloadLetters(ratio, 1);
		return value;
	}

	private function set_scaleY(value:Float) {
		if (value == scaleY) return value;

		var ratio:Float = value / scale.y;
		scale.y = value;
		scaleY = value;
		softReloadLetters(1, ratio);
		return value;
	}

	public function softReloadLetters(ratioX:Float = 1, ratioY:Null<Float> = null) {
		if(ratioY == null) ratioY = ratioX;

		for (letter in letters) if(letter != null) letter.setupAlphaCharacter((letter.x - x) * ratioX + x,(letter.y - y) * ratioY + y);
	}

	var maxPos:Float = 1;
	var posAmt:Float = 0.5;
	var trackPos:Array<Float> = [0,0];
	var trackAll:Array<Array<Float>> = [];
	override function update(elapsed:Float) {
		if (isMenuItem) {
			var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
			if(changeX)
				x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if(changeY)
				y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
		}

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 30, sprTracker.y + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
			visible = sprTracker.visible;
		}

		if (FlxG.random.bool(80) && shakeEntire) {
			var moveAmtX:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
			var moveAmtY:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
			if (FlxG.random.bool(50)) {
				if (trackPos[0] == maxPos && moveAmtX == posAmt)
					moveAmtX = -posAmt;
				if (moveAmtX == -posAmt && trackPos[0] == -maxPos)
					moveAmtX = posAmt;
				trackPos[0] += moveAmtX;
				x += moveAmtX;
			}
			if (FlxG.random.bool(50)) {
				if (trackPos[1] == maxPos && moveAmtY == posAmt)
					moveAmtY = -posAmt;
				if (trackPos[1] == -maxPos && moveAmtY == -posAmt)
					moveAmtY = posAmt;
				trackPos[1] += moveAmtY;
				y += moveAmtY;
			}
		} else if (FlxG.random.bool(80) && shakeLetters) {
			for (i in 0...letters.length) {
				var moveAmtX:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
				var moveAmtY:Float = FlxG.random.bool(50) ? -posAmt : posAmt;
				var letter = letters[i];
				trackAll[i] = [0,0];
				if (FlxG.random.bool(50)) {
					if (trackAll[i][0] == maxPos && moveAmtX == posAmt)
						moveAmtX = -posAmt;
					if (moveAmtX == -posAmt && trackAll[i][0] == -maxPos)
						moveAmtX = posAmt;
					trackAll[i][0] += moveAmtX;
					letter.x += moveAmtX;
				}
				if (FlxG.random.bool(50)) {
					if (trackAll[i][1] == maxPos && moveAmtY == posAmt)
						moveAmtY = -posAmt;
					if (trackAll[i][1] == -maxPos && moveAmtY == -posAmt)
						moveAmtY = posAmt;
					trackAll[i][1] += moveAmtY;
					letter.y += moveAmtY;
				}
			}
		}

		super.update(elapsed);
	}

	public function snapToPosition() {
		if (isMenuItem) {
			if(changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if(changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	private static var Y_PER_ROW:Float = 85;

	private function createLetters(newText:String) {
		var consecutiveSpaces:Int = 0;

		var xPos:Float = 0;
		var rowData:Array<Float> = [];
		rows = 0;
		for (character in newText.split('')) {	
			if(character != '\n') {
				var spaceChar:Bool = (character == " " || (bold && character == "_"));
				if (spaceChar) consecutiveSpaces++;

				var isAlphabet:Bool = AlphaCharacter.isTypeAlphabet(character.toLowerCase());
				if (AlphaCharacter.allLetters.exists(character.toLowerCase()) && (!bold || !spaceChar))
				{
					if (consecutiveSpaces > 0)
					{
						xPos += 28 * consecutiveSpaces * scaleX;
						if(!bold && xPos >= FlxG.width * 0.65)
						{
							xPos = 0;
							rows++;
						}
					}
					consecutiveSpaces = 0;

					var letter:AlphaCharacter = cast recycle(AlphaCharacter, true);
					letter.scale.x = scaleX;
					letter.scale.y = scaleY;

					letter.setupAlphaCharacter(xPos, rows * Y_PER_ROW * scale.y, character, bold);
					@:privateAccess letter.parent = this;

					letter.row = rows;
					var off:Float = 0;
					if(!bold) off = 2;
					xPos += letter.width + (letter.letterOffset[0] + off) * scale.x;
					rowData[rows] = xPos;

					add(letter);
					letters.push(letter);
				}
			} else {
				xPos = 0;
				rows++;
			}
		}

		for (letter in letters) {
			letter.rowWidth = rowData[letter.row];
		}

		if(letters.length > 0) rows++;
	}
}


class TxtLetter extends FlxText {

}

class UTTypeText extends FlxText {
	public var delay:Float = 0.05;
	public var eraseDelay:Float = 0.02;
	var trueDelay:Float = 0.05;
	public var showCursor:Bool = false;
	public var cursorCharacter:String = "|";
	public var cursorBlinkSpeed:Float = 0.5;
	public var prefix:String = "";
	public var autoErase:Bool = false;
	public var waitTime:Float = 1.0;
	public var paused:Bool = false;
	public var sounds:Array<FlxSound>;
	public var finishSounds = false;
	public var canSkip:Bool = true;
	public var completeCallback:Void->Void;
	public var eraseCallback:Void->Void;
    
	var _finalText:String = "";
	var _timer:Float = 0.0;
	var _waitTimer:Float = 0.0;
	var _length:Int = 0;
	var _typing:Bool = false;
	var _erasing:Bool = false;
	var _waiting:Bool = false;
	var _cursorTimer:Float = 0.0;
	var _typingVariation:Bool = false;
	var _typeVarPercent:Float = 0.5;
	static var helperString:String = "";
	var _sound:FlxSound;

    var _ignoreCharacters:Array<String> = ["`", "~", "!", "*", "(", ")", "-", "_", "=", "+", "{", "}", "[", "]", '"', "'", "\\", "|", ":", ";", ",", "<", ".", ">", "/", "?", "^", " "];
	var _punctuationChars:Array<String> = [".", ",", "!", "?", ":", ";"];

	public function new(X:Float, Y:Float, Width:Int, Text:String, Font:String, Size:Int = 8, Color:FlxColor = FlxColor.WHITE) {
		super(X, Y, Width);
		_finalText = Text;
        setFormat(Paths.font(Font), Size, Color, LEFT);
        antialiasing = false;
        scrollFactor.set();
	}

	public function start(?Delay:Float, ForceRestart:Bool = false, AutoErase:Bool = false, ?Callback:Void->Void):Void {
		if (Delay != null) delay = Delay;

		_typing = true;
		_erasing = false;
		paused = false;
		_waiting = false;

		if (ForceRestart) {
			text = "";
			_length = 0;
		}

		autoErase = AutoErase;

		if (Callback != null) completeCallback = Callback;

		insertBreakLines();

        if (sounds == null) sounds = [FlxG.sound.load(Paths.sound('dialogue/txt_none', 'overworld'), 0.8)];
	}

	override public function applyMarkup(input:String, rules:Array<FlxTextFormatMarkerPair>):FlxText {
		super.applyMarkup(input, rules);
		resetText(text);
		return this;
	}

	function insertBreakLines() {
		var saveText = text;

		var last = _finalText.length;
		var n0:Int = 0;
		var n1:Int = 0;

		while (true) {
			last = _finalText.substr(0, last).lastIndexOf(" ");

			if (last <= 0)
				break;

			text = prefix + _finalText;
			n0 = textField.numLines;

			var nextText = _finalText.substr(0, last) + "\n" + _finalText.substr(last + 1, _finalText.length);

			text = prefix + nextText;
			n1 = textField.numLines;

			if (n0 == n1) _finalText = nextText;
		}

		text = saveText;
	}

	public function erase(?Delay:Float, ForceRestart:Bool = false, ?Callback:Void->Void):Void {
		_erasing = true;
		_typing = false;
		paused = false;
		_waiting = false;

		if (Delay != null) eraseDelay = Delay;

		if (ForceRestart) {
			_length = _finalText.length;
			text = _finalText;
		}

		eraseCallback = Callback;
	}

	public function resetText(Text:String):Void {
		text = "";
		_finalText = Text;
		_typing = false;
		_erasing = false;
		paused = false;
		_waiting = false;
		_length = 0;
		trueDelay = delay;
	}

	public function setTypingVariation(Amount:Float = 0.5, On:Bool = true):Void {
		_typingVariation = On;
		_typeVarPercent = FlxMath.bound(Amount, 0, 1);
	}

	function onComplete():Void {
		_timer = 0;
		_typing = false;

		if (sounds != null) {
			for (sound in sounds) sound.stop();
		}

		if (completeCallback != null) completeCallback();

		if (autoErase && waitTime <= 0) _erasing = true;
		else if (autoErase) {
			_waitTimer = waitTime;
			_waiting = true;
		}
	}

	function onErased():Void {
		_timer = 0;
		_erasing = false;

		if (eraseCallback != null) eraseCallback();
	}

	override public function update(elapsed:Float):Void {
		#if FLX_KEYBOARD
		if (canSkip && controls.DIA_SKIP) skip();
		#end

		if (_waiting && !paused) {
			_waitTimer -= elapsed;

			if (_waitTimer <= 0) {
				_waiting = false;
				_erasing = true;
			}
		}

		if (!_waiting && !paused && ((_length < _finalText.length && _typing) || (_length > 0 && _erasing)))
			_timer += elapsed;

		if (_typing || _erasing) {
			if (_typing && _timer >= trueDelay) {
				_length += Std.int(_timer / trueDelay);
				if (_length > _finalText.length)
					_length = _finalText.length;
			}

			if (_erasing && _timer >= eraseDelay) {
				_length -= Std.int(_timer / eraseDelay);
				if (_length < 0)
					_length = 0;
			}

			if ((_typing && _timer >= trueDelay) || (_erasing && _timer >= eraseDelay)) {
				if (_punctuationChars.contains(_finalText.charAt(_length - 2)) && !_punctuationChars.contains(_finalText.charAt(_length - 1)) && !_punctuationChars.contains(_finalText.charAt(_length)) && _length > 1)
					trueDelay = 0.3;
				else 
					trueDelay = _erasing ? eraseDelay : delay;
				
				if (_typingVariation)
					_timer = FlxG.random.float(-trueDelay * _typeVarPercent / 2, trueDelay * _typeVarPercent / 2);
				else 
					_timer %= trueDelay;

                if (!_ignoreCharacters.contains(_finalText.charAt(_length - 1)) && sounds != null) {
                    if (!finishSounds) for (sound in sounds) sound.stop();
                    FlxG.random.getObject(sounds).play(!finishSounds);
                }
			}
		}

		helperString = prefix + _finalText.substr(0, _length);

		if (showCursor) {
			_cursorTimer += elapsed;

			var isBreakLine = (prefix + _finalText).charAt(helperString.length) == "\n";

			if (_cursorTimer > cursorBlinkSpeed / 2 && !isBreakLine) helperString += cursorCharacter.charAt(0);

			if (_cursorTimer > cursorBlinkSpeed) _cursorTimer = 0;
		}

		if (helperString != text) {
			text = helperString;

			if (_length >= _finalText.length && _typing && !_waiting && !_erasing) onComplete();

			if (_length == 0 && _erasing && !_typing && !_waiting) onErased();
		}

		super.update(elapsed);
	}

	public function skip():Void {
		if (_erasing || _waiting) {
			_length = 0;
			_waiting = false;
		} else if (_typing) _length = _finalText.length;
	}
}