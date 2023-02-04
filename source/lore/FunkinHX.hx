package lore;

// import lore.WinAPI;
/*
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
*/
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import shadertoy.FlxShaderToyRuntimeShader;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import #if html5 lime.utils.Assets; #else sys.io.File; #end
#if sys import flixel.system.macros.FlxMacroUtil; #end

using StringTools;

/**
 * This is where all of the hscript stuff that isn't for FunkinLua is.
 * 
 * You can find all of that stuff in FunkinLua.HScript.\
 * 
 * getExprFromString and the import code (as well as the inspiration for this file in general) is owed to YoshiCrafter29.
 * 
 * Feel free to add any lua callbacks I forgot, and merge them as PRs, if you wish.
 * 
 * @see http://github.com/YoshiCrafter29/YoshiCrafterEngine
 */
 

class FunkinHX implements IFlxDestroyable {
	public static var supportedFileTypes(default, null):Array<String> = ["fnf" /* hi gray */, "hscript", "hsc", "hxs", "hx"]; // if multiple files exist, this list in reverse is the priority order
	private static var possiblyMaliciousCode(default, null):Array<String> = [
		"@:privateAccess",
		// "ClientPrefs.aspectRatio",
		"Highscore",
		"Process",
		"Sys.command",
		"Reflect"
	];
	private var interp:Interp;
	public var scriptName:String = "unknown";
	public var scriptType:FunkinHXType = NOEXEC;
	public var loaded:Bool = false;
	public var ignoreErrors:Bool = false;
	public static final println:String->Void = #if sys Sys.println #elseif js (untyped console).log #end;

	/**
	 * Takes a Hash<Dynamic> and returns a Dynamic object.
	 * Used here to make map representations of static abstract fields be accessible like they are in an abstract before compiling.
	 * @param obj 
	 * @return Dynamic
	 */
	private static function _dynamicify(obj:Map<String, Dynamic>):Dynamic {
		var nd:Dynamic = {};
		for (k => v in obj) Reflect.setField(nd, k, v);
		return nd;
	}

	public function destroy():Void {
		interp = null;
		scriptName = null;
		loaded = false;
	}

	public function traace(text:String):Void {
		var posInfo = interp.posInfos();
		println(scriptName + ":" + posInfo.lineNumber + ": " + text);
	}

	public function interpVarExists(k:String):Bool {
		if (interp != null) {
			return interp.variables.exists(k);
		}
		return false;
	}
	public function set(k:String, v:Dynamic):Void {
		if (interp != null) interp.variables.set(k, v);
	}

	public function get(k:String):Dynamic {
		if (interp != null) return interp.variables.get(k);
		return null;
	}

	public function remove(k:String):Void {
		if (interp != null) interp.variables.remove(k);
	}

	public function new(f:String, ?primer:FunkinHX->Void = null, ?type:FunkinHXType = FILE):Void {
		scriptName = f;
		scriptType = type;
		var ttr:String = null;
		if (type == FILE) {
			ttr = #if sys File.getContent #else Assets.getText #end (f);
		} else if (type == STRING) {
			ttr = f;
		}
		var tempBuf = new StringBuf();
		var tempArray = ttr.split("\n");
		var maliciousLines = [];
		for (i in 0...tempArray.length) {
			if (tempArray[i].startsWith("package;")) tempArray[i] = "";
			for (e in possiblyMaliciousCode) if (tempArray[i].contains(e)) {
				maliciousLines.push('Line ${i+1}: ${tempArray[i]}');
			}
		}
		if (maliciousLines.length > 0) {
			var alertText:String = 'Th${maliciousLines.length == 1 ? "is line" : "ese lines"} of code are potentially malicious:\n\n{lines}\n\nWould you like to continue executing the script?'; 
			alertText = alertText.replace("{lines}", maliciousLines.join("\n"));
			#if windows
			lime.app.Application.current.window.alert(alertText, 'Potentially malicious code detected');
			#end
			destroy();
			return;
		}
		for (i in tempArray) tempBuf.add(i + "\n");
		ttr = tempBuf.toString();
		interp = new Interp();
			set("DiscordClient", Discord.DiscordClient);
			set('preloadImage', (s:String) -> Paths.image(s));
			set('preloadSound', (s:String) -> Paths.sound(s));
			set('preloadMusic', (s:String) -> Paths.music(s));
			set('FlxG', flixel.FlxG);
			set('FlxSprite', flixel.FlxSprite);
			set('FlxCamera', flixel.FlxCamera);
			set('FlxTimer', flixel.util.FlxTimer);
			set('FlxTween', flixel.tweens.FlxTween);
			set('FlxEase', flixel.tweens.FlxEase);
			set('FlxText', flixel.text.FlxText);
			set('FlxGroup', flixel.group.FlxGroup);
			set('FlxTypedGroup', flixel.group.FlxGroup.FlxTypedGroup);
			set('FlxMath', flixel.math.FlxMath);
			set('FlxRect', flixel.math.FlxRect);
            // set('FlxBar', CreateFlxBar);
			// set('FlxBar', custom.FlxBar);
			set('FNFSprite', forever.FNFSprite);
			set('Song', Song);
			set('BGSprite', BGSprite);
			set('CoolUtil', CoolUtil);
			set('PlayState', PlayState);
            set('HealthIcon', HealthIcon);
			set('game', PlayState.instance);
			set('Paths', Paths);
			set('Conductor', Conductor);
			set('ClientPrefs', ClientPrefs);
			set('Character', Character);
			set('FlxTrail', FlxTrail);
			set('Alphabet', Alphabet);
			set('PauseSubState', PauseSubState);
			set('Json', haxe.Json);
			set("curBeat", 0);
			set("curStep", 0);
			set("curSection", 0);
			#if !flash
			set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
			set('FlxShaderToyRuntimeShader', FlxShaderToyRuntimeShader);
			set('ShaderFilter', openfl.filters.ShaderFilter);
			#end
			set('StringTools', StringTools);
	
			set('setVar', function(name:String, value:Dynamic)
			{
				PlayState.instance.variables.set(name, value);
			});
			set('getVar', function(name:String)
			{
				var result:Dynamic = null;
				if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
				return result;
			});
			set('removeVar', function(name:String)
			{
				if(PlayState.instance.variables.exists(name))
				{
					PlayState.instance.variables.remove(name);
					return true;
				}
				return false;
			});
			set("Sys", Sys);
			if (PlayState.inPlayState) {
				set('SONG', PlayState.SONG);
				set("add", PlayState.instance.add);
				set("addBehindDad", PlayState.instance.addBehindDad);
				set("addBehindGF", PlayState.instance.addBehindGF);
				set("addBehindBF", PlayState.instance.addBehindBF);
				set("remove", PlayState.instance.remove);
				set("insert", PlayState.instance.insert);
				set("indexOf", PlayState.instance.members.indexOf);
				set("openSubState", PlayState.instance.openSubState);
			}
			set("create", function() {});
			set("createPost", function() {});
			set("update", function(elapsed:Float) {});
			set("updatePost", function(elapsed:Float) {});
			set("startCountdown", function() {});
			set("onCountdownStarted", function() {});
			set("onCountdownTick", function(tick:Int) {});
			set("onUpdateScore", function(miss:Bool) {});
			set("onNextDialogue", function(counter:Int) {});
			set("onSkipDialogue", function() {});
			set("onSongStart", function() {});
			set("eventEarlyTrigger", function(eventName:String) {});
			set("onResume", function() {});
			set("onResultSong", function() {});
			set("onChangeMania", function() {});
			set("onPause", function() {});
			set("onSpawnNote", function(note:Note) {});
			set("onGameOver", function() {});
			set("onEvent", function(name:String, val1:Dynamic, val2:Dynamic) {});
			set("onMoveCamera", function(char:String) {});
			set("onEndSong", function() {});
			set("onGhostTap", function(key:Int) {});
			set("onKeyPress", function(key:Int) {});
			set("onKeyRelease", function(key:Int) {});
			set("noteMiss", function(note:Note) {});
			set("noteMissPress", function(direction:Int) {});
			set("opponentNoteHit", function(note:Note) {});
			set("goodNoteHit", function(note:Note) {});
			set("noteHit", function(note:Note) {});
			set("stepHit", function() {});
			set("beatHit", function() {});
			set("sectionHit", function() {});
			set("onRecalculateRating", function() {});
			set("Function_Stop", FunkinLua.Function_Stop);
			set("Function_StopScript", FunkinLua.Function_StopLua);
			set("Function_StopLua", FunkinLua.Function_StopLua); // just in case
			set("onIconUpdate", function(p:String) {});
			set("onHeadBop", function(name:String) {});
			set("onGameOverStart", function() {});
			set("onGameOverConfirm", function() {});
			set("onPauseMenuSelect", function(name:String) {});
			set("onOpenPauseMenu", function() {});
			set("onChangeCharacter", function(name:String, charObject:Character) {});
			set("Std", Std);
			//  set("WinAPI", WinAPI);
			set("script", this);
			set("destroy", function() {});
			set("Note", Note);
			set("StrumNote", StrumNote);
			set("trace", traace);
			set("X", flixel.util.FlxAxes.X);
			set("Y", flixel.util.FlxAxes.Y);
			set("XY", flixel.util.FlxAxes.XY);
			set("switchState", MusicBeatState.switchState);
			set("ModdedState", ModdedState);
			set("ModdedSubState", ModdedSubState);
            
			set("FlxColor", forever.RealColor);
            /*
			set("FlxAxes", _dynamicify(MacroTools.getMapFromAbstract(flixel.util.FlxAxes)));
			set("FlxColor", _dynamicify(MacroTools.getMapFromAbstract(flixel.util.FlxColor)));
			set("FlxKey", _dynamicify(MacroTools.getMapFromAbstract(flixel.input.keyboard.FlxKey)));
			set("FlxPoint", _dynamicify(MacroTools.getMapFromAbstract(flixel.math.FlxPoint)));
            */
			if (primer != null) primer(this);

			if (ttr != null) try {
				interp.execute(getExprFromString(ttr, true));
				trace("haxe file loaded successfully: " + f);
				loaded = true;
			} catch (e:Dynamic) traace('$e');
			call('create', []);
	}

	public function call(event:String, args:Array<Dynamic>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		var returnArray:Array<Dynamic> = [];
		#if hscript
		var ret:Dynamic = runFunc(event, args);

		// had to do this because there is a bug in haxe where Stop != Continue doesnt work
		var bool:Bool = ret == FunkinLua.Function_Continue;
		if(!bool) {
			returnVal = cast ret;
		}
		returnArray.push(returnVal);
		#end
		//trace(event, returnVal);
		if (returnArray.contains(FunkinLua.Function_Stop)) return FunkinLua.Function_Stop;
		return returnVal;
	}

    /*
	public static function CreateFlxBar(?x:Float = 0, ?y:Float = 0, ?direction:String = "", ?width:Int = 100, ?height:Int = 10, ?parentRef:Dynamic,
        ?variable:String = "", ?min:Float = 0, ?max:Float = 100, ?showBorder:Bool = false):Void
	{
        new FlxBar(x, y, getBarDirection(direction), width, height, parentRef, variable, min, max, showBorder);
	}

	public static function getBarDirection(?direction:String = ''):FlxBarFillDirection
        {
            switch(direction.toLowerCase().trim())
            {
                case 'LEFT_TO_RIGHT': return LEFT_TO_RIGHT;
                case 'RIGHT_TO_LEFT': return RIGHT_TO_LEFT;
                case 'TOP_TO_BOTTOM': return TOP_TO_BOTTOM;
                case 'BOTTOM_TO_TOP': return BOTTOM_TO_TOP;
                case 'VERTICAL_INSIDE_OUT': return VERTICAL_INSIDE_OUT;
                case 'VERTICAL_OUTSIDE_IN': return VERTICAL_OUTSIDE_IN;
                case 'HORIZONTAL_INSIDE_OUT': return HORIZONTAL_INSIDE_OUT;
                case 'HORIZONTAL_OUTSIDE_IN': return HORIZONTAL_OUTSIDE_IN;
            }
            return LEFT_TO_RIGHT;
        }
    */

	public static function getExprFromString(code:String, critical:Bool = false, ?path:String):Expr
	{
		if (code == null)
			return null;
		var parser = new hscript.Parser();
		parser.allowTypes = parser.allowMetadata = true;
		var ast:Expr = null;
		try
		{
			ast = parser.parseString(code);
		}
		catch (ex)
		{
			trace(ex);
			var exThingy = Std.string(ex);
			var line = parser.line;
			if (path != null)
			{
				if (!openfl.Lib.application.window.fullscreen && critical)
					openfl.Lib.application.window.alert('Failed to parse the file located at "$path".\r\n$exThingy at $line');
				trace('Failed to parse the file located at "$path".\r\n$exThingy at $line');
			}
			else
			{
				if (!openfl.Lib.application.window.fullscreen && critical)
					openfl.Lib.application.window.alert('Failed to parse the given code.\r\n$exThingy at $line');
				trace('Failed to parse the given code.\r\n$exThingy at $line');
				if (!critical)
					throw new haxe.Exception('Failed to parse the given code.\r\n$exThingy at $line');
			}
		}
		return ast;
	}

		public function runFunc(f:String, args:Array<Dynamic> = null):Any {
			if (!loaded) return null;
			try {
				return interp.callMethod(f, args);
			} catch (e:Dynamic) {
				if (!ignoreErrors) openfl.Lib.application.window.alert('Error with script: ' + scriptName + ' at line ' + interp.posInfos().lineNumber + ":\n" + e, 'Haxe script error');
				return null;
			}
			return null;
		}

		public function execute(code:String):Any {
			if (!loaded) return null;
			try {
				return interp.execute(getExprFromString(code, true));
			} catch (e:Dynamic) trace('$e');
			return null;
		}
	
}

@:enum abstract FunkinHXType(Int) from Int to Int {
	var FILE = 0;
	var STRING = 1;
	var NOEXEC = 2;
}
