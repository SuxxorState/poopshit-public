package options;

class SettingsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Settings Settings';
		rpcTitle = 'Settings Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Southern Seasons', //Name
			'The setting\'s seasons will match the south.', //Description
			'southSeasons', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('SOUL Trait',
			'Changes the menus\' SOUL color',
			'soulTrait',
			'string',
			['Determination', 'Bravery', 'Justice', 'Kindness', 'Patience', 'Integrity', 'Perseverance']);
		addOption(option);

		var option:Option = new Option('Flip SOUL X',
			'Flips the SOUL on the X-Axis.',
			'soulX',
			'bool');
		addOption(option);

		var option:Option = new Option('Flip SOUL Y',
			"Flips the SOUL on the Y-Axis.",
			'soulY',
			'bool');
		addOption(option);

		var option:Option = new Option('Flip SOUL Z', //Name
			'Flips the SOUL on the Z-Axis.', //Description
			'soulZ', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Laxative Mode',
			"Charts become 150% as fast and health is halved.",
			'laxMode',
			'bool');
		option.onChange = laxChange;
		addOption(option);

		super();
	}
	
	function laxChange() {
		CoolUtil.reloadHP();	
	}
}