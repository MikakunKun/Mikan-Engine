package japanese.sonotas;

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

class UiStates extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Ui Engine Select Menu';
		rpcTitle = 'Uiのエンジン選び'; //for Discord Rich Presence
		
		var option:Option = new Option('Ui Select:',
			'UiのEngineを選んでください。',
			'UiStates',
			'string',
			'Psych-Engine',
			['Psych-Engine', 'Kade-Engine', 'Leather-Engine', 'Forever-Engine']);
		addOption(option);

		var option:Option = new Option('sideRatings',
			"これにチェックをすると、左端にRatingなどが表示されます。",
			'sideRatings',
			'bool',
			false);
		addOption(option);

		super();
	}
}
