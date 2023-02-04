package japanese.options;

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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'ゲームプレイ設定画面'; //for Discord Rich Presence

		var option:Option = new Option('Controller Mode',
			'コントローラを使用する場合は、チェックを入れてください。',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'チェックすると、ノーツは下に流れます。', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'チェックすると、プレイヤーノーツが中央に配置され、相手ノーツは外側に配置されます。',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'チェックを外すと、相手の譜面が表示されなくなります。',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"チェックを外すと、ノーツ以外のところで入力すると、ミスになります。",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"チェックを外すと、Rキーでリセットすることができるようになります。",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'音量を指定することで、ノーツヒット時にサウンドが流れるようになります。',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'ノーツ入力判定（Sickなど）が出るタイミングを変更します。\n数値を高くするほどタイミングが遅くなります。',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Sick!判定の最大時間をミリ秒単位で変更します。\n（デフォルト:45ms，短押しで3ms調整します。）',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 90;
		option.changeValue = 3;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Good判定の最大時間をミリ秒単位で変更します。\n（デフォルト:90ms，短押しで3ms調整します。）',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 21;
		option.maxValue = 135;
		option.changeValue = 3;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Bad判定の最大時間をミリ秒単位で変更します。\n（デフォルト:135ms，短押しで5ms調整します。）',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 33;
		option.maxValue = 205;
		option.changeValue = 5;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'ミスにならないノーツタイミングタイミングを設定します。\n数値を高くするほど入力が早かったり、遅かったりしてもミスになりずらくなります。\n（1フレーム移動します）',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 3;
		option.maxValue = 15;
		option.changeValue = 1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}