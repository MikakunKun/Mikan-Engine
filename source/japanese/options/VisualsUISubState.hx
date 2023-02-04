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

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'ビジュアル＆UI設定画面'; //for Discord Rich Presence
		
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
		
		var option:Option = new Option('Language:',
			'精度の判定を、trueならJPに変え、falseならRatingの設定のままにする',
			'JPScore',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Player Note Splashes',
			"チェックを外すと、Sick!判定の時にパーティクルが表⽰されなくなります。",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes',
			"チェックを外すと、相手がノーツを叩く時にパーティクルが表⽰されなくなります。",
			'OpponentnoteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'チェックすると、ノーツとタイムバー以外すべてが非表示になります。',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			'タイムバーの表示タイプを選んでください。\n（Disabledを選ぶと無効になります。）',
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"チェックを外すと点滅する光が無くなります。",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"チェックを外すと、相手が歌いだした後に、HUDが拡大&縮小表示がされなくなります。",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"オフにすると、ノーツを叩くたびにスコアの文字が拡大&縮小表示がされなくなります。",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'体力バーとアイコンの不透明度を設定します。\n（0%に近いほど透明になります。）',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'チェックすると、左上にFPS値とエンジンバージョンを表示します。',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pause Screen Song:',
			"ポーズ画面で再生するBGMを選んでください。",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}