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

class HealthSetting extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Health Setting Menu';
		rpcTitle = '体力を設定するメニュー'; //for Discord Rich Presence
		
		var option:Option = new Option('HealthText',
			'これにチェックをすると、体力を表す文字が出るよ！',
			'healthtxt',
			'bool',
			false);
		addOption(option);
		
		super();
	}
}
