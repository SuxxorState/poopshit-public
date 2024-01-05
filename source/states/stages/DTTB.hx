package states.stages;

class DTTB extends BaseStage {
	override function create() {
		if (PlayState.instance != null) {
			game.songHasKR = ClientPrefs.data.ghostTapping;
			game.swapstrums = true;
			game.skipCountdown = true;
		}

		var stage:BGSprite = new BGSprite('shit', -200, -200, 1,1);
		stage.setGraphicSize(Std.int(stage.width * 5), Std.int(stage.height * 4));
		stage.updateHitbox();
		add(stage);
	}
}