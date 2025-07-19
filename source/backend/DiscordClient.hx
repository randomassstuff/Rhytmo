package backend;

#if FUTURE_DISCORD_RPC
import hxdiscord_rpc.Discord as RichPresence;
import hxdiscord_rpc.Types;
import sys.thread.Thread;

class DiscordClient {
	public static var initialized:Bool = false;

	private static final _defaultID:String = "1353181104307306666";
	public static var clientID(default, set):String = _defaultID;

	private static function set_clientID(newID:String) {
		var change:Bool = (clientID != newID);
		clientID = newID;

		if (change && initialized) {
			shutdown();
			load();
			changePresence();
		}
		return newID;
	}

	public static function load():Void {
		if (initialized)
			return;

		final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		RichPresence.Initialize(clientID, cpp.RawPointer.addressOf(handlers), false, null);

		Thread.create(function() {
			while (true) {
				RichPresence.RunCallbacks();
				Sys.sleep(1);
			}
		});

		Application.current.window.onClose.add(() -> {
			if (initialized)
				shutdown();
		});

		initialized = true;
	}

	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool,
			?endTimestamp:Float):Void {
		final discordPresence:DiscordRichPresence = new DiscordRichPresence();
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		discordPresence.details = details;

		if (state != null)
			discordPresence.state = state;

		discordPresence.largeImageKey = 'icon';
		discordPresence.largeImageText = 'Rhythmo';
		discordPresence.smallImageKey = smallImageKey;
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
		RichPresence.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		final user:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		if (Std.parseInt(cast(user.discriminator, String)) != 0)
			trace('(Discord) Connected to User "${cast (user.username, String)}#${cast (user.discriminator, String)}"');
		else
			trace('(Discord) Connected to User "${cast (user.username, String)}"');

		changePresence('Just Started');
	}

	public static function resetClientID() {
		clientID = _defaultID;
	}

	public static function shutdown() {
		initialized = false;
		RichPresence.Shutdown();
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('(Discord) Disconnected ($errorCode: ${cast (message, String)})');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('(Discord) Error ($errorCode: ${cast (message, String)})');
	}
}
#end