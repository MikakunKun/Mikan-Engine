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

class Language extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Language Setting Menu';
		rpcTitle = 'Language Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Language:',
			'Choose your language, Jp if you prefer Japanese Eng if you prefer English',
			'Gengo',
			'string',
			'Eng',
			['Eng', 'Jp']);
		addOption(option);

		super();
	}
}
