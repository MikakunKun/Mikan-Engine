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

class ExtraUIsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Extra UIs';
		rpcTitle = 'Extra UIs Settings Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Reating',
			"精度が99%だった場合 Leather = SSSS Psych = Sick になります。",
			'Reating',
			'string',
			'Psych Engine',
			['Psych Engine', 'Leather Engine']);
		addOption(option);

		var option:Option = new Option('Score Txt Up',
			"これにチェックをすると、スコアが、タイムバーの上に移動します。",
			'scoretxtup',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Debug State',
			"これにチェックをすると、Forever Engineみたいに、\n 左上に自分のいるsource codeの場所が表示されます。",
			'DebugState',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Camera Is Move',
			"これにチェックを付けると、ずっとカメラが動きます。",
			'cameraMove',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Combo Is Camera',
			"これにチェックをすると、カメラと動かなくなります。",
			'comboCamera',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Icon Bop:',
			'アイコンの動きをどれにするかを決めてください。',
			'iconbops',
			'string',
			'Classic',
			['Cassette', 'Bambi', 'Golden Apple', 'Classic']);
		addOption(option);

		var option:Option = new Option('accuracyText is Visible',
			"これにチェックをすると、Noteをどれだけ遅れて(早く)押したかが分かります。",
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