package backend;

enum DiaTypes {
	REGULAR;
    INTERACT;
    COMPLETE;
	DEATH;
	FLEE;
	FUN;
}

class Dialogue {
    public static function get(room:String, event:DiaTypes = REGULAR, ?index:Int):Array<Dynamic> {
        var shitass:Array<Dynamic> = [];
        if (overworld.exists(Paths.formatToSongPath(room)) && overworld.get(Paths.formatToSongPath(room)).exists(event)) 
            shitass = overworld.get(Paths.formatToSongPath(room)).get(event);
        
        if (shitass == null || shitass == [] || shitass.length < 1) 
            return fillerText();
        else if (index != null && index >= 0) {
            if (index >= shitass.length) index = shitass.length - 1;
            return shitass[index];
        } else 
            return shitass;
    }

    public static function getDead(name:String):Array<String> {
        var char:String = name.toLowerCase();
        if (char == null || char.length < 1) char = 'asgore';
        if (CoolUtil.isRecording() && gameOver.exists(char + '-rec') && FlxG.random.bool()) char += '-rec';

        var dia:Array<Array<String>> = gameOver.exists(char) ? gameOver.get(char) : gameOver.get('asgore');
        var cool:Array<String> = [];
        for (i in dia[FlxG.random.int(0, dia.length - 1)]) {
            if (i.contains('[PLAYER_NAME]')) cool.push(i.replace('[PLAYER_NAME]', ClientPrefs.data.charName.toUpperCase()));
            else cool.push(i);
        }

        return cool;
    }
    
    public static function getCall(name:String, room:String):Array<Dynamic> {
        var fucked:Array<Dynamic> = [];
        var charVars:Array<Dynamic> = charShit.get(name); 
        var callVars:Array<Int> = callStats.get(charVars[0]);

        var realRoom:String = Paths.formatToSongPath(room);
        if (charVars[1] == false) realRoom = '';
        var roomInt:Int = 0;
        if (realRoom != '') roomInt = roomShit.get(realRoom);

        if (phoneCalls.exists(realRoom) && phoneCalls.get(realRoom).exists(charVars[0])) 
            fucked = phoneCalls.get(realRoom).get(charVars[0])[callVars[roomInt]];

        if (fucked == null || fucked.length < 1) fucked = fillerText(true);

        return fucked;
    }

    public static function setCall(name:String, room:String) {
        var charVars:Array<Dynamic> = charShit.get(name); 
        var callVars:Array<Int> = callStats.get(charVars[0]);

        var realRoom:String = Paths.formatToSongPath(room);
        if (charVars[1] == false) realRoom = '';

        if (!phoneCalls.exists(realRoom) || !phoneCalls.get(realRoom).exists(charVars[0])) return;

        var roomInt:Int = 0;
        if (realRoom != '') roomInt = roomShit.get(realRoom);

        callVars[roomInt]++;
        if (callVars[roomInt] >= phoneCalls.get(realRoom).get(charVars[0]).length) callVars[roomInt] = phoneCalls.get(realRoom).get(charVars[0]).length - 1;
    }
    
    public static function getCharData(char:String):CharOptions {
        var options:CharOptions;
        if (charData.exists(char))
            options = charData.get(char);
        else
            options = {gridSize: [0,0], typeFont: '8bitoperator_jve.ttf', fontSizeMult: 1.5, sbAmt: 1, soundByte: 'txt_narrate'};

        if (options.gridSize == null) options.gridSize = [0,0];
        if (options.typeFont == null) options.typeFont = '8bitoperator_jve.ttf';
        if (options.fontSizeMult == null) options.fontSizeMult = (options.typeFont == '8bitoperator_jve.ttf' ? 1.5 : 1);
        if (options.sbAmt == null) options.sbAmt = 1;
        if (options.soundByte == null) options.soundByte = 'txt_narrate';
        if (options.asterisk == null) options.asterisk = true;

        return options;
    }
    
    static var charData:Map<String, CharOptions> = [//add new characters here!
        '' => {gridSize: [0,0], typeFont: '8bitoperator_jve.ttf', fontSizeMult: 1.5, sbAmt: 1, soundByte: 'txt_narrate'},
        'bf' => {gridSize: [50,50], typeFont: 'PhantomMuff Full Letters.ttf', fontSizeMult: 1.2, sbAmt: 5},
        'poopshitter' => {gridSize: [50,50], typeFont: 'undertale-comic-sans-overworld.ttf', fontSizeMult: 1.2, soundByte: 'Sans Dialogue'},
        'peepisser' => {gridSize: [50,50], typeFont: 'papyrus-font-undertale.ttf', fontSizeMult: 1.4, soundByte: 'Piss', asterisk: false},
        'pico' => {gridSize: [50,50], typeFont: 'PIXEAB__.TTF', fontSizeMult: 0.9, sbAmt: 36},
        'saul' => {gridSize: [92,105]},
        'gf' => {typeFont: 'PhantomMuff Full Letters.ttf', fontSizeMult: 1.2, sbAmt: 3},
        'asgore' => {soundByte: 'Assgore'},
    ];

    static var callStats:Map<String, Array<Int>> = [//seek to roomShit for room ints
        'gf' => [],
        'pico' => [],
        'toriel' => [],
        'saul' => [],
        'papyrus' => [],
    ];

    static var charShit:Map<String, Array<Dynamic>> = [//character name in phone list => character name, has room-specific dialogue
        'CUTIEPIE <3' => ['gf', true],
        'PAPI' => ['pico', true],
        'Saul' => ['saul', false],
        'Goat Mama' => ['toriel', false],
        'Skeletor' => ['papyrus', true],
    ];

    static var roomShit:Map<String, Int> = [//for callStats. must be greater than or equal to 0 since its used in an array.
        'last-corridor' => 0,
        'gaster-room' => 1
    ];

    static var overworld:Map<String, Map<DiaTypes, Array<Dynamic>>> = [
        'throne-hallway' => [
            REGULAR => [
                ["", 0, "Ring. . .  Ring. . ."],
                ["poopshitter", 3, "yo it's me again"],
                ["bf", 2, "Who is this..."],
                ["poopshitter", 4, "u are a fucking idiot"],
                ["poopshitter", 0, "we just fought"],
                ["bf", 15, "Ooooooooooooohhhhhhhhhhhhhhhhhhhhhhhhh"],
                ["poopshitter", 5, "anyways your phone's gonna explode"],
                ["bf", 0, "What??"],
                ["poopshitter", 1, "ok don't be mad..."],
                ["poopshitter", 14, "but i kinda planted a bomb in ur phone lmfao"],
                ["bf", 19, "Are u fucking serious"],
                ["poopshitter", 1,  "u should be able to die in 3...-"],
                ["poopshitter", 1,  "2...-"],
                ["poopshitter", 1,  "1...-"],
            ],

            INTERACT => [
                [["" , 0, "THRONE ROOM"]],

                [["" , 0, "There's a note here..."],
                ["poopshitter" , -1, "haha no sequel for you"],
                ["poopshitter" , -1, "love, sans"],
                ["bf" , 0, "Is bro stupid"]],
            ],

            COMPLETE => [[
                ["poopshitter" , 10, "you dirty cheater."],
                ["bf" , 0, "Kys"]
            ]],

            FUN => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["poopshitter", 3, "hey i called to say"],
                ["poopshitter", 4, "i didn't like how you were looking at me"],
                ["bf", 2, "Yeah no shit you were taking too long"],
                ["poopshitter", 4, "well that sucks"],
                ["poopshitter", 0, "cause during that time i put a bomb in your phone"],
                ["bf", 19, "What-"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["poopshitter", 3, "hey since you took too long i planted a bomb in your phone"],
                ["bf", 2, "How the fuck does that work"],
                ["poopshitter", 4, "you'll find out shortly"],
                ["poopshitter", 0, "next time don't do a low% dumbass"],
                ["bf", 19, "Damn it-"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["poopshitter", 2, "hey its sans undertale"],
                ["poopshitter", 3, "am i glad that you're in there-"],
                ["poopshitter", 0, "and that im out here and that you're frozen out here-"],
                ["poopshitter", 1, "and i just remembered"],
                ["poopshitter", 7, "you never scratched my nuts"],
                ["bf", 0, "Yeah that shit gross mane"],
                ["poopshitter", 6, "your balls shall detonate in a couple of seconds"],
                ["poopshitter", 5, "L bozo"],
                ["bf", 19, "fuck-"]],
            ],
        ],

        'last-corridor' => [
            REGULAR => [
                ["poopshitter", 3, "what's good"],
                ["bf", 11, "Hi"],
                ["poopshitter", 7, "u killed eveoyne"],
                ["bf", 0, "(Jacks off)", "jackoff"],
                ["poopshitter", 3, "ok"]
            ],
            
            DEATH => [
                [["poopshitter", 1, "bro died"],
                ["bf", 5, "stfu"],
                ["poopshitter", 13, "all that aggression and for what"],
                ["bf", 0, "My fault origins;l"]],
                
                [["poopshitter", 5, "i think ur bad"],
                ["bf", 17, ""],
                ["poopshitter", 12, "har har har har har"]],
                        
                [["poopshitter", 3, "hmm. that expression..."],
                ["poopshitter", 1, "that's the expression of someone whose died thri-"],
                ["bf", 0, "", null, "Fart_Reverb"],
                ["poopshitter", 3, "ur genuinely so fucking unfunny like it's actually unreal-"]],
                                
                [["poopshitter", 5, "hi it's me sans"],
                ["bf", 11, "Who?"],
                ["poopshitter", 15, "", null, "Vine_Boom"]],
                                        
                [["poopshitter", 0, "u sure u don't just wanna see the dialogue or are u just bad?"],
                [true, "YES", "NO"],
                [["poopshitter", 0, "don't care didn't ask", "evileye"]],
                [["poopshitter", 0, "don't care didn't ask", "evileye"]]],
                                        
                [["bf", 11, "Can u just move out of the way"],
                ["poopshitter", 5, "what's the point of the mod then?"],
                ["bf", 4, "True"]],
                                                
                [["poopshitter", 7, "dawg i'm gettin real tired of you"],
                ["bf", 17, "U probably own an samsung monitor bro shut up"],
                ["poopshitter", 3, "l bozo ig"]],
                                                
                [["poopshitter", 5, "nice cook"],
                ["bf", 0, "S-Sans..."],
                ["poopshitter", 0, '${FlxG.random.int(0,999)}.${FlxG.random.int(0,999)}.${FlxG.random.int(0,999)}.${FlxG.random.int(0,999)}', "evileye"],
                ["bf", 8, ""]],
                                                        
                [["poopshitter", 0, "poop"],
                ["bf", 16, "I think that's a bit much"],
                ["poopshitter", 0, "someone had to say it", "evileye"]],
                                                        
                [["poopshitter", 14, "ok no more dialogue"],
                ["bf", 11, "lame"]]
            ],

            COMPLETE => [["poopshitter", 13, "unlucky"]],

            FLEE => [
                [["poopshitter", 14, "ez dub"]],
                [["poopshitter", 11, "", null, "bttb"]]
            ],

            FUN => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["", 0, "Hey guys, its me whire!"],
                ["", 0, "Yknow, the poopshitters guy or whatever"],
                ["", 0, "Ima be real i have no idea why tf i called"],
                ["", 0, "I kinda just wanted to make a cringey self insert and waste ur time"],
                ["", 0, "See ya!"],
                ["", 0, "(Click. . .)"]],

                [["poopshitter", 4, "my nuts itch..."],
                ["poopshitter", 1, "can u scratch them for me?"],
                [true, "YES", "NO"],
                [["poopshitter", 3, "thanks"]],
                [["poopshitter", 10, "kill yours-"]]],
            
                [["", 0, "Ring . . . Ring . . ."],
                ["poopshitter", 1, "got bored waiting so i left"],
                ["bf", 17, ""],
                ["", 0, "(Click. . .)"]],
            
                [["poopshitter", -1, "oh... hey."],
                ["poopshitter", -1, "i didn't expect you to come here so early,"],
                ["poopshitter", 3, "i was just about to finish this cone, do you mind?"],
                ["bf", 0, "It's all good man take your time"]],

                [["poopshitter", 6, "refreshing..."],
                ["poopshitter", 1, "oh yeah, rap battle, mb"]],
            
                [["poopshitter", 1, "yo this pillars so cool"],
                ["poopshitter", 3, "i sure do wonder when that midget shithead will show up"],
                ["bf", 6, "Dawg I'm literally right here"],
                ["poopshitter", 13, "it's like i can still hear them"]]
            ],
        ],

        'gaster-room' => [],
    ];

    static var phoneCalls:Map<String, Map<String, Array<Dynamic>>> = [
        '' => [// for all the non-room specific calls
            'saul' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["saul", 2, "Hi I'm Saul Goodman, did you know that you have rights?"],
                ["saul", 0, "Constitution says you do, and so do I."],
                ["saul", 1, "I believe that until proven guilty,"],
                ["saul", 1, "every man, woman and child in this country is innocent."],
                ["saul", 3, "And THAT'S why I fight for you, Albuquerque!"],
                ["saul", 2, "Better Call Saul!"],
                ["bf", 17, ""],
                ["", 0, "(Click. . .)"]]
            ],

            'toriel' => [
                [["", 0, "Dialing. . ."],
                ["", 0, ". . ."],
                ["", 0, "But Nobody Came."]]
            ]
        ],

        'last-corridor' => [
            'gf' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["gf", 0, "OMG Boyfriend hiii!~"],
                ["gf", 0, "Where the fuck are you dawg? You've been missing for like"],
                ["gf", 0, "97589 days"],
                [true, "I'm lost", "I don't know"],
                [["bf", 6, "I'm lost dawg"],
                ["gf", 0, "Is your dumbass in another shitty ass FNF mod?"],
                ["gf", 0, "I'm on my way!"],
                ["gf", 0, "Expect me in 3 years!"],
                ["bf", 8, "Why tf would it take u so long?"],
                ["gf", 0, "idk im lazy lmao"],
                ["gf", 0, "ttyl byee!~"],
                ["", 0, "(Click. . .)"]],
                [["bf", 6, "I unno"],
                ["gf", 0, "All good I tracked ur ip lmao"],
                ["bf", 15, "Ooh shit where am I?"],
                ["gf", 0, "Idk"],
                ["bf", 2, "Oh"],
                ["gf", 0, "Imma head to Arbys"],
                ["", 0, "(Click. . .)"]]],
                
                [["", 0, "Ring...  Ring..."],
                ["gf", 0, "What is up whores, Girlfriend Dearest here"],
                ["gf", 0, "Too lazy to answer the phone so leave a message"],
                ["", 0, "You decide it's not worth it."]]
            ],
            
            'pico' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 4, "Fuck you want?"],
                ["bf", 9, "I'm stuck in Friday Night Funkin The Poopshitters Judgement Hall"],
                ["pico", 3, "So?"],
                ["bf", 3, "Help"],
                ["pico", 2, "No"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 0, "LEAVE ME ALONE DAMN"],
                ["bf", 10, "My bad"],
                ["pico", 6, "Ok i'll help you"],
                ["bf", 15, "No"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["", 0, "Your call has been forwarded to an automatic voicemail system."],
                ["", 0, "(Click. . .)"]]
            ],

            'papyrus' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["peepisser", 1, "IS THAT MY BROTHER?"],
                ["peepisser", 0, "WHY IS HE IN THERE"],
                ["bf", 14, "Poopshiter mod content"],
                ["peepisser", 0, "OK MAN SURE"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["peepisser", 1, "TELL HIM TO HURRY UP"],
                ["peepisser", 0, "MORE PUZZLES NEED TO BE MADE"],
                ["bf", 12, "I'm workin on it man"],
                ["", 0, "(Click. . .)"]],
            ],
        ],

        'throne-hallway' => [
            'gf' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["bf", 0, "Come pick me up I'm done"],
                ["gf", 0, "I'm at arbys"],
                ["bf", 2, "Bro"],
                ["bf", 11, "Pick me up some at least"],
                ["gf", 0, "K"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["bf", 16, "I'm hungry"],
                ["bf", 16, "Hurry up"],
                ["gf", 0, "Buy yourself some food bro"],
                ["bf", 0, "."],
                ["", 0, "(Click. . .)"]],
            ],

            'pico' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 6, "Where's little bro at"],
                ["pico", 7, "Is there a lore reason for this"],
                ["bf", 3, "Yeah man"],
                ["pico", 12, "Oh ok"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 7, "Sure thing pal"],
                ["", 0, "(Click. . .)"]],
            ],

            'papyrus' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["peepisser", 1, "WOW THAT'S A HALLWAY"],
                ["poopshitter", 0, "ehh, make it two hallways."],
                ["bf", 0, "No it;s like 5 I think"],
                ["poopshitter", 4, "kys"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["poopshitter", 4, "kys"],
                ["", 0, "(Click. . .)"]],
            ],
        ],

        'gaster-room' => [
            'gf' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["gf", 0, "Get the egg Boyfriend"],
                ["bf", 4, "Fucking what"],
                ["gf", 0, "Get the egg Boyfie we outta eggs"],
                ["bf", 8, "What the fuck does that mean"],
                ["gf", 0, "Egg"],
                ["", 0, "(Click. . .)"]],
                
                [["", 0, "Ring...  Ring..."],
                ["gf", 0, "G   o"],
                ["bf", 17, ""],
                ["", 0, "(Click. . .)"]]
            ],

            'pico' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 2, "Dawg where the actual fuck are you?"],
                ["bf", 12, "Ganster"],
                ["pico", 4, "Ok man"],
                ["bf", 15, "Send dudes"],
                ["pico", 1, "No"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["pico", 3, "I have no fucking clue where your ass is"],
                ["bf", 0, "Find out then man"],
                ["pico", 8, "Pull up yo big boy britches fool, figure it out yourself"],
                ["bf", 17, "Fuck you"],
                ["pico", 9, "I broke up wit yo bitch ass long ago,"],
                ["pico", 6, "Go fuck wit yo bitch or somethin"],
                ["bf", 9, "I genuinely hate you dawg"],
                ["", 0, "(Click. . .)"]],

                [["", 0, "Ring. . .  Ring. . ."],
                ["", 0, "Your call has been forwarded to an automatic voicemail system."],
                ["", 0, "(Click. . .)"]]
            ],
            
            'papyrus' => [
                [["", 0, "Ring. . .  Ring. . ."],
                ["peepisser", 1, "I HAVE NOTHING TO SAY"],
                ["peepisser", 0, "HAVE FUN"],
                ["bf", 0, "Bro"],
                ["", 0, "(Click. . .)"]],
            ],
        ],

    ];

    static var gameOver:Map<String, Array<Array<String>>> = [
        '' => [//juuuuust in case
            ['']
        ],

        'asgore' => [
            ['You cannot give up just yet...', '[PLAYER_NAME]! Stay determined...'],
            ['Don\'t lose hope!', '[PLAYER_NAME]! Stay determined...'],
            ['Our fate rests upon you...', '[PLAYER_NAME]! Stay determined...'],
            ['[PLAYER_NAME]! You have to stay determined!', 'You can\'t give up... You are the future of humans and monsters...'],
            ['[PLAYER_NAME], please... wake up!', 'The fate of humans and monsters depends on you!'],
            ['Your mother did not raise a quitter!', '[PLAYER_NAME]! Stay determined...'],
            ['You\'re on the right track, my friend...', '[PLAYER_NAME]! Stay determined...'],
            ['Whatever you do, always give 100%...', 'Unless you\'re donating blood.'],
            ['You\'ll get it next time...', '[PLAYER_NAME]! Stay determined...'],
            ['Come on, don\'t stop now!', '[PLAYER_NAME]! Stay determined...'],
        ],

        'poopshitter' => [
            ['ain\'t no way blud died already, just get better'],
            ['don\'t you ever disrespect my ass again cuh'],
            ['get lost (farts)'],
            [''],
            ['this shit sucks, im jakcin off'],
            ['dawg im off to grillby\'s,', 'come back when you get better at this shit'],
            ['gettttttt shit on!!!', 'if we\'re really friends. . . you won\'t come back.']
        ],

        'poopshitter-rec' => [
            ['damn, this aint gonna look good in your vod'],
            ['i hope this makes it into the compilation...', 'of how shit you are'],
            ['chat, you might wanna clip that'],
            ['ok man you don\'t need to record EVERY death message'],
            ['uuh', 'hey guys'],
            ["editor, cut this one out"],
            ["OBS, obliterated By shitters...", "seriously u cant be this bad lmfao"],
        ],
    ];

    static function fillerText(isPhoneCall:Bool = false):Array<Dynamic> {
        var makeThemRing:Array<Dynamic> = [["", 0, "Dialing. . ."],["", 0, ". . ."],["", 0, "But Nobody Came."]];
        var regFiller:Array<Dynamic> = [["", 0, "This is an error message!"],["", 0, "This means you did something you shouldn't have."],["", 0, "Congratulations!"]];

        if (isPhoneCall) return makeThemRing;
        else return regFiller;
    }
}

typedef CharOptions = {
    @:optional var gridSize:Array<Int>;
    @:optional var typeFont:String;
    @:optional var fontSizeMult:Float;
    @:optional var sbAmt:Int;
    @:optional var soundByte:String;
    @:optional var asterisk:Bool;
}