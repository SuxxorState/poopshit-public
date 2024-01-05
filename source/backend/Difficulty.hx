package backend;

class Difficulty
{
	public static var defaultList(default, never):Array<String> = [
		'Hard'
	];
	public static var list:Array<String> = [];
	private static var defaultDifficulty(default, never):String = 'Hard'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	inline public static function getFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = list[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	inline public static function loadFromWeek(week:SongData = null)
	{
		if(week == null) week = SongData.getCurrentSong();

		var diffStr:String = 'Hard';
		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.trim().split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
				list = diffs;
		}
		else resetList();
	}

	inline public static function resetList()
	{
		list = defaultList.copy();
	}

	inline public static function copyFrom(diffs:Array<String>)
	{
		list = diffs.copy();
	}

	inline public static function getString(num:Null<Int> = null):String
	{
		return list[num == null ? PlayState.storyDifficulty : num];
	}

	inline public static function getDefault():String
	{
		return defaultDifficulty;
	}
}