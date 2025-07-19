package substates;

class PromptSubState extends FlxSubState {
	var question:String;
	var callbackYes:Void->Void;
	var callbackNo:Void->Void;

	public function new(question:String, callbackYes:Void->Void, ?callbackNo:Void->Void) {
		super();

		this.question = question;
		this.callbackYes = callbackYes;
		this.callbackNo = callbackNo;

		var width:Float = FlxG.width * 0.75;
		var height:Float = FlxG.height * 0.5;

		var box:RoundedSprite = new RoundedSprite(0, 0, Std.int(width), Std.int(height), FlxColor.BLACK);
		box.scrollFactor.set();
		box.screenCenter();
		add(box);

		var questionTxt:FlxText = new FlxText(box.x, box.y + 20, width, question);
		questionTxt.setFormat(Paths.font(Localization.getFont()), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		questionTxt.scrollFactor.set();
		add(questionTxt);

		var btnYes:FlxButton = new FlxButton(0, box.height / 2 + 200, Localization.get("yes"), () -> {
			if (callbackYes != null)
				callbackYes();
			close();
		});
		btnYes.scale.set(2, 2);
		btnYes.scrollFactor.set();
		btnYes.label.setFormat(Paths.font(Localization.getFont()), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btnYes.label.screenCenter();
		btnYes.screenCenter(X);
		add(btnYes);

		var btnNo:FlxButton = new FlxButton(0, btnYes.y + 50, Localization.get("no"), () -> {
			if (callbackNo != null)
				callbackNo();
			close();
		});
		btnNo.scale.set(2, 2);
		btnNo.scrollFactor.set();
		btnNo.label.setFormat(Paths.font(Localization.getFont()), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btnNo.label.screenCenter();
		btnNo.screenCenter(X);
		add(btnNo);
	}
}