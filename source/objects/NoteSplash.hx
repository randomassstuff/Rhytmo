package objects;

class NoteSplash extends GameSprite {
	public var colorSwap:ColorSwap;
	public var noteColor:Array<Int> = [255, 0, 0];

	public var isStatic:Bool = false;

	private var tweenStarted:Bool = false;

	public function new(x:Float, y:Float, noteData:Int = 0) {
		super(x, y);
		setupSplash(x, y, noteData);
	}

	public function setupSplash(x:Float, y:Float, noteData:Int = 0) {
		setPosition(x, y);

		loadGraphic(Paths.image('gameplay/notesplashes/${SaveData.settings.noteSplashType.toLowerCase()}/splash_${Utilities.getDirection(noteData)}'), true,
			200, 200);
		scale.set(0.6, 0.6);
		alpha = 0.6;

		animation.add("splash", [0], 1);
		animation.play("splash");

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		noteColor = NoteColors.getNoteColor(Utilities.getNoteIndex(Utilities.getDirection(noteData)));

		if (colorSwap != null && noteColor != null) {
			colorSwap.r = noteColor[0];
			colorSwap.g = noteColor[1];
			colorSwap.b = noteColor[2];
		}

		tweenStarted = false;
	}

	override function update(elapsed:Float) {
		if (!isStatic) {
			if (visible && alpha > 0 && !tweenStarted) {
				tweenStarted = true;
				FlxTween.tween(this, {alpha: 0}, 0.33, {
					onComplete: (twn:FlxTween) -> {
						if (alpha <= 0)
							kill();
					}
				});
			}
		}

		super.update(elapsed);
	}
}