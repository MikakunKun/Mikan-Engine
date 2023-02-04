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

class ForeverStates extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Forever Engine Ui Option';
		rpcTitle = 'Forever Engine Ui Option Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Counter:',
			'判定結果をどこかに表示させたいかどうか、どこに表示させたいかを選択します。',
			'Counter',
			'string',
			'None',
			['None', 'Left', 'Right']);
		addOption(option);

		var option:Option = new Option('Display Accuracy',
			"精度を画面上に表示するかどうか。",
			'DisplayAccuracy',
			'bool',
			true);
		addOption(option);

		/*
		var option:Option = new Option('Reduced Movements',
			"ゲームプレイ中のアイコンのバウンドやビートズームのような動きを減らすかどうか。",
			'ReducedMovements',
			'bool',
			false);
		addOption(option);

		
		var option:Option = new Option('Simply Judgements',
			"判定アニメーションを簡略化し、一度に1つの判定・評価スプライトを表示するようにしました。",
			'DisplayAccuracy',
			'bool',
			false);
		addOption(option);
		*/

		super();
	}
}
