package objects;

class Note extends GameSprite {
	public var dir:String = ''; // note direction
	public var type:String = ''; // receptor, plain, or sustain

	public var shouldHit:Bool = true;
	public var isEndNote:Bool = false;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var lastNote:Note;
	public var nextNote:Note;
	public var rawNoteData:Int = 0;

	public var strum:Float = 0.0;
	public var sustainLength:Float = 0;

	public var colorSwap:ColorSwap;

	public var scaleX:Float = 0;
	public var scaleY:Float = 0;

	public function new(x:Float, y:Float, dir:String, type:String) {
		super(x, y);

		this.dir = dir;
		this.type = type;

		loadGraphic(Paths.image('gameplay/noteskins/${SaveData.settings.noteSkinType.toLowerCase()}/note_$dir'), true, 200, 200);
		scale.set(0.6, 0.6);

		animation.add("note", [0], 1);
		animation.add("press", [1], 1);
		animation.add("receptor", [2], 1);
		animation.add("hold", [0], 1); // placeholder
		animation.add("holdend", [0], 1); // placeholder

		animation.play((type == 'receptor') ? "receptor" : "note");

		if (type == "sustain" && lastNote != null) {
			alpha = 0.4;
			scale.set(0.4, 0.4);

			animation.play("holdend");
			updateHitbox();

			if (lastNote.type == "sustain" && Utilities.getNoteIndex(dir) <= 0) {
				lastNote.animation.play("hold");
				lastNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.instance.speed;
				lastNote.updateHitbox();
			}
		}

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		var noteColor = NoteColors.getNoteColor(Utilities.getNoteIndex(dir));

		if (colorSwap != null && noteColor != null) {
			colorSwap.r = noteColor[0];
			colorSwap.g = noteColor[1];
			colorSwap.b = noteColor[2];
		}
	}

	public function press() {
		animation.play("press");

		scale.set(0.5, 0.5);
		FlxTween.cancelTweensOf(this.scale);
		FlxTween.tween(this.scale, {x: 0.6, y: 0.6}, 0.3, {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float) {
		scaleX = scale.x;
		scaleY = scale.y;

		super.update(elapsed);

		if (tooLate && alpha > 0.3)
			alpha = 0.3;
	}

	public function calculateCanBeHit() {
		if (this != null) {
			if (type == "sustain") {
				if (shouldHit) {
					if (strum > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
						&& strum < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
					else
						canBeHit = false;
				} else {
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			} else {
				if (shouldHit) {
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset)
						canBeHit = true;
					else
						canBeHit = false;
				} else {
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}

			if (strum < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
	}
}