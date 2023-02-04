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

class Language extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Language Setting Menu';
		rpcTitle = '体力を設定するメニュー'; //for Discord Rich Presence
		
		var option:Option = new Option('Japanese Menu:',
			'メニューのアセットを書いてくれた人を選んでください。 \n 黒髪零氏(kurokamizero)、この方は、sonotaを書いてくれた人です。 \n わらびもち氏(warabimoti)、この方はJPsych Engineの作成者です。',
			'JPMenu',
			'string',
			'kurokamizero',
			['kurokamizero', 'warabimoti']);
		addOption(option);
		
		var option:Option = new Option('Language:',
			'言語を選んでください、\n 日本語がいいなら、Jp \n 英語がいいなら、Eng',
			'Gengo',
			'string',
			'Eng',
			['Eng', 'Jp']);
		addOption(option);
		
		var option:Option = new Option('Accuracy Text',
			'精度の判定を、trueならJPに変え、falseならRatingの設定のままにする',
			'JPScore',
			'bool',
			true);
		addOption(option);

		super();
	}
}
