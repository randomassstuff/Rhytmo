package backend;

#if openfl
import openfl.system.Capabilities;
#end
import hx_arabic_shaper.ArabicReshaper;
import hx_arabic_shaper.bidi.UBA;

/**
 * A simple localization system.
 * Please credit me if you use it!
 * @author Joalor64GH
 */
class Localization {
	private static final DEFAULT_DIR:String = "languages";

	private static var data:Map<String, Dynamic>;
	private static var currentLanguage:String;

	public static var DEFAULT_FONT:String = "vcr";

	public static var DEFAULT_LANGUAGE:String = "en";
	public static var directory:String = DEFAULT_DIR;

	public static var systemLanguage(get, never):String;

	public static function get_systemLanguage() {
		#if openfl
		return Capabilities.language;
		#else
		return throw "This Variable is for OpenFl only!";
		#end
	}

	public static function loadLanguages() {
		data = new Map<String, Dynamic>();

		var path:String = Paths.txt("languages/languagesList");
		if (Paths.exists(path)) {
			for (language in Paths.getText(path).split('\n')) {
				var langCode:String = language.trim().split(':')[1];
				data.set(langCode, loadLanguageData(langCode));
			}
		}

		var config = ArabicReshaper.getDefaultConfig();
		config.delete_harakat = true;
		ArabicReshaper.init(config);
	}

	private static function loadLanguageData(language:String):Dynamic {
		try {
			return TJSON.parse(Paths.getText(path(language)));
		} catch (e:Dynamic) {
			trace('language file not found: $e');
			return TJSON.parse(Paths.getText(path(DEFAULT_LANGUAGE)));
		}
	}

	public static function switchLanguage(newLanguage:String) {
		if (newLanguage == currentLanguage)
			return;

		currentLanguage = newLanguage;
		data.set(newLanguage, loadLanguageData(newLanguage));
		trace('Language changed to $currentLanguage');
	}

	public static function get(key:String, ?language:String):String {
		var targetLanguage:String = language != null ? language : currentLanguage;
		var languageData = data.get(targetLanguage);

		if (data != null && data.exists(targetLanguage) && languageData != null && Reflect.hasField(languageData, key)) {
			var field:String = Reflect.field(languageData, key);
			return (targetLanguage == "ar") ? shapeArabicText(field) : field;
		}

		return 'missing key: $key';
	}

	public static function getFont():String {
		if (data != null && data.exists(currentLanguage)) {
			var languageData = data.get(currentLanguage);
			return Reflect.hasField(languageData, "customFont") ? Reflect.field(languageData, "customFont") : DEFAULT_FONT;
		}

		return DEFAULT_FONT;
	}

	private static function path(language:String)
		return Paths.file(Path.join([directory, language + ".json"]));

	// for arabic text
	public static function shapeArabicText(text:String):String
		return UBA.display(ArabicReshaper.reshape(text));

	public static function dispose()
		ArabicReshaper.dispose();
}

class Locale {
	public var lang:String;
	public var code:String;

	public function new(lang:String, code:String) {
		this.lang = lang;
		this.code = code;
	}
}