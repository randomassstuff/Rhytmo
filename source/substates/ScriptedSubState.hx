package substates;

class ScriptedSubState extends ExtendableSubState {
	public var path:String = "";
	public var script:HScript = null;

	public static var instance:ScriptedSubState = null;

	public function new(_path:String = null, ?args:Array<Dynamic>) {
		if (_path != null)
			path = _path;

		instance = this;

		try {
			var folders:Array<String> = [Paths.file('substates/')];
			#if FUTURE_POLYMOD
			for (mod in ModHandler.getModIDs())
				folders.push('mods/$mod/substates/');
			#end
			for (folder in folders) {
				if (FileSystem.exists(folder)) {
					for (file in FileSystem.readDirectory(folder)) {
						if (file.startsWith(path) && Paths.validScriptType(file)) {
							path = folder + file;
						}
					}
				}
			}

			script = new HScript(path, false);
			script.execute(path, false);

			scriptSet('substate', this);
			scriptSet('add', this.add);
			scriptSet('insert', this.insert);
			scriptSet('remove', this.remove);
			scriptSet('members', this.members);
			scriptSet('multiAdd', this.multiAdd);
			scriptSet('multiRemove', this.multiRemove);
		} catch (e:Dynamic) {
			script = null;
			trace('Error while getting script: $path!\n$e');
		}

		scriptExecute('new', args);

		super();
	}

	override function create() {
		scriptExecute('create', []);
		super.create();
	}

	override function update(elapsed:Float) {
		scriptExecute('update', [elapsed]);
		super.update(elapsed);

		if (Input.justPressed('f4')) // emergency exit
			ExtendableState.switchState(new MenuState());
	}

	override function beatHit() {
		scriptExecute('beatHit', [curBeat]);
		scriptSet('curBeat', curBeat);
		super.beatHit();
	}

	override function stepHit() {
		scriptExecute('stepHit', [curStep]);
		scriptSet('curStep', curStep);
		super.stepHit();
	}

	override function destroy() {
		scriptExecute('destroy', []);
		super.destroy();
	}

	override function onFocus() {
		scriptExecute('onFocus', []);
		super.onFocus();
	}

	override function onFocusLost() {
		scriptExecute('onFocusLost', []);
		super.onFocusLost();
	}

	function scriptSet(key:String, value:Dynamic) {
		script?.setVariable(key, value);
	}

	function scriptExecute(func:String, args:Array<Dynamic>) {
		try {
			script?.executeFunc(func, args);
		} catch (e:Dynamic) {
			trace('Error executing $func!\n$e');
		}
	}
}