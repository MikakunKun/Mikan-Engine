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

class ForeverStates extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Forever Engine Ui Option';
		rpcTitle = 'Forever Engine Ui Option Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Counter:',
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			'Counter',
			'string',
			'None',
			['None', 'Left', 'Right']);
		addOption(option);

		var option:Option = new Option('Display Accuracy',
			"Whether to display your accuracy on screen.",
			'DisplayAccuracy',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Reduced Movements',
			"Whether to reduce movements, like icons bouncing or beat zooms in gameplay.",
			'DisplayAccuracy',
			'bool',
			false);
		addOption(option);

		/*
		var option:Option = new Option('Simply Judgements',
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.",
			'DisplayAccuracy',
			'bool',
			false);
		addOption(option);
		*/

		super();
	}
}
