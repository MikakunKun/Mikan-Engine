package forever;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import CoolUtil;
// import forever.InfoHud;
import Conductor;
import forever.Timings;
import PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	private var timingsMap:Map<String, FlxText> = [];

	public static var bar1:FlxSprite;
	public static var bar2:FlxSprite;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		bar1 = new FlxSprite(0, -800).loadGraphic(Paths.image('backgrounds/stage/blackBar'));
		bar1.antialiasing = true;
		bar1.scale.set(3000, 500);
		bar1.active = false;
		add(bar1);

		bar2 = new FlxSprite(0, 1500).loadGraphic(Paths.image('backgrounds/stage/blackBar'));
		bar2.antialiasing = true;
		bar2.scale.set(3000, 500);
		bar2.active = false;
		add(bar2);
		
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (ClientPrefs.downScroll)
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(FlxG.width / 2, healthBarBG.y + 40, 0, scoreDisplay, 20);
		scoreBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoreText();
		scoreBar.scrollFactor.set();
		add(scoreBar);

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song) + ' - ' + CoolUtil.difficulties[PlayState.storyDifficulty];
		var engineDisplay:String = "Mikan Engine v" + MainMenuState.mikanEngineVersion;
		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
		engineBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineBar.updateHitbox();
		engineBar.x = FlxG.width - engineBar.width - 5;
		engineBar.scrollFactor.set();
		add(engineBar);

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		add(infoBar);

		// counter
		if (ClientPrefs.Counter != 'None') {
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length) {
				var textAsset:FlxText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (ClientPrefs.Counter == 'Left');

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		var iconLerp = 0.5;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (characterPlayingAs != -1)
		{
			if (iconP1.animation.frames == 3) {
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else if (healthBar.percent > 80)
					iconP1.animation.curAnim.curFrame = 2;
				else
					iconP1.animation.curAnim.curFrame = 0;
			} else if (iconP1.animation.frames == 1) {
				iconP1.animation.curAnim.curFrame = 0;
			} else {
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else
					iconP1.animation.curAnim.curFrame = 0;
			}
			
			if (iconP2.animation.frames == 3) {
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else if (healthBar.percent < 20)
					iconP2.animation.curAnim.curFrame = 2;
				else 
					iconP2.animation.curAnim.curFrame = 0;
			} else if (iconP2.animation.frames == 1) {
				iconP2.animation.curAnim.curFrame = 0;
			} else {
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else 
					iconP2.animation.curAnim.curFrame = 0;
			}
		}
	}

	private final divider:String = ' - ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.songMisses;
		scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = ClientPrefs.DisplayAccuracy;
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.songMisses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (ClientPrefs.Counter != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
	}

	public function beatHit()
	{
		if (!ClientPrefs.ReducedMovements)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 45));
			iconP2.setGraphicSize(Std.int(iconP2.width + 45));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		//
	}
}
