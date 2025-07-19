package modding;

import llua.*;
import llua.Lua.Lua_helper;

class LuaScript extends FlxBasic {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var hscript:HScript = null;
	public var lua:State = null;

	private var game:PlayState;

	public function new(file:String, ?execute:Bool = true) {
		super();

		this.game = PlayState.instance;

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		try {
			var result:Dynamic = LuaL.dofile(lua, file);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0) {
				trace('lua error!!! $resultStr');
				Lib.application.window.alert(resultStr, "Lua Error!");
				lua = null;
				return;
			}
		} catch (e) {
			trace(e.message);
			Lib.application.window.alert(e.message, "Lua Error!");
			return;
		}

		initHaxeModule();

		trace('Script Loaded Succesfully: $file');

		// Default Variables & Functions
		setVar("Function_Stop", Function_Stop);
		setVar("Function_Continue", Function_Continue);
		setVar("platform", PlatformUtil.getPlatform());
		setVar("version", Lib.application.meta.get('version'));
		setVar("lua", {version: Lua.version(), versionJIT: Lua.versionJIT()});

		var defaultFuncs:Array<Dynamic> = [
			["trace", function(v:Dynamic) trace(v)],
			["print", function(v:Dynamic) trace(v)],
			["stopScript", () -> this.destroy()],
			["setVar", (name, value) -> setVar(name, value)],
			["getVar", name -> getVar(name)],
			["deleteVar", name -> deleteVar(name)],
			["callFunction", (name, args) -> callFunction(name, args)],
			["stdInt", (x:Float) -> Std.int(x)]
		];
		for (pair in defaultFuncs)
			setCallback(pair[0], pair[1]);

		// PlayState Stuff
		var playStateArr:Array<Dynamic> = [
			["score", game.score],
			["combo", game.combo],
			["misses", game.misses],
			["health", game.health],
			["accuracy", game.accuracy],
			["curBPM", Conductor.bpm],
			["bpm", PlayState.song.bpm],
			["crochet", Conductor.crochet],
			["stepCrochet", Conductor.stepCrochet],
			["songPos", Conductor.songPosition],
			["curStep", game.curStep],
			["curBeat", game.curBeat]
		];
		for (pair in playStateArr)
			setVar(pair[0], pair[1]);
		setCallback("addScore", (v:Int = 0) -> game.score += v);
		setCallback("addMisses", (v:Int = 0) -> game.misses += v);

		setCallback("unlockAchievement", function(name:String) {
			Achievements.unlock(name, {date: Date.now(), song: PlayState.song.song});
		});

		// Screen
		setVar("screenWidth", FlxG.width);
		setVar("screenHeight", FlxG.height);

		// Basic Object Functions
		setCallback("createObject", function(type:String, tag:String, config:Dynamic) {
			switch (type) {
				case "sprite":
					var s:FlxSprite = new GameSprite(config.x, config.y);
					setCodeWithCheckNull(config.image, i -> s.loadGraphic(Paths.image(i)));
					s.active = true;
					PlayState.luaImages.set(tag, s);
				case "text":
					var t:FlxText = new FlxText(config.x, config.y, config.width, config.text, config.size);
					t.active = true;
					PlayState.luaText.set(tag, t);
				default:
					var o:FlxObject = new FlxObject(config.x, config.y, config.width, config.height);
					o.active = true;
					PlayState.luaObjects.set(tag, o);
			}
		});
		setCallback("addObject", function(tag:String) {
			if (PlayState.luaImages.exists(tag))
				PlayState.instance.add(PlayState.luaImages.get(tag));
			else if (PlayState.luaText.exists(tag))
				PlayState.instance.add(PlayState.luaText.get(tag));
			else
				PlayState.instance.add(PlayState.luaObjects.get(tag));
		});
		setCallback("removeObject", function(tag:String) {
			if (PlayState.luaImages.exists(tag))
				PlayState.instance.remove(PlayState.luaImages.get(tag));
			else if (PlayState.luaText.exists(tag))
				PlayState.instance.remove(PlayState.luaText.get(tag));
			else
				PlayState.instance.remove(PlayState.luaObjects.get(tag));
		});
		setCallback("insertObject", function(tag:String, pos:Int = 0) {
			if (PlayState.luaImages.exists(tag))
				PlayState.instance.insert(pos, PlayState.luaImages.get(tag));
			else if (PlayState.luaText.exists(tag))
				PlayState.instance.insert(pos, PlayState.luaText.get(tag));
			else
				PlayState.instance.insert(pos, PlayState.luaObjects.get(tag));
		});
		setCallback("configObject", function(tag:String, config:Dynamic) {
			if (PlayState.luaObjects.exists(tag)) {
				final o = PlayState.luaObjects.get(tag);
				setCodeWithCheckNull(config.x, x -> o.x = x);
				setCodeWithCheckNull(config.y, y -> o.y = y);
				setCodeWithCheckNull(config.width, w -> o.width = w);
				setCodeWithCheckNull(config.height, h -> o.height = h);
				setCodeWithCheckNull(config.angle, a -> o.angle = a);
				setCodeWithCheckNull(config.visible, v -> o.visible = v);
				setCodeWithCheckNull(config.active, a -> o.active = a);
				setCodeWithCheckNull(config.scrollFactor, sf -> o.scrollFactor.set(sf.x, sf.y));
			}
		});
		setCallback("setProperty", function(tag:String, property:String, value:Dynamic) {
			if (PlayState.luaImages.exists(tag))
				Reflect.setProperty(PlayState.luaImages.get(tag), property, value);
			if (PlayState.luaText.exists(tag))
				Reflect.setProperty(PlayState.luaText.get(tag), property, value);
			if (PlayState.luaObjects.exists(tag))
				Reflect.setProperty(PlayState.luaObjects.get(tag), property, value);
			if (game != null)
				Reflect.setProperty(game, property, value);
		});
		setCallback("getProperty", function(tag:String, property:String) {
			if (PlayState.luaImages.exists(tag))
				return Reflect.getProperty(PlayState.luaImages.get(tag), property);
			if (PlayState.luaText.exists(tag))
				return Reflect.getProperty(PlayState.luaText.get(tag), property);
			if (PlayState.luaObjects.exists(tag))
				return Reflect.getProperty(PlayState.luaObjects.get(tag), property);
			if (game != null)
				return Reflect.getProperty(game, property);
			return null;
		});
		setCallback("setPosition", function(tag:String, x:Float, y:Float) {
			if (PlayState.luaImages.exists(tag))
				PlayState.luaImages.get(tag).setPosition(x, y);
			if (PlayState.luaText.exists(tag))
				PlayState.luaText.get(tag).setPosition(x, y);
			if (PlayState.luaObjects.exists(tag))
				PlayState.luaObjects.get(tag).setPosition(x, y);
		});
		setCallback("setScale", function(tag:String, x:Float, y:Float) {
			if (PlayState.luaImages.exists(tag))
				PlayState.luaImages.get(tag).scale.set(x, y);
			if (PlayState.luaText.exists(tag))
				PlayState.luaText.get(tag).scale.set(x, y);
		});

		// Text Functions
		setCallback("configText", function(tag:String, config:Dynamic) {
			if (PlayState.luaText.exists(tag)) {
				var t:FlxText = PlayState.luaText.get(tag);
				setCodeWithCheckNull(config.x, x -> t.x = x);
				setCodeWithCheckNull(config.y, y -> t.y = y);
				setCodeWithCheckNull(config.width, w -> t.width = w);
				setCodeWithCheckNull(config.text, txt -> t.text = txt);
				setCodeWithCheckNull(config.size, s -> t.size = s);
				setCodeWithCheckNull(config.color, c -> t.color = getColorName(c));
				setCodeWithCheckNull(config.alignment, a -> t.alignment = getAlignmentName(a));
				setCodeWithCheckNull(config.alpha, a -> t.alpha = a);
				setCodeWithCheckNull(config.scale, s -> t.scale.set(s.x, s.y));
				setCodeWithCheckNull(config.angle, a -> t.angle = a);
				setCodeWithCheckNull(config.visible, v -> t.visible = v);
				setCodeWithCheckNull(config.active, a -> t.active = a);
				setCodeWithCheckNull(config.scrollFactor, sf -> t.scrollFactor.set(sf.x, sf.y));
				setCodeWithCheckNull(config.antialiasing, aa -> t.antialiasing = aa);
				setCodeWithCheckNull(config.font, f -> t.font = Paths.font(f));
				setCodeWithCheckNull(config.borderSize, bs -> t.borderSize = bs);
				setCodeWithCheckNull(config.borderColor, bc -> t.borderColor = getColorName(bc));
				setCodeWithCheckNull(config.borderStyle, bs -> t.borderStyle = getBorderStyleName(bs));
				setCodeWithCheckNull(config.borderQuality, bq -> t.borderQuality = bq);
			}
		});
		setCallback("setText", function(tag:String, newText:String) {
			if (PlayState.luaText.exists(tag))
				PlayState.luaText.get(tag).text = newText;
		});

		// Sprite Functions
		setCallback("configSprite", function(tag:String, config:Dynamic) {
			if (PlayState.luaImages.exists(tag)) {
				var s:FlxSprite = PlayState.luaImages.get(tag);
				setCodeWithCheckNull(config.image, img -> s.loadGraphic(Paths.image(img)));
				setCodeWithCheckNull(config.x, x -> s.x = x);
				setCodeWithCheckNull(config.y, y -> s.y = y);
				setCodeWithCheckNull(config.width, width -> s.width = width);
				setCodeWithCheckNull(config.height, height -> s.height = height);
				setCodeWithCheckNull(config.alpha, alpha -> s.alpha = alpha);
				setCodeWithCheckNull(config.scale, scale -> s.scale.set(scale.x, scale.y));
				setCodeWithCheckNull(config.angle, angle -> s.angle = angle);
				setCodeWithCheckNull(config.visible, visible -> s.visible = visible);
				setCodeWithCheckNull(config.active, active -> s.active = active);
				setCodeWithCheckNull(config.scrollFactor, scrollFactor -> s.scrollFactor.set(scrollFactor.x, scrollFactor.y));
			}
		});
		setCallback("makeGraphic", function(tag:String, x:Float, y:Float, config:Dynamic) {
			if (!PlayState.luaImages.exists(tag)) {
				var s:FlxSprite = new FlxSprite(x, y);
				s.makeGraphic(config.width, config.height, getColorName(config.color));
				PlayState.luaImages.set(tag, s);
			}
		});
		setCallback("makeAnimationSprite", function(tag:String, x:Float, y:Float, path:String) {
			if (!PlayState.luaImages.exists(tag)) {
				var s:FlxSprite = new GameSprite(x, y);
				s.frames = Paths.spritesheet(path, SPARROW);
				PlayState.luaImages.set(tag, s);
			}
		});
		setCallback("addAnimationByPrefix", function(tag:String, name:String, prefix:String, fps:Int = 24, looped:Bool = false) {
			if (PlayState.luaImages.exists(tag))
				PlayState.luaImages.get(tag).animation.addByPrefix(name, prefix, fps, looped);
		});
		setCallback("playAnimation", function(tag:String, name:String, force:Bool = false, rev:Bool = false, frames:Int = 0) {
			if (PlayState.luaImages.exists(tag))
				return PlayState.luaImages.get(tag).animation.play(name, force, rev, frames);
		});

		// Sound Functions
		setCallback("playSound", (name:String, volume:Float = 1.0, loop:Bool = false) -> FlxG.sound.play(Paths.sound(name), volume, loop));
		setCallback("playMusic", (name:String, volume:Float = 1.0, loop:Bool = false) -> FlxG.sound.playMusic(Paths.music(name), volume, loop));

		// Language Functions
		setCallback("switchLanguage", (lang:String) -> Localization.switchLanguage(lang));
		setCallback("getLangKey", (key:String, ?lang:String) -> Localization.get(key, lang));

		// HScript Support
		setCallback("runHaxeCode", function(code:String) {
			initHaxeModule();
			try {
				var ret:Dynamic = hscript.executeStr(code);
				if (ret != null && !isOfTypes(ret, [Bool, Int, Float, String, Array]))
					ret = null;
				if (ret == null)
					Lua.pushnil(lua);
				return ret;
			} catch (e:Dynamic) {
				Lib.application.window.alert(e, "Lua Error!");
				Lua.pushnil(lua);
				return null;
			}
		});
		setCallback("runHaxeFunction", function(func:String, ?args:Array<Dynamic>) {
			initHaxeModule();
			try {
				var ret:Dynamic = hscript.executeFunc(func, args);
				if (ret != null && !isOfTypes(ret, [Bool, Int, Float, String, Array]))
					ret = null;
				if (ret == null)
					Lua.pushnil(lua);
				return ret;
			} catch (e:Dynamic) {
				Lib.application.window.alert(e, "Lua Error!");
				Lua.pushnil(lua);
				return null;
			}
		});
		setCallback("importHaxeLibrary", function(lib:String, ?packageName:String) {
			initHaxeModule();
			try {
				hscript.setVariable(lib, Type.resolveClass((packageName != null ? packageName + "." : "") + lib));
			} catch (e:Dynamic)
				Lib.application.window.alert(e, "Lua Error!");
		});

		// Misc. Functions
		setCallback("getInput", function(state:String, key:String) {
			return switch (state) {
				case "justPressed": FlxG.keys.anyJustPressed([getKeyName(key)]);
				case "justReleased": FlxG.keys.anyJustReleased([getKeyName(key)]);
				case "pressed": return FlxG.keys.anyPressed([getKeyName(key)]);
				default: false;
			}
		});

		if (execute)
			callFunction('create', []);
	}

	public function callFunction(name:String, args:Array<Dynamic>) {
		if (lua == null)
			return Function_Continue;

		Lua.getglobal(lua, name);

		for (arg in args)
			Convert.toLua(lua, arg);

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if (result != null && resultIsAllowed(lua, result)) {
			if (Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				if (error == 'attempt to call a nil value')
					return Function_Continue;
			}
			return Convert.fromLua(lua, result);
		}
		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		return switch (Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				true;
			default:
				false;
		}
	}

	public function setCallback(name:String, func:Dynamic)
		return Lua_helper.add_callback(lua, name, func);

	public function setVar(name:String, value:Dynamic) {
		if (lua == null)
			return;
		Convert.toLua(lua, value);
		Lua.setglobal(lua, name);
	}

	public function getVar(name:String)
		return Lua.getglobal(lua, name);

	public function deleteVar(name:String) {
		Lua.pushnil(lua);
		Lua.setglobal(lua, name);
	}

	public static function isOfTypes(value:Any, types:Array<Dynamic>) {
		for (type in types)
			if (Std.isOfType(value, type))
				return true;
		return false;
	}

	function setCodeWithCheckNull<T>(value:Null<T>, setter:T->Void) {
		if (value != null)
			setter(value);
	}

	public static function getColorName(name:String) {
		return switch (name) {
			case "white": FlxColor.WHITE;
			case "black": FlxColor.BLACK;
			case "red": FlxColor.RED;
			case "green": FlxColor.GREEN;
			case "blue": FlxColor.BLUE;
			case "yellow": FlxColor.YELLOW;
			case "purple": FlxColor.PURPLE;
			case "cyan": FlxColor.CYAN;
			case "gray": FlxColor.GRAY;
			case "orange": FlxColor.ORANGE;
			case "lime": FlxColor.LIME;
			case "magenta": FlxColor.MAGENTA;
			case "pink": FlxColor.PINK;
			case "brown": FlxColor.BROWN;
			case "transparent": FlxColor.TRANSPARENT;
			case "": FlxColor.WHITE;
			default: FlxColor.fromString(name) ?? FlxColor.WHITE;
		}
	}

	public static function getAlignmentName(name:String) {
		return switch (name) {
			case "left": FlxTextAlign.LEFT;
			case "center": FlxTextAlign.CENTER;
			case "right": FlxTextAlign.RIGHT;
			default: FlxTextAlign.LEFT;
		}
	}

	public static function getBorderStyleName(name:String) {
		return switch (name) {
			case "none": FlxTextBorderStyle.NONE;
			case "shadow": FlxTextBorderStyle.SHADOW;
			case "outline": FlxTextBorderStyle.OUTLINE;
			case "outlineFast": FlxTextBorderStyle.OUTLINE_FAST;
			default: FlxTextBorderStyle.NONE;
		}
	}

	public static function getKeyName(name:String) {
		return switch (name.toUpperCase()) {
			case "A": FlxKey.A;
			case "B": FlxKey.B;
			case "C": FlxKey.C;
			case "D": FlxKey.D;
			case "E": FlxKey.E;
			case "F": FlxKey.F;
			case "G": FlxKey.G;
			case "H": FlxKey.H;
			case "I": FlxKey.I;
			case "J": FlxKey.J;
			case "K": FlxKey.K;
			case "L": FlxKey.L;
			case "M": FlxKey.M;
			case "N": FlxKey.N;
			case "O": FlxKey.O;
			case "P": FlxKey.P;
			case "Q": FlxKey.Q;
			case "R": FlxKey.R;
			case "S": FlxKey.S;
			case "T": FlxKey.T;
			case "U": FlxKey.U;
			case "V": FlxKey.V;
			case "W": FlxKey.W;
			case "X": FlxKey.X;
			case "Y": FlxKey.Y;
			case "Z": FlxKey.Z;
			case "ZERO": FlxKey.ZERO;
			case "ONE": FlxKey.ONE;
			case "TWO": FlxKey.TWO;
			case "THREE": FlxKey.THREE;
			case "FOUR": FlxKey.FOUR;
			case "FIVE": FlxKey.FIVE;
			case "SIX": FlxKey.SIX;
			case "SEVEN": FlxKey.SEVEN;
			case "EIGHT": FlxKey.EIGHT;
			case "NINE": FlxKey.NINE;
			case "SPACE": FlxKey.SPACE;
			case "ENTER": FlxKey.ENTER;
			case "ESCAPE": FlxKey.ESCAPE;
			case "UP": FlxKey.UP;
			case "DOWN": FlxKey.DOWN;
			case "LEFT": FlxKey.LEFT;
			case "RIGHT": FlxKey.RIGHT;
			default: FlxKey.NONE;
		}
	}

	public function initHaxeModule() {
		if (hscript == null)
			hscript = new HScript();
	}

	override public function destroy() {
		if (lua != null) {
			Lua.close(lua);
			lua = null;
		}
	}
}