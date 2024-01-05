package objects;

private var npcShit:Map<String, Array<Dynamic>> = [//spr size, freeplay offsets (dont set if it doesnt exist!), anims => put %dir for all directions and then chain all 4 dir anims in order. fps can still be read at the end
    '' => [[25,32, 0,0], ['freepoop', [35]], ['idle', [35]]], //bogus filler so blanks dont crash
    'sans' => [[25,32, 0.5,-17], ['freepoop', [30]], ['sleep', [31,32], 1], ['laugh', [28,29]], ['wink', [27]], ['no-eyes', [26]], ['idle-%dir', [9],[0],[3],[6]], ['walk-%dir', [10,9,11,9],[1,0,2,0],[4,3,5,3],[7,6,8,6]], ['icecream', [18,19,20,21,22,23,24,25]]],
    'sans-lounge' => [[49,43], ['idle', [5]], ['comb', [0,1,2,3,4]], ['file', [15,16]], ['sunglasses', [18]], ['tanner', [17]]],
    'papyrus' => [[27,44, 0.5,-9], ['freepoop', 0], ['idle', [1]], ['idle-mad', [2]], ['stomp', [3,4,6]], ['stomp-fast', [3,4,5], 12], ['cape', [7,8,9,10,11]], ['cape-sunglasses', [12,13,14,15,16]]],
    'gaster' => [[22,52, -1,-6], ['freepoop', [0]], ['idle', [0]], ['disappear', [1]]],
    'papyrus-exe' => [[27,44, 0.5,-9], ['freepoop', [14]], ['normal-%dir', [4],[0],[8],[12]], ['idle-%dir', [5],[1],[12],[9]], ['laugh-%dir', [6,7],[2,3],[13,12],[10,11], 8]]
];
private var dirs:Array<String> = ['left', 'down', 'up', 'right'];
private var fps:Int = 6;

class NonPlayerCharacter extends FlxSprite {
    public var current(default, set):String = "";
    public var curDir(default, set):Int = 1;
    static var storedshit:Array<Dynamic> = [];
    private var data:Array<Dynamic> = [];

    var freeOffset:FlxPoint = new FlxPoint(0,0);
    public var midpoint:FlxPoint = new FlxPoint(0,0);

    public function new(char:String = 'sans', x:Float = 0, y:Float = 0) {
        antialiasing = false;
        super(x,y);
        current = char;
    }

    static var prevAnim:String = '';
    function set_current(newChar:String) {
        data = npcShit.get(newChar);
        if (newChar == '') newChar = 'sans';
        if (animation.curAnim != null) prevAnim = animation.curAnim.name;

        loadGraphic(Paths.image('characters/$newChar', 'overworld'), true, data[0][0], data[0][1]);
        for (i in 1...data.length) {
            var str:String = data[i][0];
            var fr:Array<Int> = data[i][1];
            var chfps:Int = data[i][Std.int(data[i].length - 1)] is Int ? data[i][Std.int(data[i].length - 1)] : fps; //whole bunch of nonsense vars cause haxe doesnt like dynamics

            if (str.contains('%dir')) {for (d in 0...dirs.length)  {
                var dirfr:Array<Int> = data[i][d + 1];
                animation.add(str.replace('%dir', dirs[d]), dirfr, chfps);
            }} else if (str != null && fr != null) animation.add(str, fr, chfps);
        }
        if (data[0][2] != null && data[0][3] != null) freeOffset.set(data[0][2] * 3, data[0][3] * 3);
        midpoint = getGraphicMidpoint();
        if (animation.getByName(prevAnim) != null) playAnim(prevAnim); //for like. freeplay.

        return newChar;
    }

    function set_curDir(newDir:Int) {
        var anim:String = animation.curAnim.name;

        for (dir in dirs) if (anim.contains(dir)) anim.replace(dir, dirs[newDir]);
        if (animation.getByName(anim) != null) animation.play(anim, true, false, animation.curAnim.curFrame);

        return newDir;
    }

    public function playAnim(animName:String, ?dir:Dynamic) {
        var facing:String = '';
        if (dir != null) {//weird direction code so that you can put an int or a string and it recognizes both
            if (dir is Int) facing = dirs[dir];
            else if (dir is String) facing = '-$dir';
        }

        animation.play(animName + facing, true);

        if(animName.startsWith('freepoop')) offset = freeOffset;
        else offset.set(0,0);
        
        for (i in 0...dirs.length) if (animation.curAnim != null && animation.curAnim.name.endsWith('-${dirs[i]}') && curDir != i) curDir = i; //checks to see if the direction changed. useful for if animName includes a direction.
    }

    public function playRandomAnim() {
        var animArray:Array<String> = [];
        for (i in 1...data.length) {
            var anim:String = data[i][0];
            if (anim.contains('%dir')) {
                for (d in dirs) animArray.push(anim.replace('%dir', d));
            } else animArray.push(anim);
        }
        animArray.remove('freepoop');

        animation.play(animArray[FlxG.random.int(0, animArray.length - 1)]);
    }

    override public function setGraphicSize(w:Float = 0, h:Float = 0) {
        super.setGraphicSize(Std.int(w), Std.int(h));
        super.updateHitbox();
    }
}