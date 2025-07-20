package backend;

import haxe.io.Bytes;
import haxe.zip.Reader;
import haxe.io.BytesOutput;

/**
 * @author maybekoi
 * @see https://github.com/Moon4K-Dev/Moon4K
 */
class AutoUpdater {
	private static inline var DOWNLOAD_URL =
		#if windows
		"https://github.com/JoaTH-Team/Rhythmo-SC/releases/latest/download/release-windows.zip"
		#elseif mac
		"https://github.com/JoaTH-Team/Rhythmo-SC/releases/latest/download/release-mac.zip"
		#elseif linux
		"https://github.com/JoaTH-Team/Rhythmo-SC/releases/latest/download/release-linux.zip"
		#end;

	public static function downloadUpdate():Void {
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.6;
		FlxG.state.add(bg);

		var waitTxt:FlxText = new FlxText(0, 0, FlxG.width, "DOWNLOADING UPDATE\nPLEASE WAIT...");
		waitTxt.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		waitTxt.screenCenter();
		FlxG.state.add(waitTxt);

		trace("Attempting to download from: " + DOWNLOAD_URL);
		var data = downloadWithRedirects(DOWNLOAD_URL);
		if (data != null && data.length > 0)
			handleDownloadedData(data);
		else {
			trace("Download failed");
			waitTxt.color = FlxColor.RED;
			waitTxt.text = "Download failed. Please check your internet connection and try again.\n"
				+ "Error details: Unable to connect to update server.\n"
				+ "URL: "
				+ DOWNLOAD_URL;
		}
	}

	private static function downloadWithRedirects(url:String, redirectCount:Int = 0):Bytes {
		if (redirectCount > 5) {
			trace("Too many redirects");
			return null;
		}

		try {
			var http = new Http(url);
			var output = new BytesOutput();
			var result:Bytes = null;

			http.onStatus = function(status:Int) {
				trace("HTTP Status: " + status);
				if (status >= 300 && status < 400) {
					var newUrl = http.responseHeaders.get("Location");
					if (newUrl != null) {
						trace("Redirecting to: " + newUrl);
						result = downloadWithRedirects(newUrl, redirectCount + 1);
					}
				}
			}

			http.onError = (error:String) -> trace("HTTP Error: " + error);
			http.customRequest(false, output);

			if (result == null)
				result = output.getBytes();

			return result;
		} catch (e:Dynamic) {
			trace("Error downloading update: " + e);
			return null;
		}
	}

	private static function handleDownloadedData(data:Bytes):Void {
		try {
			if (data == null || data.length == 0)
				throw "Downloaded data is empty";
			var tempPath = "temp_update.zip";
			trace("Downloading update, size: " + data.length + " bytes");
			File.saveBytes(tempPath, data);
			trace("Update downloaded successfully");

			if (!FileSystem.exists(tempPath) || FileSystem.stat(tempPath).size == 0)
				throw "Downloaded file is empty or doesn't exist";

			extractUpdate(tempPath);
		} catch (e:Dynamic) {
			trace("Error saving update: " + e);
			FlxG.state.add(new FlxText(0, 0, FlxG.width, "Update save failed: " + e));
		}
	}

	private static function extractUpdate(zipPath:String):Void {
		try {
			var zipFile = File.read(zipPath, true);
			var entries = Reader.readZip(zipFile);
			zipFile.close();

			trace("Zip file opened, entries count: " + entries.length);

			for (entry in entries) {
				var fileName = entry.fileName;
				trace("Extracting: " + fileName);

				if (fileName == "Rhythmo.exe" || fileName == "lime.ndll") {
					var content = Reader.unzip(entry);
					File.saveBytes(fileName + ".new", content);
					trace("Saved new version of: " + fileName);
				} else {
					var content = Reader.unzip(entry);
					var path = Path.directory(fileName);
					if (path != "" && !FileSystem.exists(path))
						FileSystem.createDirectory(path);
					File.saveBytes(fileName, content);
					trace("Extracted: " + fileName);
				}
			}

			FileSystem.deleteFile(zipPath);
			trace("Temporary zip file deleted");
			finishUpdate();
		} catch (e:Dynamic) {
			trace("Error during extraction: " + e);
			FlxG.state.add(new FlxText(0, 0, FlxG.width, "Extraction failed: " + e));
		}
	}

	private static function finishUpdate():Void {
		var batchContent = '@echo off\n' + 'timeout /t 1 /nobreak > NUL\n' + 'move /y Rhythmo.exe.new Rhythmo.exe\n' + 'move /y lime.ndll.new lime.ndll\n'
			+ 'start "" Rhythmo.exe\n' + 'del "%~f0"';

		File.saveContent("finish_update.bat", batchContent);

		Sys.command("start finish_update.bat");
		Application.current.window.close();
	}
}
