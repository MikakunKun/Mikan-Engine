package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class TIMER extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "";

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time);
		});
		#end
	}

	function qatarShit():String {
		/*
		var leGoal = new Date(2022, 12, 25, 9, 0, 0).getTime();

		var second = 1000;
		var minute = second * 60;
		var hour = minute * 60;
		var day = hour * 24;

		var leDate = Date.now().getTime();
		// var timeLeft = leGoal - leDate;
		var timeLeft = leDate;

		var shitArray:Array<Dynamic> = [
			Math.floor(timeLeft / (day)),
         	Math.floor((timeLeft % (day)) / (hour)),
			Math.floor((timeLeft % (hour)) / (minute)),
        	Math.floor((timeLeft % (minute)) / second)
		];

		var zeroShitArray:Array<String> = ["day","hour","minute","second"];
		
		var leftTime:String = "";

		for (i in 0...shitArray.length) {
			if (shitArray[i] < 10) {
				zeroShitArray[i] = '0' + shitArray[i];
			} else zeroShitArray[i] = '' + shitArray[i];
			var dosPuntos:String = (i > 0 && i < shitArray.length) ? ":" : "";

			leftTime += dosPuntos + zeroShitArray[i];
		}

		return leftTime;
		*/
		var shitArray:Array<Dynamic> = [
			Date.now().getFullYear(), // 年
			(Date.now().getMonth() + 1), // 月
			Date.now().getDate(), // 日
			Date.now().getHours(), // 時間
			Date.now().getMinutes(), // 分
        	Date.now().getSeconds() // 秒
		];

		var zeroShitArray:Array<String> = ["year","month","day","hour","minute","second"];

		var leftTime:String = "";

		for (i in 0...shitArray.length) {
			if (shitArray[i] < 10) {
				zeroShitArray[i] = '0' + shitArray[i];
			} else zeroShitArray[i] = '' + shitArray[i];
			var dosPuntos:String = (i > 0 && i < shitArray.length) ? ":" : "";

			leftTime += dosPuntos + zeroShitArray[i];
		}
		
		return leftTime;
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		text = "";
		
		#if openfl
		text += "\n";
		#end

		// text += "\nMikan Engine Version: " + MainMenuState.mikanEngineVersion;
		text += "\nThis Time Is: " + qatarShit();

		if (ClientPrefs.DebugState)
			text += "\nState: " + Main.initialState;

		text += "\n";
		
		textColor = 0xFFFFFFFF;
	}
}