package options;

import options.Option;

class OptionsSubState extends ExtendableSubState {
	var options:Array<Option> = [];
	var grpOptions:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var description:FlxText;
	var camFollow:FlxObject;

	var holdTimer:FlxTimer;
	var holdDirection:Int = 0;

	var note:Note;
	var noteSplash:NoteSplash;
	var testSprite:FlxSprite;

	public function new() {
		super();

		var o:Option;
		o = new Option(Localization.get("opAnti"), Localization.get("descAnti"), OptionType.Toggle, SaveData.settings.antialiasing);
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.antialiasing = v;
			reloadSprite('test');
		};
		o.showSillySprite = true;
		options.push(o);

		#if desktop
		o = new Option(Localization.get("opFlScrn"), Localization.get("descFlScrn"), OptionType.Toggle, SaveData.settings.fullscreen);
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.fullscreen = v;
			FlxG.fullscreen = SaveData.settings.fullscreen;
		};
		options.push(o);
		#end

		o = new Option(Localization.get("opFlash"), Localization.get("descFlash"), OptionType.Toggle, SaveData.settings.flashing);
		o.onChange = (v:Dynamic) -> SaveData.settings.flashing = v;
		options.push(o);

		o = new Option(Localization.get("opFrm"), Localization.get("descFrm"), OptionType.Integer(60, 240, 10),
			Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, 60, 240)));
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.framerate = v;
			Main.framerate = SaveData.settings.framerate;
		};
		options.push(o);

		o = new Option(Localization.get("opFPS"), Localization.get("descFPS"), OptionType.Toggle, SaveData.settings.fpsCounter);
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.fpsCounter = v;
			if (Main.fpsDisplay != null)
				Main.fpsDisplay.visible = SaveData.settings.fpsCounter;
		};
		options.push(o);

		o = new Option(Localization.get("opSpeed"), Localization.get("descSpeed"), OptionType.Integer(1, 10, 1), SaveData.settings.songSpeed);
		o.onChange = (v:Dynamic) -> SaveData.settings.songSpeed = v;
		options.push(o);

		o = new Option(Localization.get("opDwnScrl"), Localization.get("descDwnScrl"), OptionType.Toggle, SaveData.settings.downScroll);
		o.onChange = (v:Dynamic) -> SaveData.settings.downScroll = v;
		options.push(o);

		o = new Option(Localization.get("opUnderlay"), Localization.get("descUnderlay"), OptionType.Integer(0, 100, 1), SaveData.settings.laneUnderlay);
		o.showPercentage = true;
		o.onChange = (v:Dynamic) -> SaveData.settings.laneUnderlay = v;
		options.push(o);

		o = new Option(Localization.get("opNoteskin"), Localization.get("descNoteskin"),
			OptionType.Choice(Paths.getTextArray(Paths.txt('data/noteskinsList'))), SaveData.settings.noteSkinType);
		o.showNoteskin = true;
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.noteSkinType = v;
			reloadSprite('note');
		};
		options.push(o);

		o = new Option(Localization.get("opNotesplash"), Localization.get("descNotesplash"),
			OptionType.Choice(Paths.getTextArray(Paths.txt('data/notesplashesList'))), SaveData.settings.noteSplashType);
		o.showNotesplash = true;
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.noteSplashType = v;
			reloadSprite('splash');
		};
		options.push(o);

		o = new Option(Localization.get("opHitSndT"), Localization.get("descHitSndT"), OptionType.Choice(['Default', 'CD', 'OSU', 'Switch']),
			SaveData.settings.hitSoundType);
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.hitSoundType = v;
			FlxG.sound.play(Paths.sound('hitsound' + SaveData.settings.hitSoundType));
		};
		options.push(o);

		o = new Option(Localization.get("opHitSndV"), Localization.get("descHitSndV"), OptionType.Integer(0, 100, 10), SaveData.settings.hitSoundVolume);
		o.showPercentage = true;
		o.onChange = (v:Dynamic) -> {
			SaveData.settings.hitSoundVolume = v;
			FlxG.sound.play(Paths.sound('hitsound' + SaveData.settings.hitSoundType), SaveData.settings.hitSoundVolume / 100);
		};
		options.push(o);

		o = new Option(Localization.get("opBot"), Localization.get("descBot"), OptionType.Toggle, SaveData.settings.botPlay);
		o.onChange = (v:Dynamic) -> SaveData.settings.botPlay = v;
		options.push(o);

		o = new Option(Localization.get("opMSDisp"), Localization.get("descMSDisp"), OptionType.Toggle, SaveData.settings.displayMS);
		o.onChange = (v:Dynamic) -> SaveData.settings.displayMS = v;
		options.push(o);

		o = new Option(Localization.get("opMash"), Localization.get("descMash"), OptionType.Toggle, SaveData.settings.antiMash);
		o.onChange = (v:Dynamic) -> SaveData.settings.antiMash = v;
		options.push(o);

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);
		add(camFollow);

		var bg:FlxSprite = new GameSprite().loadGraphic(Paths.image('menu/backgrounds/options_bg'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length) {
			var optionTxt:FlxText = new FlxText(20, 20 + (i * 80), 0, options[i].toString(), 32);
			optionTxt.setFormat(Paths.font(Localization.getFont()), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionTxt.ID = i;
			grpOptions.add(optionTxt);

			if (options[i].showSillySprite)
				reloadSprite('test');
			if (options[i].showNoteskin)
				reloadSprite('note');
			if (options[i].showNotesplash)
				reloadSprite('splash');
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font(Localization.getFont()), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		add(description);

		changeSelection(0, false);

		holdTimer = new FlxTimer();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Input.justPressed('up') || Input.justPressed('down'))
			changeSelection(Input.justPressed('up') ? -1 : 1);
		if (Input.justPressed('right') || Input.justPressed('left'))
			startHold(Input.justPressed('right') ? 1 : -1);
		if (Input.justReleased('right') || Input.justReleased('left')) {
			if (holdTimer.active)
				holdTimer.cancel();
		}

		if (Input.justPressed('accept')) {
			var option:Option = options[curSelected];
			if (option != null)
				option.execute();
		}

		if (Input.justPressed('exit')) {
			SaveData.saveSettings();
			persistentDraw = persistentUpdate = true;
			close();
		}
	}

	private function changeSelection(change:Int = 0, ?playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scroll'));
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		grpOptions.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		var option = options[curSelected];

		if (testSprite != null)
			testSprite.visible = option.showSillySprite;
		if (note != null)
			note.visible = option.showNoteskin;
		if (noteSplash != null)
			noteSplash.visible = option.showNotesplash;

		if (option.desc != null) {
			description.text = option.desc;
			description.screenCenter(X);
		}
	}

	private function changeValue(direction:Int = 0):Void {
		FlxG.sound.play(Paths.sound('scroll'));
		var option:Option = options[curSelected];

		if (option != null) {
			option.changeValue(direction);

			grpOptions.forEach(function(txt:FlxText):Void {
				if (txt.ID == curSelected)
					txt.text = option.toString();
			});
		}
	}

	private function startHold(direction:Int = 0):Void {
		holdDirection = direction;

		var option:Option = options[curSelected];

		if (option != null) {
			if (option.type != OptionType.Function)
				changeValue(holdDirection);

			switch (option.type) {
				case OptionType.Integer(_, _, _) | OptionType.Decimal(_, _, _):
					if (!holdTimer.active) {
						holdTimer.start(0.5, function(timer:FlxTimer):Void {
							timer.start(0.05, function(timer:FlxTimer):Void {
								changeValue(holdDirection);
							}, 0);
						});
					}
				default:
			}
		}
	}

	private function reloadSprite(sprite:String) {
		switch (sprite) {
			case 'test':
				if (testSprite != null) {
					testSprite.kill();
					remove(testSprite);
					testSprite.destroy();
				}
				testSprite = new GameSprite(840, 0).loadGraphic(Paths.image('testSpr'));
				testSprite.scale.set(2, 2);
				testSprite.scrollFactor.set();
				testSprite.updateHitbox();
				testSprite.screenCenter(Y);
				add(testSprite);
			case 'note':
				if (note != null) {
					note.kill();
					remove(note);
					note.destroy();
				}
				note = new Note(1000, 0, 'up', 'note');
				note.scrollFactor.set();
				note.updateHitbox();
				note.screenCenter(Y);
				add(note);
			case 'splash':
				if (noteSplash != null) {
					noteSplash.kill();
					remove(noteSplash);
					noteSplash.destroy();
				}
				noteSplash = new NoteSplash(1000, 0, 2);
				noteSplash.isStatic = true;
				noteSplash.alpha = 1;
				noteSplash.scrollFactor.set();
				noteSplash.updateHitbox();
				noteSplash.screenCenter(Y);
				add(noteSplash);
		}
	}
}