package backend;

import flixel.input.FlxInput.FlxInputState;

typedef Bind = {
	key:Array<FlxKey>,
	gamepad:Array<FlxGamepadInputID>
}

class Input {
	static public var kBinds:Array<FlxKey> = SaveData.settings.keyboardBinds;
	static public var gBinds:Array<FlxGamepadInputID> = SaveData.settings.gamepadBinds;
	public static var binds:Map<String, Bind> = getDefaultBinds();

	inline static function getDefaultBinds():Map<String, Bind>
		return [
			'left' => {key: [kBinds[0], kBinds[4]], gamepad: [gBinds[0], gBinds[4]]},
			'down' => {key: [kBinds[1], kBinds[5]], gamepad: [gBinds[1], gBinds[5]]},
			'up' => {key: [kBinds[2], kBinds[6]], gamepad: [gBinds[2], gBinds[6]]},
			'right' => {key: [kBinds[3], kBinds[7]], gamepad: [gBinds[3], gBinds[7]]},
			'accept' => {key: [kBinds[8]], gamepad: [gBinds[8]]},
			'exit' => {key: [kBinds[9]], gamepad: [gBinds[9]]},
			'reset' => {key: [kBinds[10]], gamepad: [gBinds[10]]}
		];

	public static function refreshControls()
		binds = getDefaultBinds();

	public static function resetControls() {
		SaveData.settings.keyboardBinds = [LEFT, DOWN, UP, RIGHT, A, S, W, D, ENTER, ESCAPE, R];
		SaveData.settings.gamepadBinds = [
			DPAD_LEFT,
			DPAD_DOWN,
			DPAD_UP,
			DPAD_RIGHT,
			LEFT_TRIGGER,
			LEFT_SHOULDER,
			RIGHT_SHOULDER,
			RIGHT_TRIGGER,
			A,
			B,
			RIGHT_STICK_CLICK
		];
		SaveData.saveSettings();
		refreshControls();
	}

	public static function justPressed(tag:String):Bool
		return checkInput(tag, JUST_PRESSED);

	public static function pressed(tag:String):Bool
		return checkInput(tag, PRESSED);

	public static function justReleased(tag:String):Bool
		return checkInput(tag, JUST_RELEASED);

	public static function anyJustPressed(tags:Array<String>):Bool
		return checkAnyInputs(tags, JUST_PRESSED);

	public static function anyPressed(tags:Array<String>):Bool
		return checkAnyInputs(tags, PRESSED);

	public static function anyJustReleased(tags:Array<String>):Bool
		return checkAnyInputs(tags, JUST_RELEASED);

	public static function checkInput(tag:String, state:FlxInputState):Bool {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (binds.exists(tag)) {
			if (gamepad != null) {
				for (input in binds[tag].gamepad)
					if (input != FlxGamepadInputID.NONE && gamepad.checkStatus(input, state))
						return true;
			}

			for (input in binds[tag].key)
				if (input != FlxKey.NONE && FlxG.keys.checkStatus(input, state))
					return true;
		} else {
			if (gamepad != null) {
				var gpInput = FlxGamepadInputID.fromString(tag);
				if (gpInput != FlxGamepadInputID.NONE && gamepad.checkStatus(gpInput, state))
					return true;
			}
			if (FlxKey.fromString(tag) != FlxKey.NONE && FlxG.keys.checkStatus(FlxKey.fromString(tag), state))
				return true;
		}

		return false;
	}

	public static function checkAnyInputs(tags:Array<String>, state:FlxInputState):Bool {
		if (tags == null || tags.length <= 0)
			return false;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		for (tag in tags) {
			if (binds.exists(tag)) {
				if (gamepad != null) {
					for (input in binds[tag].gamepad)
						if (input != FlxGamepadInputID.NONE && gamepad.checkStatus(input, state))
							return true;
				}
				for (input in binds[tag].key)
					if (input != FlxKey.NONE && FlxG.keys.checkStatus(input, state))
						return true;
			} else {
				if (gamepad != null) {
					var gpInput = FlxGamepadInputID.fromString(tag);
					if (gpInput != FlxGamepadInputID.NONE && gamepad.checkStatus(gpInput, state))
						return true;
				}

				if (FlxKey.fromString(tag) != FlxKey.NONE && FlxG.keys.checkStatus(FlxKey.fromString(tag), state))
					return true;
			}
		}

		return false;
	}
}