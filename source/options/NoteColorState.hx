package options;

class NoteColorState extends ExtendableState {
	var daText:FlxText;

	var strumline:FlxTypedGroup<Note>;
	var noteDirs:Array<String> = ['left', 'down', 'up', 'right'];

	var isSelectingSomething:Bool = false;
	var curSelectedControl:Int = 0;

	var curSelectedValue:Int = 0; // red - 0, green - 1, blue - 2
	var curColorVals:Array<Int> = [255, 0, 0];

	final colorMins:Array<Int> = [0, 0, 0];
	final colorMaxs:Array<Int> = [255, 255, 255];

	var fromPlayState:Bool = false;

	public function new(?fromPlayState:Bool = false) {
		super();
		this.fromPlayState = fromPlayState;
	}

	override function create() {
		super.create();

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		strumline = new FlxTypedGroup<Note>();
		add(strumline);

		var noteWidth:Float = 200;
		var totalWidth:Float = noteDirs.length * noteWidth;
		var startX:Float = (FlxG.width - totalWidth) / 2;

		for (i in 0...noteDirs.length) {
			var note:Note = new Note(startX + i * noteWidth, 50, noteDirs[i], "note");
			note.ID = i;
			strumline.add(note);
		}

		daText = new FlxText(0, 280, FlxG.width, "", 12);
		daText.setFormat(Paths.font(Localization.getFont()), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.screenCenter(X);
		add(daText);

		updateColorVals();
		updateText();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('reset')) {
			curColorVals = NoteColors.defaultColors[curSelectedControl];
			var n = strumline.members[curSelectedControl];
			n.colorSwap.r = curColorVals[0];
			n.colorSwap.g = curColorVals[1];
			n.colorSwap.b = curColorVals[2];
			NoteColors.setNoteColor(curSelectedControl, curColorVals);
		}

		if (Input.justPressed('exit')) {
			if (isSelectingSomething)
				isSelectingSomething = false;
			else {
				SaveData.saveSettings();
				ExtendableState.switchState(new OptionsState(fromPlayState));
				FlxG.sound.play(Paths.sound('cancel'));
			}
		}

		if (!isSelectingSomething && (Input.justPressed('left') || Input.justPressed('right'))) {
			curSelectedControl += Input.justPressed('left') ? -1 : 1;
			if (curSelectedControl < 0)
				curSelectedControl = 3;
			if (curSelectedControl > 3)
				curSelectedControl = 0;
			updateColorVals();
		}

		if (isSelectingSomething && (Input.justPressed('up') || Input.justPressed('down'))) {
			curColorVals[curSelectedValue] += Input.justPressed('up') ? 1 : -1;
			curColorVals[curSelectedValue] = Std.int(FlxMath.bound(curColorVals[curSelectedValue], colorMins[curSelectedValue], colorMaxs[curSelectedValue]));
			var n = strumline.members[curSelectedControl];
			switch (curSelectedValue) {
				case 0:
					n.colorSwap.r = curColorVals[0];
				case 1:
					n.colorSwap.g = curColorVals[1];
				case 2:
					n.colorSwap.b = curColorVals[2];
			}
			NoteColors.setNoteColor(curSelectedControl, curColorVals);
		}

		if (isSelectingSomething && (Input.justPressed('left') || Input.justPressed('right'))) {
			curSelectedValue += Input.justPressed('left') ? -1 : 1;
			if (curSelectedValue < 0)
				curSelectedValue = 2;
			if (curSelectedValue > 2)
				curSelectedValue = 0;
		}

		updateText();

		for (note in strumline) {
			if (note.ID == curSelectedControl && Input.justPressed('accept') && !isSelectingSomething) {
				curSelectedControl = note.ID;
				isSelectingSomething = true;
			}
			note.alpha = (note.ID == curSelectedControl) ? 1 : 0.6;
		}
	}

	function updateText() {
		var r:String = Std.string(curColorVals[0]);
		var g:String = Std.string(curColorVals[1]);
		var b:String = Std.string(curColorVals[2]);
		switch (curSelectedValue) {
			case 0:
				r = '>$r<';
			case 1:
				g = '>$g<';
			case 2:
				b = '>$b<';
		}
		daText.text = Localization.get("noteColorGuide")
			+ Localization.get("red")
			+ r
			+ Localization.get("green")
			+ g
			+ Localization.get("blue")
			+ b;
		daText.screenCenter(X);
	}

	inline function updateColorVals()
		curColorVals = NoteColors.getNoteColor(curSelectedControl);
}