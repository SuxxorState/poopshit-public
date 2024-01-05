package backend;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import tjson.TJSON as Json;

typedef SongFile = {
	var song:String;
	var songChar:Array<String>;
	var charOffsets:Array<Float>;
	var overworld:String;
	var playerName:String;
	var level:Null<Float>;
	var secretSong:Null<Bool>;
	var bgMusic:String;
	var bgVariant:String;
}

class SongData {
	public static var songsLoaded:Map<String, SongData> = new Map<String, SongData>();
	public static var allSongs:Map<String, SongData> = new Map<String, SongData>();
	public static var songList:Array<String> = [];
	public var folder:String = '';
	
	public var song:String;
	public var songChar:Array<String>;
	public var charOffsets:Array<Float>;
	public var overworld:String;
	public var playerName:String;
	public var level:Null<Float>;
	public var secretSong:Null<Bool>;
	public var bgMusic:String;
	public var bgVariant:String;

	public var fileName:String;

	public static function createSongFile():SongFile {
		var songFile:SongFile = {
			song: "Constipation",
			songChar: ["sans","freepoop","laugh","sleep"],
			charOffsets: [0,0],
			overworld: "Last Corridor",
			playerName: "",
			level: 19,
			secretSong: false,
			bgMusic: "PoopshittersMainMenu",
			bgVariant: "normal",
		};
		return songFile;
	}

	public function new(songFile:SongFile, fileName:String) {
		song = songFile.song;
		songChar = songFile.songChar;
		charOffsets = songFile.charOffsets;
		overworld = songFile.overworld;
		playerName = songFile.playerName;
		level = songFile.level;
		secretSong = songFile.secretSong;
		bgMusic = songFile.bgMusic;
		bgVariant = songFile.bgVariant;

		this.fileName = fileName;
	}

	public static function reloadSongFiles(storyMode:Null<Bool> = false) {
		songList = [];
		songsLoaded.clear();

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('songs/List.txt'));
		#if sys
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs"))) 
			if (!sexList.contains(i)) sexList.push(i);
		#end

		for (i in 0...sexList.length) {
			var fileToCheck:String = Paths.getPreloadPath() + 'songs/' + sexList[i] + '/Data.json';

			if(!songsLoaded.exists(sexList[i])) {
				var song:SongFile = getSongFile(fileToCheck);
				if(song != null) {
					var songFile:SongData = new SongData(song, sexList[i]);
					var secretUnlocked:Bool = true;

					if (songFile.secretSong && ClientPrefs.data.permaUnlocks.exists(Paths.formatToSongPath(sexList[i]))) secretUnlocked = ClientPrefs.data.permaUnlocks.get(Paths.formatToSongPath(sexList[i]));
					else if (songFile.secretSong && !ClientPrefs.data.permaUnlocks.exists(Paths.formatToSongPath(sexList[i]))) {
						secretUnlocked = false;
						ClientPrefs.data.permaUnlocks.set(Paths.formatToSongPath(sexList[i]), false);
					}

					if(songFile != null && (songFile.secretSong == null || !songFile.secretSong || (secretUnlocked && songFile.secretSong))) {
						songsLoaded.set(sexList[i], songFile);
						songList.push(sexList[i]);
					}
					allSongs.set(sexList[i], songFile);
				}
			}
		}
	}

	private static function addSong(songToCheck:String, path:String) {
		if(!songsLoaded.exists(songToCheck)) {
			var song:SongFile = getSongFile(path);
			if(song != null) {
				var songFile:SongData = new SongData(song, songToCheck);
				var secretUnlocked:Bool = true;

				if (songFile.secretSong && ClientPrefs.data.permaUnlocks.exists(Paths.formatToSongPath(songToCheck))) secretUnlocked = ClientPrefs.data.permaUnlocks.get(Paths.formatToSongPath(songToCheck));
				else if (songFile.secretSong && !ClientPrefs.data.permaUnlocks.exists(Paths.formatToSongPath(songToCheck))) {
					secretUnlocked = false;
					ClientPrefs.data.permaUnlocks.set(Paths.formatToSongPath(songToCheck), false);
				}

				if(songFile != null && (songFile.secretSong == null || !songFile.secretSong || (secretUnlocked && songFile.secretSong))) {
					songsLoaded.set(songToCheck, songFile);
					songList.push(songToCheck);
				}
			}
		}
	}

	private static function getSongFile(path:String):SongFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(path)) rawJson = File.getContent(path);
		#else
		if(OpenFlAssets.exists(path)) rawJson = Assets.getText(path);
		#end

		if(rawJson != null && rawJson.length > 0) return cast Json.parse(rawJson);

		return null;
	}

	public static function getSongFileName():String return songList[PlayState.storyWeek];
	public static function getCurrentSong():SongData return songsLoaded.get(songList[PlayState.storyWeek]);
}