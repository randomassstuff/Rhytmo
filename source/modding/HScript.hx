package modding;

import hscript.*;

class HScript extends FlxBasic {
	public var locals(get, set):Map<String, {r:Dynamic}>;

	function get_locals():Map<String, {r:Dynamic}> {
		@:privateAccess
		return interp.locals;
	}

	function set_locals(local:Map<String, {r:Dynamic}>) {
		@:privateAccess
		return interp.locals = local;
	}

	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var parser:Parser = new Parser();
	public var interp:Interp = new Interp();

	public function new(?file:String, ?execute:Bool = true) {
		super();

		parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;
		parser.preprocesorValues = macros.Macros.getDefines();

		// Default Variables
		setVariable('this', this);

		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('platform', PlatformUtil.getPlatform());
		setVariable('version', Lib.application.meta.get('version'));

		// Default Functions
		setVariable('import', function(daClass:String, ?asDa:String) {
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'HScript Error!');
			else {
				if (daEnum != null) {
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						setVariable(asDa, daEnumField);
					else
						setVariable(splitClassName[splitClassName.length - 1], daEnumField);
				} else {
					if (asDa != null && asDa != '')
						setVariable(asDa, daClass);
					else
						setVariable(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});

		setVariable('trace', function(value:Dynamic) {
			trace(value);
		});

		setVariable('importScript', function(source:String) {
			var name:String = StringTools.replace(source, '.', '/');
			var script:HScript = new HScript(Paths.script(name), false);
			script.execute(Paths.script(name), false);
			return script.getAll();
		});

		setVariable('stopScript', function() {
			this.destroy();
		});

		// Haxe
		setVariable('Array', Array);
		setVariable('Bool', Bool);
		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('Dynamic', Dynamic);
		setVariable('EReg', EReg);
		#if sys
		setVariable('File', File);
		setVariable('FileSystem', FileSystem);
		#end
		setVariable('Float', Float);
		setVariable('Int', Int);
		setVariable('Json', Json);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Path', Path);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('String', String);
		setVariable('StringTools', StringTools);
		#if sys
		setVariable('Sys', Sys);
		#end
		setVariable('TJSON', TJSON);
		setVariable('Type', Type);
		setVariable('Xml', Xml);

		setVariable('createThread', function(func:Void->Void) {
			#if sys
			sys.thread.Thread.create(() -> {
				func();
			});
			#else
			func();
			#end
		});

		// OpenFL
		setVariable('Assets', Assets);
		setVariable('BitmapData', BitmapData);
		setVariable('Lib', Lib);
		setVariable('ShaderFilter', ShaderFilter);
		setVariable('Sound', Sound);

		// Flixel
		setVariable('FlxAxes', getFlxAxes());
		setVariable('FlxBackdrop', FlxBackdrop);
		setVariable('FlxBasic', FlxBasic);
		setVariable('FlxCamera', FlxCamera);
		setVariable('FlxCameraFollowStyle', getFlxCameraFollowStyle());
		setVariable('FlxColor', getFlxColor());
		setVariable('FlxEase', FlxEase);
		setVariable('FlxG', FlxG);
		setVariable('FlxGroup', FlxGroup);
		setVariable('FlxKey', getFlxKey());
		setVariable('FlxMath', FlxMath);
		setVariable('FlxObject', FlxObject);
		setVariable('FlxRuntimeShader', FlxRuntimeShader);
		setVariable('FlxSound', FlxSound);
		setVariable('FlxSprite', FlxSprite);
		setVariable('FlxSpriteGroup', FlxSpriteGroup);
		setVariable('FlxText', FlxText);
		setVariable('FlxTextAlign', getFlxTextAlign());
		setVariable('FlxTextBorderStyle', getFlxTextBorderStyle());
		setVariable('FlxTimer', FlxTimer);
		setVariable('FlxTween', FlxTween);
		setVariable('FlxTypedGroup', FlxTypedGroup);
		setVariable('createTypedGroup', function(?variable) {
			return variable = new FlxTypedGroup<Dynamic>();
		});
		setVariable('createSpriteGroup', function(?variable) {
			return variable = new FlxSpriteGroup();
		});

		// State Stuff
		setVariable('add', FlxG.state.add);
		setVariable('remove', FlxG.state.remove);
		setVariable('insert', FlxG.state.insert);
		setVariable('members', FlxG.state.members);
		setVariable('state', FlxG.state);

		// Rhythmo
		setVariable('Achievements', Achievements);
		setVariable('Bar', Bar);
		setVariable('Conductor', Conductor);
		#if FUTURE_DISCORD_RPC
		setVariable('DiscordClient', DiscordClient);
		#end
		setVariable('ExtendableState', ExtendableState);
		setVariable('ExtendableSubState', ExtendableSubState);
		setVariable('GameSprite', GameSprite);
		setVariable('HighScore', HighScore);
		setVariable('Input', Input);
		setVariable('Localization', Localization);
		setVariable('LuaScript', LuaScript);
		setVariable('Main', Main);
		#if FUTURE_POLYMOD
		setVariable('ModHandler', ModHandler);
		#end
		setVariable('Note', Note);
		setVariable('Paths', Paths);
		setVariable('PlayState', PlayState);
		setVariable('Rating', Rating);
		setVariable('SaveData', SaveData);
		setVariable('ScriptedState', ScriptedState);
		setVariable('ScriptedSubState', ScriptedSubState);
		setVariable('Song', Song);
		setVariable('Utilities', Utilities);

		setVariable('game', PlayState.instance);

		if (execute && file != null)
			this.execute(file);
	}

	public function execute(file:String, ?executeCreate:Bool = true):Void {
		try {
			interp.execute(parser.parseString(File.getContent(file)));
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');

		trace('Script Loaded Succesfully: $file');

		if (executeCreate)
			executeFunc('create', []);
	}

	public function executeStr(code:String):Dynamic {
		try {
			@:privateAccess
			parser.line = 1;
			return interp.execute(parser.parseString(code));
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');

		return null;
	}

	public function setVariable(name:String, val:Dynamic):Void {
		try {
			interp?.variables.set(name, val);
			locals.set(name, {r: val});
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');
	}

	public function getVariable(name:String):Dynamic {
		try {
			if (locals.exists(name) && locals[name] != null)
				return locals.get(name).r;
			else if (interp.variables.exists(name))
				return interp?.variables.get(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');

		return null;
	}

	public function removeVariable(name:String):Void {
		try {
			interp?.variables.remove(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');
	}

	public function existsVariable(name:String):Bool {
		try {
			return interp?.variables.exists(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'HScript Error!');

		return false;
	}

	public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (existsVariable(funcName)) {
			try {
				return Reflect.callMethod(this, getVariable(funcName), args == null ? [] : args);
			} catch (e:Dynamic)
				Lib.application.window.alert(Std.string(e), 'HScript Error!');
		}

		return null;
	}

	public function getAll():Dynamic {
		var balls:Dynamic = {};

		for (i in locals.keys())
			Reflect.setField(balls, i, getVariable(i));
		for (i in interp.variables.keys())
			Reflect.setField(balls, i, getVariable(i));

		return balls;
	}

	public function getFlxColor() {
		return {
			// colors
			"BLACK": FlxColor.BLACK,
			"BLUE": FlxColor.BLUE,
			"BROWN": FlxColor.BROWN,
			"CYAN": FlxColor.CYAN,
			"GRAY": FlxColor.GRAY,
			"GREEN": FlxColor.GREEN,
			"LIME": FlxColor.LIME,
			"MAGENTA": FlxColor.MAGENTA,
			"ORANGE": FlxColor.ORANGE,
			"PINK": FlxColor.PINK,
			"PURPLE": FlxColor.PURPLE,
			"RED": FlxColor.RED,
			"TRANSPARENT": FlxColor.TRANSPARENT,
			"WHITE": FlxColor.WHITE,
			"YELLOW": FlxColor.YELLOW,

			// functions
			"add": FlxColor.add,
			"fromCMYK": FlxColor.fromCMYK,
			"fromHSB": FlxColor.fromHSB,
			"fromHSL": FlxColor.fromHSL,
			"fromInt": FlxColor.fromInt,
			"fromRGB": FlxColor.fromRGB,
			"fromRGBFloat": FlxColor.fromRGBFloat,
			"fromString": FlxColor.fromString,
			"interpolate": FlxColor.interpolate,
			"to24Bit": function(color:Int) {
				return color & 0xffffff;
			}
		};
	}

	public static function getFlxKey() {
		return {
			'ANY': -2,
			'NONE': -1,
			'A': 65,
			'B': 66,
			'C': 67,
			'D': 68,
			'E': 69,
			'F': 70,
			'G': 71,
			'H': 72,
			'I': 73,
			'J': 74,
			'K': 75,
			'L': 76,
			'M': 77,
			'N': 78,
			'O': 79,
			'P': 80,
			'Q': 81,
			'R': 82,
			'S': 83,
			'T': 84,
			'U': 85,
			'V': 86,
			'W': 87,
			'X': 88,
			'Y': 89,
			'Z': 90,
			'ZERO': 48,
			'ONE': 49,
			'TWO': 50,
			'THREE': 51,
			'FOUR': 52,
			'FIVE': 53,
			'SIX': 54,
			'SEVEN': 55,
			'EIGHT': 56,
			'NINE': 57,
			'PAGEUP': 33,
			'PAGEDOWN': 34,
			'HOME': 36,
			'END': 35,
			'INSERT': 45,
			'ESCAPE': 27,
			'MINUS': 189,
			'PLUS': 187,
			'DELETE': 46,
			'BACKSPACE': 8,
			'LBRACKET': 219,
			'RBRACKET': 221,
			'BACKSLASH': 220,
			'CAPSLOCK': 20,
			'SEMICOLON': 186,
			'QUOTE': 222,
			'ENTER': 13,
			'SHIFT': 16,
			'COMMA': 188,
			'PERIOD': 190,
			'SLASH': 191,
			'GRAVEACCENT': 192,
			'CONTROL': 17,
			'ALT': 18,
			'SPACE': 32,
			'UP': 38,
			'DOWN': 40,
			'LEFT': 37,
			'RIGHT': 39,
			'TAB': 9,
			'PRINTSCREEN': 301,
			'F1': 112,
			'F2': 113,
			'F3': 114,
			'F4': 115,
			'F5': 116,
			'F6': 117,
			'F7': 118,
			'F8': 119,
			'F9': 120,
			'F10': 121,
			'F11': 122,
			'F12': 123,
			'NUMPADZERO': 96,
			'NUMPADONE': 97,
			'NUMPADTWO': 98,
			'NUMPADTHREE': 99,
			'NUMPADFOUR': 100,
			'NUMPADFIVE': 101,
			'NUMPADSIX': 102,
			'NUMPADSEVEN': 103,
			'NUMPADEIGHT': 104,
			'NUMPADNINE': 105,
			'NUMPADMINUS': 109,
			'NUMPADPLUS': 107,
			'NUMPADPERIOD': 110,
			'NUMPADMULTIPLY': 106,

			'fromStringMap': FlxKey.fromStringMap,
			'toStringMap': FlxKey.toStringMap,
			'fromString': FlxKey.fromString,
			'toString': function(key:Int) {
				return FlxKey.toStringMap.get(key);
			}
		};
	}

	public function getFlxCameraFollowStyle() {
		return {
			"LOCKON": FlxCamera.FlxCameraFollowStyle.LOCKON,
			"PLATFORMER": FlxCamera.FlxCameraFollowStyle.PLATFORMER,
			"TOPDOWN": FlxCamera.FlxCameraFollowStyle.TOPDOWN,
			"TOPDOWN_TIGHT": FlxCamera.FlxCameraFollowStyle.TOPDOWN_TIGHT,
			"SCREEN_BY_SCREEN": FlxCamera.FlxCameraFollowStyle.SCREEN_BY_SCREEN,
			"NO_DEAD_ZONE": FlxCamera.FlxCameraFollowStyle.NO_DEAD_ZONE
		};
	}

	public function getFlxTextAlign() {
		return {
			"LEFT": FlxTextAlign.LEFT,
			"CENTER": FlxTextAlign.CENTER,
			"RIGHT": FlxTextAlign.RIGHT,
			"JUSTIFY": FlxTextAlign.JUSTIFY
		};
	}

	public function getFlxTextBorderStyle() {
		return {
			"NONE": FlxTextBorderStyle.NONE,
			"SHADOW": FlxTextBorderStyle.SHADOW,
			"OUTLINE": FlxTextBorderStyle.OUTLINE,
			"OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
		};
	}

	public function getFlxAxes() {
		return {
			"X": FlxAxes.X,
			"Y": FlxAxes.Y,
			"XY": FlxAxes.XY
		};
	}

	override function destroy() {
		super.destroy();
		parser = null;
		interp = null;
	}
}