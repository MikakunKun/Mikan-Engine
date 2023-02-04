package sonotas;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class ExtraUIsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Extra UIs';
		rpcTitle = 'Extra UIs Settings Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Reating',
			"Reating 99% Leather = SSSS Psych = Sick",
			'Reating',
			'string',
			'Psych Engine',
			['Psych Engine', 'Leather Engine']);
		addOption(option);

		var option:Option = new Option('Score Txt Up',
			"Checking this will move the score up.",
			'scoretxtup',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Debug State',
			"If this is checked, the FPS will show where you are now.",
			'DebugState',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Camera Is Move',
			"If checked, Camera Move",
			'cameraMove',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Combo Is Camera',
			"If not checked, Combo Is UI Camera",
			'comboCamera',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Icon Bop:',
			'Cassette is Cassette Girl Mod icons bops, Bambi is Dave & Bambi icons bops, Golden Apple is Dave & Bambi Golden Apple Edition icon bops, Classic is Vanilla FnF icons bops',
			'iconbops',
			'string',
			'Classic',
			['Cassette', 'Bambi', 'Golden Apple', 'Classic']);
		addOption(option);

		var option:Option = new Option('accuracyText is Visible',
			"Checking this will tell you how late (early) you pressed Note.",
			'accuracyTextVisible',
			'bool',
			false);
		addOption(option);

		super();
	}

	var mchangedMusic:Bool = false;
	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}