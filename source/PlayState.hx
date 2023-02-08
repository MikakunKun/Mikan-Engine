package;

import haxe.Timer;
import flixel.graphics.FlxGraphic;
import WiggleEffect.ChromAbEffect;
import FlxPerspectiveSprite.FlxPerspectiveTrail;
#if desktop
import Discord.DiscordClient;
#end
import flixel.tweens.misc.VarTween;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import leather.ResultsScreenSubstate;
import forever.Timings;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import sys.io.File;

import Conductor.Rating;
import utilities.Ratings;

#if sys
import sys.FileSystem;
import sys.io.File;
#else
import js.html.FileSystem;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	// Forever Engine rating
	public static var ForeverratingStuff:Array<Dynamic> = [
		['f', 0.7], //From 0% to 69%
		['e', 0.75], //From 70% to 74%
		['d', 0.8], //From 75% to 79%
		['c', 0.85], //From 80% to 84%
		['b', 0.9], //From 85% to 89%
		['A', 0.95], //From 90% to 94%
		['S', 1], //From 95% to 99%
		['S+', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	// Psych Engine rating
	public static var oldratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	// Leather Engine rating
	public static var ratingStuff:Array<Dynamic> = [
		['Noob', 0], //From 0% to 1%
		['G', 0.02], //From 2% to 4%
		['F', 0.05], //From 5% to 9%
		['E', 0.1], //From 10% to 49%
		['D', 0.5], //From 50% to 64%
		['C', 0.65], //From 65% to 69%
		['B', 0.7], //From 70% to 79%
		['B+', 0.8], //From 80% to 84%
		['A', 0.85], //From 85% to 88%
		['AA', 0.9], //From 89% to 91%
		['S', 0.92], //From 92% to 94%
		['SS', 0.95], //From 95% to 97%
		['SSS', 0.98], //From 98% to 99%
		['SSSS', 1], //99%
		['SSSSS', 1] //The value on this one isn't used actually, since Perfect is always "1"
	]; 
	// Me Setting rating
	public static var oratingStuff:Array<Dynamic> = [
		['You Noob!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Suck', 0.5], //From 40% to 49%
		['Bad', 0.6], //From 50% to 59%
		['Bruh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Normal Player', 0.8], //From 70% to 79%
		['Good?', 0.85], //From 80% to 84%
		['Great Nice', 0.9], //From 85% to 89%
		['Nice Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	// JPsych Engine rating
	public static var JpratingStuff:Array<Dynamic> = [
		['最悪だな!', 0.2], //From 0% to 19%
		['ダメだ!', 0.4], //From 20% to 39%
		['悪い', 0.5], //From 40% to 49%
		['まじかよ', 0.6], //From 50% to 59%
		['あぁ...', 0.69], //From 60% to 68%
		['ナイス', 0.7], //69%
		['いいね!', 0.8], //From 70% to 79%
		['グッド!', 0.9], //From 80% to 89%
		['かっこいい!', 1], //From 90% to 99%
		['パーフェクト!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	]; 

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Dad> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartBarSprites:Map<String, ModchartBarSprite> = new Map<String, ModchartBarSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Dad> = new Map<String, Dad>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartBarSprites:Map<String, ModchartBarSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var lDance:Bool = false;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	
	public var maniaRandom:String = "false";

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var otherGroup:FlxTypedSpriteGroup<FlxPerspectiveSprite>;
	public var trailGroup:FlxTypedSpriteGroup<FlxPerspectiveTrail>;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isJapanMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var inPlayState:Bool = true;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	public var dadvocals:FlxSound;
	public var boyfriendvocals:FlxSound;

	public var dad:Dad = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums1:FlxTypedGroup<StrumNote>;
	public var playerStrums2:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var Notelength:Int = 0;
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthShown:Float = 1;
	public var minhealth:Float = 0;
	public var maxhealth:Float = 2;
	public var dadminhealth:Float = 2;
	public var boyfriendminhealth:Float = 2;
	public var dadmaxhealth:Float = 2;
	public var boyfriendmaxhealth:Float = 2;
	public var combo:Int = 0;
	
	public var dadhealth:Float = 1;
	public var bfhealth:Float = 1;
	public var dadhpShown:Float = 1;
	public var bfhpShown:Float = 1;
	public var dadcombo:Int = 0;
	public var bfcombo:Int = 0;

	public var HealthRight:Bool = true;

	private var healthBarBG:AttachedSprite;
	private var foreverhealthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var dadhealthBar:FlxBar;
	public var bfhealthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var marvelous:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	public var p1Ratings:PlayerStates = null;
	public var p2Ratings:PlayerStates = null;
	public static var playerList:Array<PlayerStates> = [];

	public var ranksList:Array<String> = ["Skill Issue", "E", "D", "C", "B", "A", "S"]; //for score text
	public var fcList:Array<String> = ["[Nice FC]", "[Awful FC]", "[SFC]", "[GFC]", "[FC]", "[FC]", "[SDCB]", "[Pass]","youre just terrible"]; //fc shit

	public static var mania:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	// =======================================================================================================================================
	// Changed mod vars =========================================================================================================================
	// =======================================================================================================================================

	// Drippin boss
	var particleEmitter:FlxEmitter;
	var particleEmitter2:FlxEmitter;
	var sharkEmitter:FlxEmitter;
	var tentacleEmitter:FlxEmitter;
	var tentacleEmitter2:FlxEmitter;

	var tentacleDir:Int = 1;
	var tentacleRate:Int = 1;
	var tentacles:Bool = true;
	var spacebarMash:BGSprite;
	var spaceAmount:Int = 0;
	var spaceAmountNum:Int = 3;
	var spaceTimerDefault:Int = 10;
	var spaceTimer:FlxTimer;
	var spaceTimerText:FlxText;

	var bossToggle1:Bool = false;
	var bossToggle2:Bool = false;

	// =======================================================================================================================================
	// Not Changed mod vars =========================================================================================================================
	// =======================================================================================================================================

	//Shaggy Mod Event
	var burst:FlxPerspectiveSprite;
	public static var rotCam = false;
	var rotCamSpd:Float = 1;
	var rotCamRange:Float = 10;
	var rotCamInd = 0;

	//cum
	var bgDim:FlxSprite;
	var fullDim = false;
	var noticeTime = 0;
	var dimGo:Bool = false;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;

	public var scoreTxt:FlxText;
	public var healthTxt:FlxText;

	public var P1scoreTxt:FlxText;
	public var P2scoreTxt:FlxText;
	public var hudThing:FlxTextAlign = LEFT;

	public var accuracy:Float = 100.0;

	// Leather Engine Setting
	var infoTxt:FlxText;

	// Forever Engine Setting
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;
	var scoreDisplay:String;
	

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudCamZoom:Float = 1.0;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	public var haxeArray:Array<lore.FunkinHX> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Array<Dynamic>>;
	private var dadkeysArray:Array<Array<Dynamic>>;
	private var bfkeysArray:Array<Array<Dynamic>>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	public static var ratingPositionX:Float;
	public static var ratingPositionY:Float;

	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	public static var characterPlayingAs:Int = 0;

	public static var DadOtherCharacterCamera:Int = 0;
	public static var BfOtherCharacterCamera:Int = 0;

	public static var fliplol:Bool = false;

	public var stile:String = "bf";
	public var playStailText:String = "bf";

	public var ratingText:FlxText;

	private var timingsMap:Map<String, FlxText> = [];

	public var ratingStr:String = "";

	var left = (ClientPrefs.Counter == 'Left');

	override public function create()
	{
		Paths.clearStoredMemory();

		stile = ClientPrefs.getGameplaySetting('playstail','bf');
		switch (stile)
		{
			case "bf":
				characterPlayingAs = 0;
				playStailText = 'boyfriend play';
			case "opponent":
				characterPlayingAs = 1;
				playStailText = 'opponent play';
			case "not player health both":
				characterPlayingAs = -1;
				playStailText = 'not player health both play';
			case "player health both":
				characterPlayingAs = -2;
				playStailText = 'player health both play';
			case "vs player health":
				characterPlayingAs = 2;
				playStailText = 'vs player health play';
			case "vs player score":
				characterPlayingAs = 3;
				playStailText = 'vs player score play';
			default:
				characterPlayingAs = 0;
				playStailText = 'boyfriend play';
		}

		// for lua
		instance = this;

		playerList = [];

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			dadkeysArray = EKData.Keybinds.p1fill();
			bfkeysArray = EKData.Keybinds.p2fill();
	
			p1Ratings = new PlayerStates();
			p2Ratings = new PlayerStates();
			
			playerList.push(p1Ratings);
			playerList.push(p2Ratings);

			p1Ratings.resetStats();
			p2Ratings.resetStats();
		}
		else
			keysArray = EKData.Keybinds.fill();

		//Ratings

		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		fliplol = false;

		BfOtherCharacterCamera = 0;
		DadOtherCharacterCamera = 0;
		
		rotCam = false;
		camera.angle = 0;

		//trace('Playback Rate: ' + playbackRate);

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if (SONG.mania == null)
			mania = Note.defaultMania;
		else
			mania = SONG.mania;

		if (mania < 0 || mania > Note.maxMania)
			mania = Note.defaultMania;

		trace("song keys: " + (mania + 1) + " / mania value: " + mania);

		// For the "Just the Two of Us" achievement
		if (characterPlayingAs == 2 || characterPlayingAs == 3)
			for (i in 0...bfkeysArray[mania].length)
			{
				keysPressed.push(false);
			}
		else
			for (i in 0...keysArray[mania].length)
			{
				keysPressed.push(false);
			}

		spaceTimer = new FlxTimer();
		spaceTimer.start(spaceTimerDefault, killBF, 1);
		spaceTimer.active = false;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		var s_termination = "s";
		if (mania == 0) s_termination = "";
		storyDifficultyText = " (" + CoolUtil.difficulties[storyDifficulty] + ", " + (mania + 1) + "key" + s_termination + ")";

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		otherGroup = new FlxTypedSpriteGroup<FlxPerspectiveSprite>(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		trailGroup = new FlxTypedSpriteGroup<FlxPerspectiveTrail>(DAD_X, DAD_Y);

		if (ClientPrefs.UiStates == 'Leather-Engine' && ClientPrefs.sideRatings)
		{
			ratingText = new FlxText(0, 0, 0, "bruh");
			ratingText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			ratingText.screenCenter(Y);

			ratingText.scrollFactor.set();
			add(ratingText);

			ratingText.cameras = [camHUD];

			updateRatingText();
		}

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(trailGroup);
		add(dadGroup);
		add(boyfriendGroup);
		add(otherGroup);

		//add(dadGroup);
		//add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		bgDim = new FlxSprite().makeGraphic(4000, 4000, FlxColor.BLACK);
		bgDim.scrollFactor.set(0);
		bgDim.screenCenter();
		bgDim.alpha = 0;
		add(bgDim);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}

					for (i in lore.FunkinHX.supportedFileTypes)
					{
						if (file.endsWith('.${i}') && !filesPushed.contains(file))
						{
							haxeArray.push(new lore.FunkinHX(folder + file));
							filesPushed.push(file);
						}
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		#if (MODS_ALLOWED && hscript)
		for (i in lore.FunkinHX.supportedFileTypes) {
			doPush = false;
			var hxFile:String = 'stages/' + curStage + '.${i}';
			if(FileSystem.exists(Paths.modFolders(hxFile))) {
				hxFile = Paths.modFolders(hxFile);
				doPush = true;
			} else {
				hxFile = Paths.getPreloadPath(hxFile);
				if(FileSystem.exists(hxFile)) {
					doPush = true;
				}
			}

			if(doPush)
				haxeArray.push(new lore.FunkinHX(hxFile));
		}
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			if(gf.otherCharacters == null)
			{
				if (gf.coolTrail != null)
					gfGroup.add(gf.coolTrail);
				gfGroup.add(gf);
			}
			else
			{
				for(character in gf.otherCharacters)
				{
					if (character.coolTrail != null)
						gfGroup.add(character.coolTrail);
					gfGroup.add(character);
				}
			}
			if(gf.otherCharacters == null)
				gf.dance();
			else
				for (character in gf.otherCharacters)
					character.dance();

			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Dad(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		if(dad.otherCharacters == null)
		{
			if (dad.coolTrail != null)
				dadGroup.add(dad.coolTrail);
			dadGroup.add(dad);
		}
		else
		{
			for(character in dad.otherCharacters)
			{
				if (character.coolTrail != null)
					dadGroup.add(character.coolTrail);
				dadGroup.add(character);
			}
		}

		if (dad.otherCharacters == null)
			dad.dance();
		else
			for (character in dad.otherCharacters)
				character.dance();

		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		if(boyfriend.otherCharacters == null)
		{
			if (boyfriend.coolTrail != null)
				boyfriendGroup.add(boyfriend.coolTrail);
			boyfriendGroup.add(boyfriend);
		}
		else
		{
			for(character in boyfriend.otherCharacters)
			{
				if (character.coolTrail != null)
					boyfriendGroup.add(character.coolTrail);
				boyfriendGroup.add(character);
			}
		}
		if (boyfriend.otherCharacters == null)
				boyfriend.dance();
		else
			for (character in boyfriend.otherCharacters)
					character.dance();

		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
	
		if (boyfriend.maxhealth <= 0)
			boyfriendmaxhealth = boyfriend.maxhealth;
		else
			boyfriendmaxhealth = 2;
		
		if (dad.maxhealth <= 0)
			dadmaxhealth = dad.maxhealth;
		else
			dadmaxhealth = 2;

		maxhealth = ((boyfriendmaxhealth + dadmaxhealth) / 2);

		if (boyfriend.minhealth > boyfriend.maxhealth)
			boyfriendminhealth = boyfriend.minhealth;
		else
			boyfriendminhealth = 0;
		
		if (dad.minhealth > dad.maxhealth)
			dadminhealth = dad.minhealth;
		else
			dadminhealth = 0;

		if (((boyfriendminhealth + dadminhealth) / 2) < maxhealth)
			minhealth = ((boyfriendminhealth + dadminhealth) / 2);
		else
			minhealth = 0;

		health = ((maxhealth + minhealth) / 2);
		bfhealth = health;
		dadhealth = health;

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		switch (ClientPrefs.UiStates.toLowerCase())
		{
			case 'Leather-Engine':
				strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 100).makeGraphic(FlxG.width, 10);
				if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 100;
			default:
				strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
				if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		}
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		
		if (ClientPrefs.UiStates != 'Leather-Engine')
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 2;
			timeTxt.visible = showTime;
			if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
	
			if(ClientPrefs.timeBarType == 'Song Name')
			{
				timeTxt.text = SONG.song;
			}
			updateTime = showTime;
	
			timeBarBG = new AttachedSprite('timeBar');
			timeBarBG.x = timeTxt.x;
			timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			timeBarBG.scrollFactor.set();
			timeBarBG.alpha = 0;
			timeBarBG.visible = showTime;
			timeBarBG.color = FlxColor.BLACK;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			add(timeBarBG);
	
			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			add(timeBar);
			add(timeTxt);
			timeBarBG.sprTracker = timeBar;

			if(ClientPrefs.timeBarType == 'Song Name')
			{
				timeTxt.size = 24;
				timeTxt.y += 3;
			}
		}
		
		strumLineNotes = new FlxTypedGroup<StrumNote>();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			opponentStrums = new FlxTypedGroup<StrumNote>();
			playerStrums = new FlxTypedGroup<StrumNote>();
		}
		else
		{
			playerStrums1 = new FlxTypedGroup<StrumNote>();
			playerStrums2 = new FlxTypedGroup<StrumNote>();
		}

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			var healthBarPosY = FlxG.height * 0.9;

			if (ClientPrefs.downScroll)
				healthBarPosY = 60;

			healthBarBG = new AttachedSprite('healthBar');
			healthBarBG.y = healthBarPosY;
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);

			if (characterPlayingAs != -2 && characterPlayingAs != 3)
			{
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
					'healthShown', minhealth, maxhealth);
				healthBar.scrollFactor.set();
				add(healthBar);
			}
			else
			{
				bfhealthBar = new FlxBar(healthBarBG.x + healthBarBG.width / 2 - 1, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
					'bfhpShown', minhealth, maxhealth);
				bfhealthBar.scrollFactor.set();
				add(bfhealthBar);

				dadhealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
					'dadhpShown', minhealth, maxhealth);
				dadhealthBar.scrollFactor.set();
				add(dadhealthBar);
			}
			
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(timeTxt);
			
			timeBarBG = new AttachedSprite('healthBar');
			timeBarBG.y += healthBarPosY;
			timeBarBG.screenCenter(X);
			timeBarBG.scrollFactor.set();

			if (ClientPrefs.downScroll)
				timeBarBG.y = FlxG.height - (timeBarBG.height + 1);
			else
				timeBarBG.y = 1;

			add(timeBarBG);

			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createGradientBar([(FlxColor.fromRGB(50, 50, 50)), (FlxColor.fromRGB(25, 25, 25)), FlxColor.BLACK], [/* FlxColor.CYAN */(FlxColor.fromRGB(0, 255, 255)), (FlxColor.fromRGB(0, 230, 230)), (FlxColor.fromRGB(0, 205, 205))]);
			// timeBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
			timeBar.numDivisions = 400;
			add(timeBar);
		}
		else if (ClientPrefs.UiStates == 'Forever-Engine')
		{
			var barY = FlxG.height * 0.875;
			if (ClientPrefs.downScroll)
				barY = 64;

			foreverhealthBarBG = new FlxSprite(0,barY).loadGraphic(Paths.image('healthBar'));
			foreverhealthBarBG.screenCenter(X);
			foreverhealthBarBG.scrollFactor.set();
			foreverhealthBarBG.visible = !ClientPrefs.hideHud;
			add(foreverhealthBarBG);
	
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
			{
				healthBar = new FlxBar(foreverhealthBarBG.x + 4, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width - 8), Std.int(foreverhealthBarBG.height - 8), this,
					'healthShown', minhealth, maxhealth);
						
				healthBar.scrollFactor.set();
				// healthBar
				healthBar.visible = !ClientPrefs.hideHud;
				healthBar.alpha = ClientPrefs.healthBarAlpha;
				add(healthBar);
			}
			else
			{
				bfhealthBar = new FlxBar(foreverhealthBarBG.x + foreverhealthBarBG.width / 2 - 1, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width / 2 - 4), Std.int(foreverhealthBarBG.height - 8), this,
					'bfhpShown', minhealth, maxhealth);
						
				bfhealthBar.scrollFactor.set();
				bfhealthBar.visible = !ClientPrefs.hideHud;
				bfhealthBar.alpha = ClientPrefs.healthBarAlpha;
				add(bfhealthBar);

				dadhealthBar = new FlxBar(foreverhealthBarBG.x + 4, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width / 2 - 4), Std.int(foreverhealthBarBG.height - 8), this,
					'dadhpShown', minhealth, maxhealth);
						
				dadhealthBar.scrollFactor.set();
				dadhealthBar.visible = !ClientPrefs.hideHud;
				dadhealthBar.alpha = ClientPrefs.healthBarAlpha;
				add(dadhealthBar);
			}
		}
		else
		{
			healthBarBG = new AttachedSprite('healthBar');
			healthBarBG.y = FlxG.height * 0.89;
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			healthBarBG.visible = !ClientPrefs.hideHud;
			healthBarBG.xAdd = -4;
			healthBarBG.yAdd = -4;
			add(healthBarBG);
			if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
	
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
			{
				healthBar = new FlxBar(healthBarBG.x, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
					'healthShown', minhealth, maxhealth);
						
				healthBar.scrollFactor.set();
				healthBar.visible = !ClientPrefs.hideHud;
				healthBar.alpha = ClientPrefs.healthBarAlpha;
				add(healthBar);
				healthBarBG.sprTracker = healthBar;
			}
			else
			{
				bfhealthBar = new FlxBar(healthBarBG.x + healthBarBG.width / 2 - 1, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
					'bfhpShown', minhealth, maxhealth);
				bfhealthBar.scrollFactor.set();
				bfhealthBar.visible = !ClientPrefs.hideHud;
				bfhealthBar.alpha = ClientPrefs.healthBarAlpha;
				add(bfhealthBar);
				healthBarBG.sprTracker = dadhealthBar;

				bfhealthBar.scrollFactor.set();
				add(bfhealthBar);

				dadhealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
					'dadhpShown', minhealth, maxhealth);
				dadhealthBar.scrollFactor.set();
				dadhealthBar.visible = !ClientPrefs.hideHud;
				dadhealthBar.alpha = ClientPrefs.healthBarAlpha;
				add(dadhealthBar);
			}
		}

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			if (ClientPrefs.UiStates == 'Forever-Engine')
			{
				P1scoreTxt = new FlxText(foreverhealthBarBG.x + foreverhealthBarBG.width - 540, foreverhealthBarBG.y + 30, 0, "", 20);
				P2scoreTxt = new FlxText(foreverhealthBarBG.x + foreverhealthBarBG.width - 540, foreverhealthBarBG.y + 30, 0, "", 20);
			}
			else
			{
				P1scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
				P2scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 540, healthBarBG.y + 30, 0, "", 20);
			}
			P1scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, hudThing, OUTLINE, FlxColor.BLACK);
			P1scoreTxt.scrollFactor.set();
	
			P2scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			P2scoreTxt.scrollFactor.set();
			
			P1scoreTxt.x = FlxG.width - 200;
			P1scoreTxt.y = 250;
			hudThing = RIGHT;

			P2scoreTxt.x = 20;
			P2scoreTxt.y = 250;
		}

		if (ClientPrefs.UiStates == 'Forever-Engine')
		{
			iconP1 = new HealthIcon(boyfriend.healthIcon, true);
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				iconP1.y = healthBar.y - (iconP1.height / 2);
			else
				iconP1.y = bfhealthBar.y - (iconP1.height / 2);
			iconP1.visible = !ClientPrefs.hideHud;
			iconP1.alpha = ClientPrefs.healthBarAlpha;
			add(iconP1);
	
			iconP2 = new HealthIcon(dad.healthIcon, false);
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				iconP2.y = healthBar.y - (iconP2.height / 2);
			else
				iconP2.y = dadhealthBar.y - (iconP1.height / 2);
			iconP2.visible = !ClientPrefs.hideHud;
			iconP2.alpha = ClientPrefs.healthBarAlpha;
			add(iconP2);
		}
		else
		{
			iconP1 = new HealthIcon(boyfriend.healthIcon, true);
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				iconP1.y = healthBar.y - 75;
			else
				iconP1.y = bfhealthBar.y - (iconP1.height / 2);
			iconP1.visible = !ClientPrefs.hideHud;
			iconP1.alpha = ClientPrefs.healthBarAlpha;
			add(iconP1);
	
			iconP2 = new HealthIcon(dad.healthIcon, false);
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				iconP2.y = healthBar.y - 75;
			else
				iconP2.y = dadhealthBar.y - (iconP1.height / 2);
			iconP2.visible = !ClientPrefs.hideHud;
			iconP2.alpha = ClientPrefs.healthBarAlpha;
			add(iconP2);
		}
		reloadHealthBarColors();

		if (characterPlayingAs == 0 || characterPlayingAs == 2)
			HealthRight = false;
		else
			HealthRight = true;

		var scoreTxtSize:Int = 16;
	
		var funnyBarOffset:Int = 45;

		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, '', 16);
		
		if (ClientPrefs.biggerScoreInfo)
			scoreTxtSize = 20;

		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			scoreTxt = new FlxText(0, healthBarBG.y + funnyBarOffset, FlxG.width, "", 20);
			
			scoreTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.screenCenter(X);

			if (ClientPrefs.biggerScoreInfo)
				scoreTxt.borderSize = 1.25;

			var infoTxtSize:Int = ClientPrefs.biggerScoreInfo ? 20 : 16;

			infoTxt = new FlxText(0, 0, 0, SONG.song + " - " + (CoolUtil.difficultyString()) + (cpuControlled ? " (BOT)" : "") + (practiceMode ? " (PRACTICE)" : "") + (instakillOnMiss ? " (INSTAKILL)" : ""), 20);

			infoTxt.setFormat(Paths.font("vcr.ttf"), infoTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			infoTxt.screenCenter(X);

			infoTxt.scrollFactor.set();
			
			if (ClientPrefs.downScroll)
				infoTxt.y = timeBarBG.y - timeBarBG.height - 1;
			else
				infoTxt.y = timeBarBG.y + timeBarBG.height + 1;

			add(infoTxt);
		}
		else if (ClientPrefs.UiStates == 'Forever-Engine')
		{
			var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';
	
			scoreBar = new FlxText(FlxG.width / 2, foreverhealthBarBG.y + 40, 0, scoreDisplay, 20);
			if (ClientPrefs.Gengo == 'Jp')
				scoreBar.setFormat(Paths.font("jpvcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			else
				scoreBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreBar.scrollFactor.set();
			add(scoreBar);
			
			var infoDisplay:String = SONG.song + ' - ' + CoolUtil.difficultyString();
			var engineDisplay:String = "Mikan Engine v" + MainMenuState.mikanEngineVersion;
			engineBar = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
			engineBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			engineBar.updateHitbox();
			engineBar.x = FlxG.width - engineBar.width - 5;
			engineBar.scrollFactor.set();
			add(engineBar);

			infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
			infoBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			infoBar.scrollFactor.set();
			add(infoBar);
			
			if (ClientPrefs.Counter != 'None') {
				var judgementNameArray:Array<String> = [];
				for (i in Timings.judgementsMap.keys())
					judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
				judgementNameArray.sort(sortByRating);
				for (i in 0...judgementNameArray.length) {
					ratingText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);

					if (!left)
						ratingText.x -= ratingText.text.length * counterTextSize;
					ratingText.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
					ratingText.scrollFactor.set();
					add(ratingText);
		
					ratingText.cameras = [camHUD];
				}
			}
			ForeverUpdateScoreText();
		}
		else
		{
			scoreTxtSize = 20;
			if (ClientPrefs.scoretxtup)
				scoreTxt = new FlxText(0, timeBarBG.y - 28, FlxG.width, "", 20);
			else
				scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);

			scoreTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.25;
		}
		if (ClientPrefs.UiStates != 'Forever-Engine')
		{
			//scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(ClientPrefs.Gengo == 'Eng')
				scoreTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			if(ClientPrefs.Gengo == 'Jp')
				scoreTxt.setFormat(Paths.font("jpvcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	
			scoreTxt.scrollFactor.set();
			scoreTxt.visible = !ClientPrefs.hideHud;
			add(scoreTxt);
		}
		
		if (ClientPrefs.UiStates == 'Leather-Engine')
			healthTxt = new FlxText(0, timeBarBG.y + timeBarBG.height + 12, FlxG.width, "", 20);
			/*
			if (ClientPrefs.scoretxtup)
				healthTxt = new FlxText(0, healthBarBG.y + funnyBarOffset, FlxG.width, "", 20);
			else
				healthTxt = new FlxText(0, timeBarBG.y + timeBarBG.height + 12, FlxG.width, "", 20);
			*/
		else
			if (ClientPrefs.UiStates == 'Forever-Engine')
				healthTxt = new FlxText(0, 0, FlxG.width, "", 20);
			else
				if (ClientPrefs.scoretxtup)
					healthTxt = new FlxText(0, healthBarBG.y + funnyBarOffset, FlxG.width, "", 20);
				else
					healthTxt = new FlxText(0, timeBarBG.y + 15, FlxG.width, "", 20);
	
		healthTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if(ClientPrefs.Gengo == 'Jp')
			healthTxt.setFormat(Paths.font("jpvcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		healthTxt.scrollFactor.set();
		healthTxt.borderSize = 1.25;
		healthTxt.visible = !ClientPrefs.hideHud;
		add(healthTxt);

		add(strumLineNotes);
		add(grpNoteSplashes);
		add(notes);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}
		
		spacebarMash = new BGSprite("changed/SpaceBarAssets", FlxG.width/2-55, FlxG.height/2 - 300, 0, 0, ['spaceNotHit']);
		spacebarMash.animation.addByPrefix('hit', 'spaceHit', 30, false);
		spacebarMash.animation.addByPrefix('idle', 'spaceNotHit', 30, false);
		spacebarMash.visible = false;
		spacebarMash.scale.set(0.6, 0.6); //0.85 looked good
		spacebarMash.alpha = 0.85;

		if(ClientPrefs.downScroll){
			spacebarMash.y = FlxG.height/2 -300;
		}
		
		spacebarMash.dance();
		add(spacebarMash);

		spaceTimerText = new FlxText(FlxG.width/2, FlxG.height/2, 0, '$spaceTimer', 24, true);
		spaceTimerText.setFormat(Paths.font("impact.ttf"), 120, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		spaceTimerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5, 1);
		spaceTimerText.visible = false;
		spaceTimerText.x = FlxG.width/2 + 280;
		spaceTimerText.y = FlxG.height/2 -330;

		if(ClientPrefs.downScroll){
			spaceTimerText.y = FlxG.height/2 + 190;
		}
		spacebarMash.dance();
		add(spacebarMash);

		add(spaceTimerText);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		if (characterPlayingAs != -2 && characterPlayingAs != 3)
			healthBar.cameras = [camHUD];
		else
		{
			dadhealthBar.cameras = [camHUD];
			bfhealthBar.cameras = [camHUD];
		}
		if (ClientPrefs.UiStates != 'Forever-Engine')
			healthBarBG.cameras = [camHUD];
		
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		if (ClientPrefs.UiStates != 'Forever-Engine')
			scoreTxt.cameras = [camHUD];

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			add(P1scoreTxt);
			add(P2scoreTxt);
			P1scoreTxt.cameras = [camHUD];
			P2scoreTxt.cameras = [camHUD];
		}
		healthTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			infoTxt.cameras = [camHUD];
		}
		else
			if (ClientPrefs.UiStates == 'Forever-Engine')
			{
				foreverhealthBarBG.cameras = [camHUD];
				scoreBar.cameras = [camHUD];
				engineBar.cameras = [camHUD];
				infoBar.cameras = [camHUD];
				ForeverUpdateScoreText();
			}
			// else
		doof.cameras = [camHUD];
		spacebarMash.cameras = [camHUD];
		spaceTimerText.cameras = [camHUD];

		if(SONG.HardEvent)
			bossStuff();

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		#if hscript
		for (notetype in noteTypeMap.keys())
		{
			for (i in lore.FunkinHX.supportedFileTypes) {
				#if MODS_ALLOWED
				var hscriptToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.${i}');
				if(FileSystem.exists(hscriptToLoad))
				{
					haxeArray.push(new lore.FunkinHX(hscriptToLoad));
				}
				else
				{
					hscriptToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.${i}');
					if(FileSystem.exists(hscriptToLoad))
					{
						haxeArray.push(new lore.FunkinHX(hscriptToLoad));
					}
				}
				#elseif sys
				var hscriptToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.${i}');
				if(OpenFlAssets.exists(hscriptToLoad))
				{
					haxeArray.push(new lore.FunkinHX(hscriptToLoad));
				}
				#end
			}
		}
		for (event in eventPushedMap.keys())
		{
			for (i in lore.FunkinHX.supportedFileTypes) {
				#if MODS_ALLOWED
				var hscriptToLoad:String = Paths.modFolders('custom_events/' + event + '.${i}');
				if(FileSystem.exists(hscriptToLoad))
				{
					haxeArray.push(new lore.FunkinHX(hscriptToLoad));
				}
				else
				{
					hscriptToLoad = Paths.getPreloadPath('custom_events/' + event + '.${i}');
					if(FileSystem.exists(hscriptToLoad))
					{
						haxeArray.push(new lore.FunkinHX(hscriptToLoad));
					}
				}
				#elseif sys
				var hscriptToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.${i}');
				if(OpenFlAssets.exists(hscriptToLoad))
				{
					haxeArray.push(new lore.FunkinHX(hscriptToLoad));
				}
				#end
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}

					for (i in lore.FunkinHX.supportedFileTypes)
					{
						if(file.endsWith('.${i}') && !filesPushed.contains(file))
						{
							haxeArray.push(new lore.FunkinHX(folder + file));
							filesPushed.push(file);
						}
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();
		if (ClientPrefs.UiStates == 'Forever-Engine')
			ForeverUpdateScoreText();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence('Play Stail is ' + playStailText + ' ' + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		#end


		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, ondadKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, ondadKeyRelease);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onbfKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onbfKeyRelease);
		}
		else
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;
		
		#if hscript
		for (i in haxeArray) {
			i.set("boyfriend", boyfriend);
			i.set("dad", dad);
			i.set("gf", gf);
			i.set("iconP1", iconP1);
			i.set("iconP2", iconP2);
			if (ClientPrefs.UiStates == 'Forever-Engine')
				i.set("healthBarBG", foreverhealthBarBG);
			else
				i.set("healthBarBG", healthBarBG);
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				i.set("healthBar", healthBar);
			else
			{
				i.set("bfhealthBar", bfhealthBar);
				i.set("dadhealthBar", dadhealthBar);
			}
			i.set("scoreTxt", scoreTxt);
			i.set("timeTxt", timeTxt);
			i.set("timeBarBG", timeBarBG);
			i.set("timeBar", timeBar);
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
			{
				i.set("playerStrums", playerStrums);
				i.set("opponentStrums", opponentStrums);
			}
			else
			{
				i.set("playerStrums", playerStrums2);
				i.set("opponentStrums", playerStrums1);
			}
			i.set("strumLineNotes", strumLineNotes);
			i.set("strumLine", strumLine);
			i.set("notes", notes);
		}
		#end
		setOnHaxes('characterPlayingAs', characterPlayingAs);
		callOnLuas('onCreatePost', []);
		callOnHaxes('createPost', []);

		super.create();

		cacheCountdown();
		cachePopUpScore();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			updateSongInfoText();
			calculateAccuracy();
		}
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			if(dadvocals != null) dadvocals.pitch = value;
			if(boyfriendvocals != null) boyfriendvocals.pitch = value;
			
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		if (!fliplol)
		{
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
					FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			else
			{
				dadhealthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
					FlxColor.fromRGB(255, 0, 0));
					
				bfhealthBar.createFilledBar(FlxColor.fromRGB(255, 0, 0),
					FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			}
		}
		else
		{
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				healthBar.createFilledBar(FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]),
					FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
			else
			{
				dadhealthBar.createFilledBar(FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]),
					FlxColor.fromRGB(255, 0, 0));
					
				bfhealthBar.createFilledBar(FlxColor.fromRGB(255, 0, 0),
					FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
			}
		}

		if (characterPlayingAs != -2 && characterPlayingAs != 3)
			healthBar.updateBar();
		else
		{
			dadhealthBar.updateBar();
			bfhealthBar.updateBar();
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);

					if (newBoyfriend.otherCharacters == null)
					{
						boyfriendGroup.add(newBoyfriend);
					}
					else
					{
						for(character in newBoyfriend.otherCharacters)
						{
							boyfriendGroup.add(character);
						}
					}

					// boyfriendGroup.add(newBoyfriend);

					startCharacterPos(newBoyfriend);

					if (newBoyfriend.otherCharacters == null)
						newBoyfriend.alpha = 0.00001;
					else
					{
						for(character in newBoyfriend.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}

					// newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
					
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Dad = new Dad(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);

					if (newDad.otherCharacters == null)
					{
						dadGroup.add(newDad);
					}
					else
					{
						for(character in newDad.otherCharacters)
						{
							dadGroup.add(character);
						}
					}

					//dadGroup.add(newDad);
					startCharacterPos(newDad, true);

					if (newDad.otherCharacters == null)
						newDad.alpha = 0.00001;
					else
					{
						for(character in newDad.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}

					// newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter, true);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);

					if (newGf.otherCharacters == null)
					{
						gfGroup.add(newGf);
					}
					else
					{
						for(character in newGf.otherCharacters)
						{
							gfGroup.add(character);
						}
					}

					// gfGroup.add(newGf);
					startCharacterPos(newGf);

					if (newGf.otherCharacters == null)
						newGf.alpha = 0.00001;
					else
					{
						for(character in newGf.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}

					// newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
		
		#if hscript
		for (i in lore.FunkinHX.supportedFileTypes) {
			var doPush:Bool = false;
			var hscriptFile:String = 'characters/' + name + '.${i}';
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(hscriptFile))) {
				hscriptFile = Paths.modFolders(hscriptFile);
				doPush = true;
			} else {
				hscriptFile = Paths.getPreloadPath(hscriptFile);
				if(FileSystem.exists(hscriptFile)) {
					doPush = true;
				}
			}
			#else
			hscriptFile = Paths.getPreloadPath(hscriptFile);
			if(Assets.exists(hscriptFile)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				for (script in haxeArray)
				{
					if(script.scriptName == hscriptFile) return;
				}
				haxeArray.push(new lore.FunkinHX(hscriptFile));
			}
		}
		#end
	}

	
	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(modchartBarSprites.exists(tag)) return modchartBarSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf'))
		{ //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			if (gf.otherCharacters == null)
			{
				char.setPosition(GF_X, GF_Y);
				char.scrollFactor.set(0.95, 0.95);
				char.danceEveryNumBeats = 2;				
			}
			else
			for (charother in char.otherCharacters)
			{
				charother.setPosition(GF_X, GF_Y);
				charother.scrollFactor.set(0.95, 0.95);
				charother.danceEveryNumBeats = 2;
			}
		}
		if (char.otherCharacters == null)
		{
			char.x += char.positionArray[0];
			char.y += char.positionArray[1];
		}
		else
		{
			for (charother in char.otherCharacters)
			{
				charother.x += charother.positionArray[0];
				charother.y += charother.positionArray[1];
			}
		}
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			ResultorendSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					ResultorendSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				ResultorendSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public var camMovement:Float = 40;
	public var velocity:Float = 1;
	public var campointx:Float = 0;
	public var campointy:Float = 0;
	public var camlockx:Float = 0;
	public var camlocky:Float = 0;
	public var camlock:Bool = false;
	public var bfturn:Bool = false;


	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}
	
	public function updateLuaDefaultPos() {
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}
		}
		else
		{
			for (i in 0...playerStrums2.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums2.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums2.members[i].y);
			}
			for (i in 0...playerStrums1.length) {
				setOnLuas('defaultOpponentStrumX' + i, playerStrums1.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, playerStrums1.members[i].y);
			}
		}
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			callOnHaxes('startCountdown',[]);
			return;
		}

		inCutscene = false;
		var ret:Array<Dynamic> = [callOnLuas('onStartCountdown', [], false), callOnHaxes('startCountdown', [], false)];
		if(!ret.contains(FunkinLua.Function_Stop)) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			if (characterPlayingAs == 0 || characterPlayingAs == 2 || characterPlayingAs == 3)
			{
				generateStaticArrows(0, false);
				generateStaticArrows(1, true);
			}
			else
			{
				if (characterPlayingAs == -1 || characterPlayingAs == -2)
				{
					generateStaticArrows(0, false);
					generateStaticArrows(1, true);
				}
				else
				{
					generateStaticArrows(0, true);
					generateStaticArrows(1, false);			
				}
			}
			updateLuaDefaultPos();

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);
			callOnHaxes('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (boyfriend.otherCharacters == null)
				{
					if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
						boyfriend.dance();
				}
				else
				{
					for (character in boyfriend.otherCharacters)
						if (tmr.loopsLeft % character.danceEveryNumBeats == 0 && character.animation.curAnim != null && !character.animation.curAnim.name.startsWith('sing') && !character.stunned)
							character.dance();
				}
				if (dad.otherCharacters == null)
				{
					if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
						dad.dance();
				}
				else
				{
					for (character in dad.otherCharacters)
						if (tmr.loopsLeft % character.danceEveryNumBeats == 0 && character.animation.curAnim != null && !character.animation.curAnim.name.startsWith('sing'))
							character.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.cameras = [camHUD];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.cameras = [camHUD];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if (characterPlayingAs != 2 && characterPlayingAs != 3)
						if(ClientPrefs.opponentStrums || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.middleScroll && !note.mustPress) {
								note.alpha *= 0.35;
							}
						}
				});
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHaxes('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		if (ClientPrefs.UiStates != 'Leather-Engine' && ClientPrefs.UiStates != 'Forever-Engine')
		{
			/*
			scoreTxt.text = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Rating: ' + ratingName
			+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
			*/
			
			scoreTxt.text = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Accuracy: ' + ratingName
			+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - [ $ratingFC ]' : '');
	
			if (ClientPrefs.Gengo == 'Jp')
			{
				scoreTxt.text = 'スコア: ' + songScore
				+ ' | ミス数: ' + songMisses
				+ ' | 精度: ' + ratingName
				+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - [ $ratingFC ]' : '');
				
			}
	
			if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}
		callOnLuas('onUpdateScore', [miss]);
		callOnHaxes('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		dadvocals.pause();
		boyfriendvocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();

		if (Conductor.songPosition <= dadvocals.length)
		{
			dadvocals.time = time;
			dadvocals.pitch = playbackRate;
		}
		dadvocals.play();

		if (Conductor.songPosition <= boyfriendvocals.length)
		{
			boyfriendvocals.time = time;
			boyfriendvocals.pitch = playbackRate;
		}
		boyfriendvocals.play();	

		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
		callOnHaxes('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
		callOnHaxes('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		dadvocals.play();
		boyfriendvocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			dadvocals.pause();
			boyfriendvocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		if (ClientPrefs.UiStates != 'Forever-Engine')
		{
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}
		else
		{
			FlxTween.tween(timeBar, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeBarBG, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
		}

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence('Play Stail is ' + playStailText + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
		callOnHaxes('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private var parsingKeyCount:Int = 4;
	private var maniaChanges:Array<Dynamic> = [];

	private function generateSong(dataPath:String):Void
	{
		parsingKeyCount = Note.ammo[mania];
		var ogMania = mania;

		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed / ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			// vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song,
				(SONG.specialAudioName == null ? CoolUtil.difficultyString() : SONG.specialAudioName)));
		else
			vocals = new FlxSound();

		if (SONG.needsDadVoices)
			dadvocals = new FlxSound().loadEmbedded(Paths.dadvoices(PlayState.SONG.song, PlayState.SONG.player2));
		else
			dadvocals = new FlxSound();
		
		if (SONG.needsBfVoices)
			boyfriendvocals = new FlxSound().loadEmbedded(Paths.bfvoices(PlayState.SONG.song, PlayState.SONG.player1));
		else
			boyfriendvocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		
		dadvocals.pitch = playbackRate;
		FlxG.sound.list.add(dadvocals);
		
		boyfriendvocals.pitch = playbackRate;
		FlxG.sound.list.add(boyfriendvocals);

		// FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(SONG.song,
			(SONG.specialAudioName == null ? CoolUtil.difficultyString() : SONG.specialAudioName))));

		notes = new FlxTypedGroup<Note>();
		//add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				
				for (mchange in maniaChanges)
				{
					if (daStrumTime >= mchange[0])
					{
						parsingKeyCount = Note.ammo[mchange[1]];
						mania = mchange[1];

						SONG.mania = mania; //so notes are correct anim/scale and whatever
					}
				}

				var daNoteData:Int = Std.int(songNotes[1] % parsingKeyCount);

				var gottaHitNote:Bool = section.mustHitSection;

				var opponentNoteSingNote:Bool = !section.mustHitSection;

				if (songNotes[1] > (parsingKeyCount - 1))
				{
					opponentNoteSingNote = section.mustHitSection;
					gottaHitNote = !section.mustHitSection;
				}
				
				if(characterPlayingAs == 1 || characterPlayingAs == -2)
					gottaHitNote = !gottaHitNote;

				if (characterPlayingAs == -1 || characterPlayingAs == -2)
					gottaHitNote = true;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				if(!Std.isOfType(songNotes[3], String) && (Std.isOfType(songNotes[3], Int) || Std.isOfType(songNotes[3], Array)))
				{
					songNotes[4] = songNotes[3];
					songNotes[3] = "";
				}

				if(!Std.isOfType(songNotes[4], Int) && !Std.isOfType(songNotes[4], Array))
				{
					songNotes[4] = 0;
				}

				var char:Dynamic = songNotes[4];

				var chars:Array<Int> = [];

				if(Std.isOfType(char, Array))
				{
					chars = char;
					char = chars[0];
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, char, chars);
				swagNote.opponentSing = opponentNoteSingNote;
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<parsingKeyCount));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();
				
				if ((!swagNote.ignoreNote || !swagNote.hitCausesMiss) && !swagNote.isSustainNote)
				{
					if (characterPlayingAs == 0 && !swagNote.opponentSing)
						Notelength++;
	
					if (characterPlayingAs == 1 && swagNote.opponentSing)
						Notelength++;
					
					if (characterPlayingAs == -1 || characterPlayingAs == -2)
						Notelength++;
				}

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true, char, chars);
						
						sustainNote.opponentSing = opponentNoteSingNote;
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<parsingKeyCount));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;

		mania = ogMania; //so stuff works properly and doesnt keep when resetting song
		SONG.mania = ogMania;
	}

	public function burstRelease(bX:Float, bY:Float)
	{
		FlxG.sound.play(Paths.sound('burst'));
		remove(burst);
		burst = new FlxPerspectiveSprite(bX - 1000, bY - 100);
		burst.frames = Paths.getSparrowAtlas('characters/shaggy');
		burst.animation.addByPrefix('burst', "burst", 30);
		burst.animation.play('burst');
		//burst.setGraphicSize(Std.int(burst.width * 1.5));
		burst.antialiasing = true;
		add(burst);
		new FlxTimer().start(0.5, function(rem:FlxTimer)
		{
			remove(burst);
		});
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Change Mania': 
				maniaChanges.push([event.strumTime, Std.parseInt(event.value1)]);
				
			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);

		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Array<Dynamic> = [callOnLuas('eventEarlyTrigger', [event.event]), callOnHaxes('eventEarlyTrigger', [event.event])];
		if(!returnedValue.contains(0)) {
			for (i in returnedValue) if (i != 0) return i;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	var counterTextSize:Int = 18;

	function sortByRating(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	
	private function generateStaticArrows(player:Int, Play:Bool = false):Void
	{
		for (i in 0...Note.ammo[mania])
		{
			var twnDuration:Float = 4 / mania;
			var twnStart:Float = 0.5 + ((0.8 / mania) * i);
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if (characterPlayingAs != 2 && characterPlayingAs != 3)
					if(!ClientPrefs.opponentStrums) targetAlpha = 0;
					else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote((characterPlayingAs == -1 || characterPlayingAs == -2) ? STRUM_X_MIDDLESCROLL : (ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X), strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween && mania > 1)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (characterPlayingAs != 2 && characterPlayingAs != 3)
			{
				if (Play)
				{
					playerStrums.add(babyArrow);
	
					if(ClientPrefs.middleScroll && characterPlayingAs == 1)
					{
						var separator:Int = Note.separator[mania];
	
						babyArrow.x += 310;
						if(i > separator) { //Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
				}
				else
				{
					if(ClientPrefs.middleScroll && characterPlayingAs == 0)
					{
						var separator:Int = Note.separator[mania];
	
						babyArrow.x += 310;
						if(i > separator) { //Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
					if (characterPlayingAs == -1 || characterPlayingAs == -2)
					{
						babyArrow.x = FlxG.width * 20;
					}
	
					opponentStrums.add(babyArrow);
				}
			}
			else
			{
				if (Play)
					playerStrums2.add(babyArrow);
				else
					playerStrums1.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();

			if (characterPlayingAs != 2 && characterPlayingAs != 3)
			{
				if (ClientPrefs.showKeybindsOnStart && Play) {
					for (j in 0...keysArray[mania][i].length) {
						var daKeyTxt:FlxText = new FlxText(babyArrow.x, babyArrow.y - 10, 0, InputFormatter.getKeyName(keysArray[mania][i][j]), 32);
						daKeyTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						daKeyTxt.borderSize = 1.25;
						daKeyTxt.alpha = 0;
						daKeyTxt.size = 32 - mania; //essentially if i ever add 0k!?!?
						daKeyTxt.x = babyArrow.x+(babyArrow.width / 2);
						daKeyTxt.x -= daKeyTxt.width / 2;
						add(daKeyTxt);
						daKeyTxt.cameras = [camHUD];
						var textY:Float = (j == 0 ? babyArrow.y - 32 : ((babyArrow.y - 32) + babyArrow.height) - daKeyTxt.height);
						daKeyTxt.y = textY;
	
						if (mania > 1 && !skipArrowStartTween) {
							FlxTween.tween(daKeyTxt, {y: textY + 32, alpha: 1}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
						} else {
							daKeyTxt.y += 16;
							daKeyTxt.alpha = 1;
						}
						new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) {
							FlxTween.tween(daKeyTxt, {y: daKeyTxt.y + 32, alpha: 0}, twnDuration, {ease: FlxEase.circIn, startDelay: twnStart, onComplete:
							function(t) {
								remove(daKeyTxt);
							}});
						});
					}
				}
			}
			else
			{
				if (ClientPrefs.showKeybindsOnStart && Play) {
					for (j in 0...bfkeysArray[mania][i].length) {
						var daKeyTxt:FlxText = new FlxText(babyArrow.x, babyArrow.y - 10, 0, InputFormatter.getKeyName(bfkeysArray[mania][i][j]), 32);
						daKeyTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						daKeyTxt.borderSize = 1.25;
						daKeyTxt.alpha = 0;
						daKeyTxt.size = 32 - mania; //essentially if i ever add 0k!?!?
						daKeyTxt.x = babyArrow.x+(babyArrow.width / 2);
						daKeyTxt.x -= daKeyTxt.width / 2;
						add(daKeyTxt);
						daKeyTxt.cameras = [camHUD];
						var textY:Float = (j == 0 ? babyArrow.y - 32 : ((babyArrow.y - 32) + babyArrow.height) - daKeyTxt.height);
						daKeyTxt.y = textY;
	
						if (mania > 1 && !skipArrowStartTween) {
							FlxTween.tween(daKeyTxt, {y: textY + 32, alpha: 1}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
						} else {
							daKeyTxt.y += 16;
							daKeyTxt.alpha = 1;
						}
						new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) {
							FlxTween.tween(daKeyTxt, {y: daKeyTxt.y + 32, alpha: 0}, twnDuration, {ease: FlxEase.circIn, startDelay: twnStart, onComplete:
							function(t) {
								remove(daKeyTxt);
							}});
						});
					}
				}
				if (ClientPrefs.showKeybindsOnStart && !Play) {
					for (j in 0...dadkeysArray[mania][i].length) {
						var daKeyTxt:FlxText = new FlxText(babyArrow.x, babyArrow.y - 10, 0, InputFormatter.getKeyName(dadkeysArray[mania][i][j]), 32);
						daKeyTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						daKeyTxt.borderSize = 1.25;
						daKeyTxt.alpha = 0;
						daKeyTxt.size = 32 - mania; //essentially if i ever add 0k!?!?
						daKeyTxt.x = babyArrow.x+(babyArrow.width / 2);
						daKeyTxt.x -= daKeyTxt.width / 2;
						add(daKeyTxt);
						daKeyTxt.cameras = [camHUD];
						var textY:Float = (j == 0 ? babyArrow.y - 32 : ((babyArrow.y - 32) + babyArrow.height) - daKeyTxt.height);
						daKeyTxt.y = textY;
	
						if (mania > 1 && !skipArrowStartTween) {
							FlxTween.tween(daKeyTxt, {y: textY + 32, alpha: 1}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
						} else {
							daKeyTxt.y += 16;
							daKeyTxt.alpha = 1;
						}
						new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) {
							FlxTween.tween(daKeyTxt, {y: daKeyTxt.y + 32, alpha: 0}, twnDuration, {ease: FlxEase.circIn, startDelay: twnStart, onComplete:
							function(t) {
								remove(daKeyTxt);
							}});
						});
					}
				}
			}
		}
	}

	function updateNote(note:Note)
	{
		var tMania:Int = mania + 1;
		var noteData:Int = note.noteData;

		note.scale.set(1, 1);
		note.updateHitbox();

		/*
		if (!isPixelStage) {
			note.setGraphicSize(Std.int(note.width * Note.noteScales[mania]));
			note.updateHitbox();
		} else {
			note.setGraphicSize(Std.int(note.width * daPixelZoom * (Note.noteScales[mania] + 0.3)));
			note.updateHitbox();
		}
		*/

		// Like reloadNote()

		var lastScaleY:Float = note.scale.y;
		if (isPixelStage) {
			if (note.isSustainNote) {note.originalHeightForCalcs = note.height;}

			note.setGraphicSize(Std.int(note.width * daPixelZoom * Note.pixelScales[mania]));
		} else {
			// Like loadNoteAnims()

			note.setGraphicSize(Std.int(note.width * Note.scales[mania]));
			note.updateHitbox();
		}

		//if (note.isSustainNote) {note.scale.y = lastScaleY;}
		note.updateHitbox();

		// Like new()

		var prevNote:Note = note.prevNote;
		
		if (note.isSustainNote && prevNote != null) {
			
			note.offsetX += note.width / 2;

			note.animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			note.updateHitbox();

			note.offsetX -= note.width / 2;

			if (note != null && prevNote != null && prevNote.isSustainNote && prevNote.animation != null) { // haxe flixel
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData % tMania] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				prevNote.scale.y *= songSpeed;

				if(isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / note.height);
				}

				prevNote.updateHitbox();
				//trace(prevNote.scale.y);
			}
			
			if (isPixelStage){
				prevNote.scale.y *= daPixelZoom * (Note.pixelScales[mania]); //Fuck urself
				prevNote.updateHitbox();
			}
		} else if (!note.isSustainNote && noteData > - 1 && noteData < tMania) {
			if (note.changeAnim) {
				var animToPlay:String = '';

				animToPlay = Note.keysShit.get(mania).get('letters')[noteData % tMania];
				
				note.animation.play(animToPlay);
			}
		}

		// Like set_noteType()

		if (note.changeColSwap) {
			var hsvNumThing = Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData % tMania]);
			var colSwap = note.colorSwap;
	
			colSwap.hue = ClientPrefs.arrowHSV[hsvNumThing][0] / 360;
			colSwap.saturation = ClientPrefs.arrowHSV[hsvNumThing][1] / 100;
			colSwap.brightness = ClientPrefs.arrowHSV[hsvNumThing][2] / 100;
		}
	}

	public function changeMania(newValue:Int, skipStrumFadeOut:Bool = false)
	{
		//funny dissapear transitions
		//while new strums appear
		/*
		var daOldMania = mania;
				
		mania = newValue;
		if (!skipStrumFadeOut) {
			for (i in 0...strumLineNotes.members.length) {
				var oldStrum:FlxSprite = strumLineNotes.members[i].clone();
				oldStrum.x = strumLineNotes.members[i].x;
				oldStrum.y = strumLineNotes.members[i].y;
				oldStrum.alpha = strumLineNotes.members[i].alpha;
				oldStrum.scrollFactor.set();
				oldStrum.cameras = [camHUD];
				oldStrum.setGraphicSize(Std.int(oldStrum.width * Note.scales[daOldMania]));
				oldStrum.updateHitbox();
				add(oldStrum);
	
				FlxTween.tween(oldStrum, {alpha: 0}, 0.3, {onComplete: function(_) {
					remove(oldStrum);
				}});
			}
		}

		playerStrums.clear();
		opponentStrums.clear();
		strumLineNotes.clear();
		setOnLuas('mania', mania);

		notes.forEachAlive(function(note:Note) {updateNote(note);});

		for (noteI in 0...unspawnNotes.length) {
			var note:Note = unspawnNotes[noteI];

			updateNote(note);
		}

		callOnLuas('onChangeMania', [mania, daOldMania]);

		if (characterPlayingAs == 0)
		{
			generateStaticArrows(0, false);
			generateStaticArrows(1, true);
		}
		else
		{
			if (characterPlayingAs == -1)
			{
				generateStaticArrows(0, false);
				generateStaticArrows(1, true);
			}
			else
			{
				generateStaticArrows(0, true);
				generateStaticArrows(1, false);		
			}
		}
		updateLuaDefaultPos();
		*/
		var ogmania = SONG.mania;
		mania = newValue;

		SONG.mania = mania;

		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			playerStrums.clear();
			opponentStrums.clear();
		}
		else
		{
			playerStrums2.clear();
			playerStrums1.clear();
		}
		strumLineNotes.clear();
		//renderedStrumLineNotes.clear();
		setOnLuas('mania', mania);
		setOnHaxes('mania', mania);
		
		callOnLuas('onChangeMania', [mania, ogmania]);
		callOnHaxes('onChangeMania', [mania, ogmania]);

		if (characterPlayingAs == 0 || characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			generateStaticArrows(0, false);
			generateStaticArrows(1, true);
		}
		else
		{
			if (characterPlayingAs == -1 || characterPlayingAs == -2)
			{
				generateStaticArrows(0, false);
				generateStaticArrows(1, true);
			}
			else
			{
				generateStaticArrows(0, true);
				generateStaticArrows(1, false);		
			}
		}

		updateLuaDefaultPos();
		//setupBinds();

		//mania = ogmania;
		SONG.mania = ogmania;
		//Note.mania = ogmania;
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				dadvocals.pause();
				boyfriendvocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);
			callOnHaxes('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence('Play Stail is ' + playStailText + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence('Play Stail is ' + playStailText + ' ' + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if ((characterPlayingAs == -2 ? (dadhealth + bfhealth) : health) > minhealth && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence('Play Stail is ' + playStailText + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence('Play Stail is ' + playStailText + ' ' + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if ((characterPlayingAs == -2 ? (dadhealth + bfhealth) : health) > minhealth && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		dadvocals.pause();
		boyfriendvocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();

		if (Conductor.songPosition <= dadvocals.length)
		{
			dadvocals.time = Conductor.songPosition;
			dadvocals.pitch = playbackRate;
		}
		dadvocals.play();
		
		if (Conductor.songPosition <= boyfriendvocals.length)
		{
			boyfriendvocals.time = Conductor.songPosition;
			boyfriendvocals.pitch = playbackRate;
		}
		boyfriendvocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var song_info_timer:Float = 0.0;

	override public function update(elapsed:Float)
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos && ClientPrefs.cameraMove)
			{
				if (!SONG.notes[curSection].mustHitSection)
				{
					moveCamera(true);
				}
				else
				{
					moveCamera(false);
				}			
			}			
		}

		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		setOnHaxes('health', health);
		callOnLuas('onUpdate', [elapsed]);
		callOnHaxes('update', [elapsed]);

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			updateHUD(1);
			updateHUD(2);
		}
		
		if (rotCam)
		{
			rotCamInd ++;
			camera.angle = Math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange;
		}
		else
		{
			rotCamInd = 0;
		}

		if (dimGo)
		{
			if (bgDim.alpha < 0.5) bgDim.alpha += 0.01;
		}
		else
		{
			if (bgDim.alpha > 0) bgDim.alpha -= 0.01;
		}
		if (fullDim)
		{
			bgDim.alpha = 1;
			noticeTime ++;
		}

		/*
		if (god)
		{
			chrom.strength = FlxMath.lerp(chrom.strength, 0, elapsed*10);
			chrom.update(elapsed);
		}
		*/
		if(ClientPrefs.camMovement && !PlayState.isPixelStage) {
			if(camlock) {
				camFollow.x = camlockx;
				camFollow.y = camlocky;
			}
		}

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if (boyfriend.otherCharacters == null)
			{
				if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
					boyfriendIdleTime += elapsed;
					if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
						boyfriendIdled = true;
					}
				} else {
					boyfriendIdleTime = 0;
				}
			}
			else
			{
				var chara:Int = 0;
				if(!startingSong && !endingSong && boyfriend.otherCharacters[chara].animation.curAnim.name.startsWith('idle')) {
					boyfriendIdleTime += elapsed;
					if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
						boyfriendIdled = true;
					}
				} else {
					boyfriendIdleTime = 0;
				}				
			}
		}

		if(spacebarMash.visible == true){
			if(spacebarMash.animation.finished){
				spacebarMash.animation.play('idle');
			}
		}

		if(boyfriend.latexed == true){
			//latexed
			
			spacebarMash.visible = true;
			spaceTimerText.visible = true;

			var spaceText = Math.round(spaceTimer.timeLeft);

			spaceTimerText.text = "" + spaceText;

			if(spaceAmount < 1){
				boyfriend.latexed = false;
			}

			if(FlxG.keys.justPressed.SPACE){
				spaceAmount--;
				spacebarMash.animation.play('hit', true);
			}

		}else if (boyfriend.latexed == false){
			// not latexed

			spacebarMash.visible = false;
			spaceTimerText.visible = false;
			spaceTimer.active = false;
		}

		super.update(elapsed);

		trailGroup.sort(FlxPerspectiveSprite.sortByZTrail, FlxSort.ASCENDING);
		//otherGroup.sort(FlxPerspectiveSprite.sortByZ, FlxSort.ASCENDING);
		otherGroup.sort( 
			function(order:Int, sprite1:FlxPerspectiveSprite, sprite2:FlxPerspectiveSprite):Int
			{
				return FlxSort.byValues(order, sprite1.z, sprite2.z);
			},
		FlxSort.ASCENDING);

		notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		notes.sort(FlxPerspectiveSprite.sortByZ, FlxSort.ASCENDING);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Array<Dynamic> = [callOnLuas('onPause', [], false), callOnHaxes('onPause', [], false)];
			if(!ret.contains(FunkinLua.Function_Stop)) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}																																

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			if (ClientPrefs.Gengo == 'Jp')
			{
				if (ClientPrefs.healthtxt)
					if (characterPlayingAs != -2)
						if (HealthRight)
							if (characterPlayingAs == -1)
								if (SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
									healthTxt.text = '最小体力: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | 体力: ' + Math.floor(health * 500) / 10 + '%' + ' | 最大体力: ' + Math.floor(maxhealth * 500) / 10 + '%';
								else
									healthTxt.text = '最大体力: ' + Math.floor(maxhealth * 500) / 10 + '%' + ' | 体力: ' + Math.floor(health * 500) / 10 + '%' + ' | 最小体力: ' + Math.floor(minhealth * 500) / 10 + '%';
							else
								healthTxt.text = '最小体力: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | 体力: ' + Math.floor(health * 500) / 10 + '%' + ' | 最大体力: ' + Math.floor(maxhealth * 500) / 10 + '%';
						else
							healthTxt.text = '最大体力: ' + Math.floor(maxhealth * 500) / 10 + '%' + ' | 体力: ' + Math.floor(health * 500) / 10 + '%' + ' | 最小体力: ' + Math.floor(minhealth * 500) / 10 + '%';
					else
						if (HealthRight)
							healthTxt.text = '最小体力: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | 体力: [Dad側 ' + Math.floor(dadhealth * 500) / 10 + '%' + '/ Bf側' + Math.floor(bfhealth * 500) / 10 + '%' + '] | 最大体力: ' + Math.floor(maxhealth * 500) / 10 + '%';
						else
							healthTxt.text = '最大体力: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | 体力: [Bf側 ' + Math.floor(bfhealth * 500) / 10 + '%' + '/ Dad側' + Math.floor(dadhealth * 500) / 10 + '%' + '] | 最小体力: ' + Math.floor(maxhealth * 500) / 10 + '%';
				else
					healthTxt.text = '';
			}
			else
			{
				if (ClientPrefs.healthtxt)
					if (characterPlayingAs != -2)
						if (HealthRight)
							if (characterPlayingAs != -2)
								if (characterPlayingAs == -1)
									if (SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
										healthTxt.text = 'minhealth: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | Health: ' + Math.floor(health * 500) / 10 + '%' + ' | maxhealth: ' + Math.floor(maxhealth * 500) / 10 + '%';
									else
										healthTxt.text = 'maxhealth: ' + Math.floor(maxhealth * 500) / 10 + '%' + ' | Health: ' + Math.floor(health * 500) / 10 + '%' + ' | minhealth: ' + Math.floor(minhealth * 500) / 10 + '%';
								else
									healthTxt.text = 'minhealth: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | Health: ' + Math.floor(health * 500) / 10 + '%' + ' | maxhealth: ' + Math.floor(maxhealth * 500) / 10 + '%';
							else
								healthTxt.text = 'minhealth: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | Health: ' + Math.floor(health * 500) / 10 + '%' + ' | maxhealth: ' + Math.floor(maxhealth * 500) / 10 + '%';
						else
							healthTxt.text = 'maxhealth: ' + Math.floor(maxhealth * 500) / 10 + '%' + ' | Health: ' + Math.floor(health * 500) / 10 + '%' + ' | minhealth: ' + Math.floor(minhealth * 500) / 10 + '%';
					else
						if (HealthRight)
							healthTxt.text = 'minhealth: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | Health: [Dad side ' + Math.floor(dadhealth * 500) / 10 + '%' + '/ Bf side' + Math.floor(bfhealth * 500) / 10 + '%' + '] | minhealth: ' + Math.floor(maxhealth * 500) / 10 + '%';
						else
							healthTxt.text = 'maxhealth: ' + Math.floor(minhealth * 500) / 10 + '%' + ' | Health: [Bf side ' + Math.floor(bfhealth * 500) / 10 + '%' + '/ Dad side' + Math.floor(dadhealth * 500) / 10 + '%' + '] | minhealth: ' + Math.floor(maxhealth * 500) / 10 + '%';
				else
					healthTxt.text = '';			
			}
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (characterPlayingAs != -2 && characterPlayingAs != 3)
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}
		else
		{
			iconP1.x = bfhealthBar.x + (bfhealthBar.width * (FlxMath.remapToRange(bfhealthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = dadhealthBar.x + (dadhealthBar.width * (FlxMath.remapToRange(dadhealthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}

		if (health > maxhealth)
			health = maxhealth;
		
		if (dadhealth > maxhealth)
			dadhealth = maxhealth;
		
		if (bfhealth > maxhealth)
			bfhealth = maxhealth;

		if (HealthRight)
			if (characterPlayingAs == -1)
				if (SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
					healthShown = maxhealth - health;
				else
					healthShown = health;
			else
				healthShown = maxhealth - health;
		else
			healthShown = health;

		if (HealthRight)
		{
			dadhpShown = maxhealth - dadhealth;
			bfhpShown = bfhealth;
		}
		else
		{
			bfhpShown = dadhealth;
			dadhpShown = maxhealth - bfhealth;
		}

		if (characterPlayingAs != -1)
		{
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
			{
				var ret:Array<Dynamic> = [callOnLuas('onIconUpdate', ["player"]), callOnHaxes('onIconUpdate', ["player"])];
				if (!ret.contains(FunkinLua.Function_Stop))
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
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
					else
						if (iconP1.animation.frames == 3) {
							if (bfhealthBar.percent < 20)
								iconP1.animation.curAnim.curFrame = 1;
							else if (bfhealthBar.percent > 80)
								iconP1.animation.curAnim.curFrame = 2;
							else
								iconP1.animation.curAnim.curFrame = 0;
						} else if (iconP1.animation.frames == 1) {
							iconP1.animation.curAnim.curFrame = 0;
						} else {
							if (bfhealthBar.percent < 20)
								iconP1.animation.curAnim.curFrame = 1;
							else
								iconP1.animation.curAnim.curFrame = 0;
						}
				}
				
				var ret:Array<Dynamic> = [callOnLuas('onIconUpdate', ["opponent"]), callOnHaxes('onIconUpdate', ["opponent"])];
				if (!ret.contains(FunkinLua.Function_Stop))
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
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
					else
						if (iconP2.animation.frames == 3) {
							if (dadhealthBar.percent > 80)
								iconP2.animation.curAnim.curFrame = 1;
							else if (dadhealthBar.percent < 20)
								iconP2.animation.curAnim.curFrame = 2;
							else
								iconP2.animation.curAnim.curFrame = 0;
						} else if (iconP2.animation.frames == 1) {
							iconP2.animation.curAnim.curFrame = 0;
						} else {
							if (dadhealthBar.percent > 80)
								iconP2.animation.curAnim.curFrame = 1;
							else
								iconP2.animation.curAnim.curFrame = 0;
						}
				}
			}
			else
			{
				var ret:Array<Dynamic> = [callOnLuas('onIconUpdate', ["player"]), callOnHaxes('onIconUpdate', ["player"])];
				if (!ret.contains(FunkinLua.Function_Stop))
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
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
					else
						if (iconP1.animation.frames == 3) {
							if (bfhealthBar.percent < 20)
								iconP1.animation.curAnim.curFrame = 1;
							else if (bfhealthBar.percent > 80)
								iconP1.animation.curAnim.curFrame = 2;
							else
								iconP1.animation.curAnim.curFrame = 0;
						} else if (iconP1.animation.frames == 1) {
							iconP1.animation.curAnim.curFrame = 0;
						} else {
							if (bfhealthBar.percent < 20)
								iconP1.animation.curAnim.curFrame = 1;
							else
								iconP1.animation.curAnim.curFrame = 0;
						}
				}
				
				var ret:Array<Dynamic> = [callOnLuas('onIconUpdate', ["opponent"]), callOnHaxes('onIconUpdate', ["opponent"])];
				if (!ret.contains(FunkinLua.Function_Stop))
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
						if (iconP2.animation.frames == 3) {
							if (healthBar.percent > 90)
								iconP2.animation.curAnim.curFrame = 1;
							else if (healthBar.percent < 10)
								iconP2.animation.curAnim.curFrame = 2;
							else 
								iconP2.animation.curAnim.curFrame = 0;
						} else if (iconP2.animation.frames == 1) {
							iconP2.animation.curAnim.curFrame = 0;
						} else {
							if (healthBar.percent > 90)
								iconP2.animation.curAnim.curFrame = 1;
							else 
								iconP2.animation.curAnim.curFrame = 0;
						}
					else
						if (iconP2.animation.frames == 3) {
							if (dadhealthBar.percent > 90)
								iconP2.animation.curAnim.curFrame = 1;
							else if (dadhealthBar.percent < 10)
								iconP2.animation.curAnim.curFrame = 2;
							else
								iconP2.animation.curAnim.curFrame = 0;
						} else if (iconP2.animation.frames == 1) {
							iconP2.animation.curAnim.curFrame = 0;
						} else {
							if (dadhealthBar.percent > 90)
								iconP2.animation.curAnim.curFrame = 1;
							else
								iconP2.animation.curAnim.curFrame = 0;
						}
				}
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			/*
			if (ClientPrefs.Gengo == 'Jp')
				MusicBeatState.switchState(new japanese.editors.CharacterEditorState(SONG.player2));
			else
			*/
				MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		song_info_timer += elapsed;

		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			if (song_info_timer >= 0.25 / playbackRate)
			{
				updateSongInfoText();
				song_info_timer = 0;
			}
		}

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name' && ClientPrefs.UiStates == 'Psych-Engine')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				health = 0;
			else
			{
				dadhealth = 0;
				bfhealth = 0;
			}
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);
				callOnHaxes('onSpawnNote', [dunceNote]);
				/*
				for(character in dunceNote.characters)
					callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, character]);
				*/

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if (characterPlayingAs == 2 || characterPlayingAs == 3)
			{
				if(!cpuControlled) {
					dadkeyShit();
					bfkeyShit();
				} else {
					if (dad.otherCharacters == null)
					{
						if(dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss')) {
							dad.dance();
						}
					}
					else
					{
						for (character in dad.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
								character.dance();
							}
						}
					}
					if (boyfriend.otherCharacters == null)
					{
						if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
							boyfriend.dance();
							//boyfriend.animation.curAnim.finish();
						}
					}
					else
					{
						for (character in boyfriend.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
								character.dance();
								//boyfriend.animation.curAnim.finish();
							}
						}
					}
				}
			}
			if (characterPlayingAs == -1 || characterPlayingAs == -2)
			{
				if(!cpuControlled)
					keyShit();
				if (boyfriend.otherCharacters == null)
				{
					if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
						boyfriend.dance();
						//boyfriend.animation.curAnim.finish();
					}
				}
				else
				{
					for (character in boyfriend.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
							character.dance();
							//boyfriend.animation.curAnim.finish();
						}
					}
				}
				if (dad.otherCharacters == null)
				{
					if(dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss')) {
						dad.dance();
						//dad.animation.curAnim.finish();
					}
				}
				else
				{
					for (character in dad.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
							character.dance();
						}
					}
				}
			}
			if (characterPlayingAs == 0)
			{
				if(!cpuControlled) {
					keyShit();
				} else {
					if (boyfriend.otherCharacters == null)
					{
						if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
							boyfriend.dance();
							//boyfriend.animation.curAnim.finish();
						}
					}
					else
					{
						for (character in boyfriend.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
								character.dance();
								//boyfriend.animation.curAnim.finish();
							}
						}
					}
				}
	
				if (dad.otherCharacters == null)
				{
					if(dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss')) {
						dad.dance();
						//dad.animation.curAnim.finish();
					}
				}
				else
				{
					for (character in dad.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
							character.dance();
						}
					}
				}
			}
			if (characterPlayingAs == 1)
			{
				if(!cpuControlled) {
					keyShit();
				} else {
					if (dad.otherCharacters == null)
					{
						if(dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss')) {
							dad.dance();
						}
					}
					else
					{
						for (character in dad.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
								character.dance();
							}
						}
					}
				}
	
				if (boyfriend.otherCharacters == null)
				{
					if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
						boyfriend.dance();
					}
				}
				else
				{
					for (character in boyfriend.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss')) {
							character.dance();
						}
					}
				}
			}
			
			/*
			if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
			*/

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = null;
					if (characterPlayingAs != 2 && characterPlayingAs != 3)
					{
						if(daNote.mustPress) strumGroup = playerStrums;
						if(!daNote.mustPress) strumGroup = opponentStrums;
					}
					else
					{
						if(daNote.mustPress) strumGroup = playerStrums2;
						if(!daNote.mustPress) strumGroup = playerStrums1;
					}
	
					/*
					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumZ:Float = strumGroup.members[daNote.noteData].z;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;
					*/
					var strumX:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].x;
					var strumY:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].y;
					var strumZ:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].z;
					var strumAngle:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData%strumGroup.members.length].downScroll;
					var strumHeight:Float = strumGroup.members[daNote.noteData%strumGroup.members.length].height;

					daNote.z = strumZ;
					
					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					/*
					daNote.z = strumZ;
					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;
					*/

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1) * Note.scales[mania];
						}
					}

					if (characterPlayingAs == 2 || characterPlayingAs == 3)
					{
						if(!daNote.blockHit && !daNote.mustPress && cpuControlled && daNote.canBeHit) {
							if(daNote.isSustainNote) {
								if(daNote.canBeHit) {
									DadNoteHit(daNote);
								}
							} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
								DadNoteHit(daNote);
							}
						}
					}
					else
					{
						if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
						{
							opponentNoteHit(daNote);
						}
					}
					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}
					var center:Float = strumY + Note.swagWidth / 2;

					if(strumGroup.members[daNote.noteData%strumGroup.members.length].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (!cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
						{
							if (daNote.mustPress)
								noteMiss(daNote, 1);
							else
								noteMiss(daNote, 2);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		callOnHaxes('updatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			dadvocals.pause();
			boyfriendvocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		/*
		if (ClientPrefs.Gengo == 'Jp')
			MusicBeatState.switchState(new japanese.editors.ChartingState());
		else
		*/
			MusicBeatState.switchState(new ChartingState());

		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (!(characterPlayingAs == 2 || characterPlayingAs == 3))
		{
			if (((skipHealthCheck && instakillOnMiss) || (characterPlayingAs == -2 ? (dadhealth + bfhealth) : health) <= minhealth) && !practiceMode && !isDead)
			{
				var ret:Array<Dynamic> = [callOnLuas('onGameOver', [], false), callOnHaxes('onGameOver', [], false)];
				if(!ret.contains(FunkinLua.Function_Stop)) {
					boyfriend.stunned = true;
					deathCounter++;
	
					paused = true;
	
					vocals.stop();
					dadvocals.stop();
					boyfriendvocals.stop();
					
					FlxG.sound.music.stop();
	
					persistentUpdate = false;
					persistentDraw = false;
					for (tween in modchartTweens) {
						tween.active = true;
					}
					for (timer in modchartTimers) {
						timer.active = true;
					}
					if(boyfriend.otherCharacters == null)
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
					else
					{
						var lol:Int = 0;
						if (BfOtherCharacterCamera <= boyfriend.otherCharacters.length)
							openSubState(new GameOverSubstate(boyfriend.otherCharacters[BfOtherCharacterCamera].getScreenPosition().x - boyfriend.otherCharacters[BfOtherCharacterCamera].positionArray[0], boyfriend.otherCharacters[BfOtherCharacterCamera].getScreenPosition().y - boyfriend.otherCharacters[BfOtherCharacterCamera].positionArray[1], camFollowPos.x, camFollowPos.y));
						else
							openSubState(new GameOverSubstate(boyfriend.otherCharacters[lol].getScreenPosition().x - boyfriend.otherCharacters[lol].positionArray[0], boyfriend.otherCharacters[lol].getScreenPosition().y - boyfriend.otherCharacters[lol].positionArray[1], camFollowPos.x, camFollowPos.y));
					}
	
					// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					
					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
					#end
					isDead = true;
					return true;
				}
			}
		}
		if (characterPlayingAs != -2 && characterPlayingAs != 3)
		{
			if (health < minhealth)
				health = minhealth;
		}
		else
		{
			if (bfhealth < minhealth)
				bfhealth = minhealth;

			if (dadhealth < minhealth)
				dadhealth = minhealth;
		}

		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function updateSongInfoText()
	{
		if (ClientPrefs.UiStates == 'Leather-Engine')
		{
			var songThingy = Conductor.songPosition - ClientPrefs.noteOffset;

			var seconds = Math.floor(songThingy / 1000);
			seconds = Std.int(seconds / playbackRate);
		
			var songCalc:Float = (songLength - songThingy);
			songCalc = songThingy;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if (secondsTotal < 0)
				secondsTotal = 0;

			if (!endingSong)
			{
				infoTxt.text = SONG.song
					+ " - "
					+ (CoolUtil.difficultyString())
					//+ ' (${FlxStringUtil.formatTime(secondsTotal, false)})'
					+ ' (${FlxStringUtil.formatTime(songLength / 1000, false)} / ${FlxStringUtil.formatTime(secondsTotal, false)})'
					+ (cpuControlled ? " (Bot)" : "")
					+ (practiceMode ? " (Practice Mode)" : "")
					+ (instakillOnMiss ? " (No Miss)" : "")
					+ (characterPlayingAs == 1 ? " (Dad Play)" : (characterPlayingAs == -1 ? " (together health both play)" :
					(characterPlayingAs == -2 ? " (not together health both play)" : "")));
				infoTxt.screenCenter(X);
			}
			else
			{
				infoTxt.text = SONG.song
					+ " - "
					+ (CoolUtil.difficultyString())
					//+ ' (${FlxStringUtil.formatTime(secondsTotal, false)})'
					+ ' (${FlxStringUtil.formatTime(songLength / 1000, false)} / ${FlxStringUtil.formatTime(songLength / 1000, false)})'
					+ (cpuControlled ? " (Bot)" : "")
					+ (practiceMode ? " (Practice Mode)" : "")
					+ (instakillOnMiss ? " (No Miss)" : "")
					+ (characterPlayingAs == 1 ? " (Dad Play)" : (characterPlayingAs == -1 ? " (together health both play)" :
					(characterPlayingAs == -2 ? " (not together health both play)" : "")));
				infoTxt.screenCenter(X);
			}
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Shaggy burst':
				var value:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'dad' | 'opponent':
					value = 0;
					case 'bf' | 'player' | 'boyfriend':
					value = 1;
				}
				var val2:Int = Std.parseInt(value2);

				switch(value)
				{
					case 0:
						if (dad.otherCharacters != null)
							burstRelease(dad.otherCharacters[val2].getMidpoint().x, dad.otherCharacters[val2].getMidpoint().y);
						else
							burstRelease(dad.getMidpoint().x, dad.getMidpoint().y);	

					case 1:
						if (boyfriend.otherCharacters != null)
							burstRelease(boyfriend.otherCharacters[val2].getMidpoint().x, boyfriend.otherCharacters[val2].getMidpoint().y);
						else
							burstRelease(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y);
				}

			case 'Camera rotate on':
				rotCam = true;
				rotCamSpd = Std.parseFloat(value1);
				rotCamRange = Std.parseFloat(value2);

			case 'Camera rotate off':
				rotCam = false;
				camera.angle = 0;

			case 'Toggle bg dim':
				dimGo = !dimGo;

			case 'HealthBar Opposition':
				if (characterPlayingAs != -1)
				{
					fliplol = !fliplol;
					HealthRight = !HealthRight;
					if (!fliplol)
					{
						iconP1.changeIcon(boyfriend.healthIcon);
						iconP2.changeIcon(dad.healthIcon);
					}
					else
					{
						iconP1.changeIcon(dad.healthIcon);
						iconP2.changeIcon(boyfriend.healthIcon);
					}
					reloadHealthBarColors();
				}

			case 'Max Health & Min Health':
				var value:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'Max Health' | 'max health' | 'MaxHealth' | 'maxhealth' | '0':
						value = 0;
					case 'Min Health' | 'min health' | 'MinHealth' | 'minhealth' | '1':
						value = 1;
				}
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val2)) val2 = 1;

				switch(value)
				{
					case 0: //enable and target dad
					boyfriendmaxhealth = val2 / 2;
					dadmaxhealth = val2 / 2;

					case 1: //enable and target dad
					boyfriendminhealth = val2 / 2;
					dadminhealth = val2 / 2;
				}
				maxhealth = ((boyfriendmaxhealth + dadmaxhealth));

				if (((boyfriendminhealth + dadminhealth)) < maxhealth)
					minhealth = ((boyfriendminhealth + dadminhealth));
				else
					minhealth = 0;

				if (characterPlayingAs != -2 && characterPlayingAs != 3)
					remove(healthBar);
				{
					remove(dadhealthBar);
					remove(bfhealthBar);
				}
				
				/*
				if (!HealthRight)
					healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
						'healthShown', minhealth, maxhealth);
				else
					healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
						'maxhealthShown', (maxhealth - maxhealth), (maxhealth - minhealth));
				*/

				if (ClientPrefs.UiStates != 'Forever-Engine')
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
						healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
						'healthShown', minhealth, maxhealth);
					else
					{
						bfhealthBar = new FlxBar(healthBarBG.x + healthBarBG.width / 2 - 1, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
							'bfhpShown', minhealth, maxhealth);
		
						dadhealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width / 2 - 4), Std.int(healthBarBG.height - 8), this,
							'dadhpShown', minhealth, maxhealth);
					}
				}
				else
				{
					if (characterPlayingAs != -2 && characterPlayingAs != 3)
						healthBar = new FlxBar(foreverhealthBarBG.x + 4, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width - 8), Std.int(foreverhealthBarBG.height - 8), this,
						'healthShown', minhealth, maxhealth);
					else
					{
						bfhealthBar = new FlxBar(foreverhealthBarBG.x + foreverhealthBarBG.width / 2 - 1, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width / 2 - 4), Std.int(foreverhealthBarBG.height - 8), this,
							'bfhpShown', minhealth, maxhealth);
		
						dadhealthBar = new FlxBar(foreverhealthBarBG.x + 4, foreverhealthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(foreverhealthBarBG.width / 2 - 4), Std.int(foreverhealthBarBG.height - 8), this,
							'dadhpShown', minhealth, maxhealth);
					}
				}
				
				remove(iconP1);
				remove(iconP2);
				if (characterPlayingAs != -2 && characterPlayingAs != 3)
				{
					healthBar.scrollFactor.set();
					healthBar.visible = !ClientPrefs.hideHud;
					add(healthBar);
				}
				else
				{
					bfhealthBar.scrollFactor.set();
					bfhealthBar.visible = !ClientPrefs.hideHud;
					add(bfhealthBar);
					dadhealthBar.scrollFactor.set();
					dadhealthBar.visible = !ClientPrefs.hideHud;
					add(dadhealthBar);
				}
				add(iconP1);
				add(iconP2);
				if (characterPlayingAs != -2 && characterPlayingAs != 3)
					healthBar.cameras = [camHUD];
				else
				{
					bfhealthBar.cameras = [camHUD];
					dadhealthBar.cameras = [camHUD];
				}
				reloadHealthBarColors();

			case 'Normal Wave':
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 1;
				
				bossToggle1 = !bossToggle1;

				if(bossToggle1 == true){
					var waveoffset = 10;
					var wavetimerdef = 0.06;
					var waveamm = 1;
					var wavetime = wavetimerdef;
					var wavetimer = new FlxTimer();

					healthTxt.visible = false;

					// ========================== BOSS ON (Waves) ========================== 
					wavetimer.start(wavetime, function(tmr:FlxTimer){
						createWaves(waveamm, 720+waveoffset, particleEmitter, false);
						if(bossToggle1 == true){
							wavetimer.reset();
						}
					});
					//trace("boss toggle enabled");
				}else{
					healthTxt.visible = true;
					// ========================== BOSS OFF ==========================
					//trace("boss toggle disabled");
				}
					
			case 'Up Down Wave':
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 1;

				bossToggle2 = !bossToggle2;

				if(bossToggle2 == true){
					// ========================== ENABLE BOSS MODE ==========================

					//new FlxTimer().start((tweenTime/tentacleAmount)*i+introtime, function(tmr:FlxTimer){

					var waveoffset = 10;
					var wavetimerdef = 0.03;
					var waveamm = 1;
					var wavetime = wavetimerdef;
					var wavetimer = new FlxTimer();
					var topwave = false;
					wavetimer.start(wavetime, function(tmr:FlxTimer){
							if(topwave == false){
								createWaves(waveamm, 720+waveoffset, particleEmitter, false);
								topwave = true;
							}else{
								createWaves(waveamm, -waveoffset, particleEmitter2, true);
								topwave = false;
							}

							if(bossToggle2 == true){
								wavetimer.reset();
							}
					});
					//trace("boss toggle enabled");

					if(val1 == 1){
						tentacles = true;
					}else{
						tentacles = false;
					}

				}else{

					trace("boss toggle disabled");
				}

			case 'Boss Event Fish':
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 1;
				
				createSharks(val1, 720+100, sharkEmitter);

			case 'Boss Event Drippin':
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 1;
				
				tentacleDir = val1;
				tentacleRate = val2;

			case 'Boss Event 2':
				var val1:Int = Std.parseInt(value1); 
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 1;

				createTentacles(val1, val2, tentacleEmitter);

			case 'otherCharacterCameraSwitch':
				var value:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'dad' | 'opponent':
					value = 0;
					case 'bf' | 'player' | 'boyfriend':
					value = 1;
				}
				var val2:Int = Std.parseInt(value2);

				switch(value)
				{
					case 0:
					DadOtherCharacterCamera = val2;	

					case 1:
					BfOtherCharacterCamera = val2;	
				}

			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			case 'Change Mania':
				var newMania:Int = 0;
				var skipTween:Bool = value2 == "true" ? true : false;

				newMania = Std.parseInt(value1);
				if(Math.isNaN(newMania) && newMania < 0 && newMania > Note.maxMania)
					newMania = 0;
				changeMania(newMania, skipTween);

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;

							if(boyfriend.otherCharacters == null)
							{
								boyfriend.alpha = 0.00001;
								if (boyfriend.coolTrail != null)
									boyfriendGroup.remove(boyfriend.coolTrail);
							}
							else
							{
								for(character in boyfriend.otherCharacters)
								{
									character.alpha = 0.00001;
									if (character.coolTrail != null)
										boyfriendGroup.remove(character.coolTrail);
								}
							}

							boyfriend = boyfriendMap.get(value2);

							setOnHaxes('boyfriend', boyfriend);
							callOnLuas("onChangeCharacter", ["bf"]);
							callOnHaxes("onChangeCharacter", ["bf"]);
							
							if(boyfriend.otherCharacters == null)
							{
								boyfriend.alpha = lastAlpha;
								if (boyfriend.coolTrail != null)
									boyfriendGroup.add(boyfriend.coolTrail);
								boyfriendGroup.remove(boyfriend);
								boyfriendGroup.add(boyfriend);
							}
							else
							{
								for(character in boyfriend.otherCharacters)
								{
									character.alpha = lastAlpha;
									if (character.coolTrail != null)
										boyfriendGroup.add(character.coolTrail);
									boyfriendGroup.remove(character);
									boyfriendGroup.add(character);
								}
							}

							if (boyfriend.maxhealth >= 0)
								boyfriendmaxhealth = boyfriend.maxhealth;
							else
								boyfriendmaxhealth = 2;

							if (boyfriend.minhealth < boyfriend.maxhealth)
								boyfriendminhealth = boyfriend.minhealth;
							else
								boyfriendminhealth = 0;

							if (!fliplol)
								iconP1.changeIcon(boyfriend.healthIcon);
							else
								iconP2.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;

							if(dad.otherCharacters == null)
							{
								dad.alpha = 0.00001;
								if (dad.coolTrail != null)
									dadGroup.remove(dad.coolTrail);
							}
							else
							{
								for(character in dad.otherCharacters)
								{
									character.alpha = 0.00001;
									if (character.coolTrail != null)
										dadGroup.remove(character.coolTrail);
								}
							}

							dad = dadMap.get(value2);
							
							setOnHaxes('dad', dad);
							callOnLuas("onChangeCharacter", ["dad"]);
							callOnHaxes("onChangeCharacter", ["dad"]);

							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}

							if(dad.otherCharacters == null)
							{
								dad.alpha = lastAlpha;
								if (dad.coolTrail != null)
									dadGroup.add(dad.coolTrail);
								dadGroup.remove(dad);
								dadGroup.add(dad);
							}
							else
							{
								for(character in dad.otherCharacters)
								{
									character.alpha = lastAlpha;
									if (character.coolTrail != null)
										dadGroup.add(character.coolTrail);
									dadGroup.remove(character);
									dadGroup.add(character);
								}
							}

							if (dad.maxhealth >= 0)
								dadmaxhealth = dad.maxhealth;
							else
								dadmaxhealth = 2;

							if (dad.minhealth < dad.maxhealth)
								dadminhealth = dad.minhealth;
							else
								dadminhealth = 0;

							if (!fliplol)
								iconP2.changeIcon(dad.healthIcon);
							else
								iconP1.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;

								if(gf.otherCharacters == null)
								{
									gf.alpha = 0.00001;
									if (gf.coolTrail != null)
										gfGroup.remove(gf.coolTrail);
								}
								else
								{
									for(character in gf.otherCharacters)
									{
										character.alpha = 0.00001;
										if (character.coolTrail != null)
											gfGroup.remove(character.coolTrail);
									}
								}
								
								gf = gfMap.get(value2);
								
								setOnHaxes('gf', gf);
								callOnLuas("onChangeCharacter", ["gf"]);
								callOnHaxes("onChangeCharacter", ["gf"]);

								if(gf.otherCharacters == null)
								{
									gf.alpha = lastAlpha;
									if (gf.coolTrail != null)
										gfGroup.add(gf.coolTrail);
								}
								else
								{
									for(character in gf.otherCharacters)
									{
										character.alpha = lastAlpha;
										if (character.coolTrail != null)
											gfGroup.add(character.coolTrail);
									}
								}
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
				
			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
		callOnHaxes('onEvent', [eventName, value1, value2]);
	}

	function createWaves(waveNumber:Int, yy, emitter:FlxEmitter, flip:Bool){
		var offsetx = FlxG.random.int(-200, 1480);
		var angle = -90;
		var anglemod = 20;

		var speed = 400;
		var speedmod = 100;

		var grav = 850;
		var gravmod = 100;

		var mult = 2;
		//var offsety = 800;

		if(flip == true){
			anglemod = -anglemod;
			angle = -angle;
			//speed = -speed;
			//speedmod = -speedmod;
			grav = -grav;
			gravmod = -gravmod;
			//mult = -mult;
		}

		emitter.x = offsetx;
		emitter.y = yy;

        for (i in 0...waveNumber){

			var scale = FlxG.random.float(3, 3.2);			

            var particle:FlxParticle = new FlxParticle();
            particle.loadGraphic(Paths.image('changed/bg-squiddog/oldArt/squogWater'), false, 1, 1);
			if(flip == true){
				particle.flipY = true;
			}
			particle.cameras = [camHUD];

			particle.visible = true;
			emitter.scale.set(scale);
			emitter.alpha.set(FlxG.random.float(0.7, 0.9));
			emitter.acceleration.start.min.y = grav;
			emitter.acceleration.start.max.y = grav+gravmod;
			emitter.acceleration.end.max.y = grav+(gravmod*mult);
			emitter.acceleration.end.max.y = grav+(gravmod*mult);
			emitter.launchAngle.set(angle+anglemod, angle-anglemod);
			emitter.speed.set(speed,speed+speedmod,speed,speed+speedmod);
			emitter.add(particle);
        }
		emitter.start(true, 12, waveNumber);
    }

	function createSharks(sharkNumber:Int, yy, emitter:FlxEmitter){
		var offsetx = FlxG.random.int(280, 1000);
		var angle = -90;
		var anglemod = 20;

		var speed = FlxG.random.int(1400, 2200);
		var speedmod = 100;

		var grav = 3000; // was 2000
		var gravmod = 100;

		var mult = 2;
		//var offsety = 800;

		emitter.x = offsetx;
		emitter.y = yy;

        for (i in 0...sharkNumber){
			
			var egg = FlxG.random.int(0, 0);
			var scale = FlxG.random.float(1.6, 1.6);
			var shark = FlxG.random.int(0, 2);
			var particle:FlxParticle = new FlxParticle();

			switch(shark){
				case 0 | 2:
					particle.loadGraphic(Paths.image('changed/bg-tigershark/oldArt/sharks/SHARK'+shark), false, 1, 1);
				case 1:
					particle.loadGraphic(Paths.image('changed/bg-tigershark/oldArt/sharks/SHARK'+shark), true, 165, 165);
					particle.animation.add('anim', [0, 1, 2, 3], 10, true);
					particle.animation.play('anim', true);
				}

			particle.antialiasing = false;
			var flip:Bool = FlxG.random.bool();

			if(flip == true){
				anglemod = -anglemod;
				particle.flipX = true;
			}

			particle.cameras = [camHUD];

			particle.visible = true;
			emitter.scale.set(scale);
			emitter.acceleration.start.min.y = grav;
			emitter.acceleration.start.max.y = grav+gravmod;
			emitter.acceleration.end.max.y = grav+(gravmod*mult);
			emitter.acceleration.end.max.y = grav+(gravmod*mult);
			emitter.launchAngle.set(angle+anglemod, angle-anglemod);
			emitter.speed.set(speed,speed+speedmod,speed,speed+speedmod);
			emitter.add(particle);
        }
		emitter.start(true, 12, sharkNumber);
    }


	function createTentacles(wall:Int = 1, dir:Int = 0, emitter:FlxEmitter){

		// WALL
		//1 = left
		//2 = down
		//3 = right
		//4 = up

		// DIR
		//1 = noflip
		//2 = flip
		for(i in 0...6){
			var angle = 90;
			var speed = 800;

			var dur = 0.5;

			var offscreen = 100;
			var horangle = 90;
			var verangle = 180;

			var xSpawn = 1280;
			var ySpawn = 0;

			var scale = 2.6;
			var particle:FlxParticle = new FlxParticle();
			var partangle = 0;
			var hDistance = 40;
			var vDistance = 20;
			var xx = 0;

			particle.loadGraphic(Paths.image('changed/bg-squiddog/oldArt/squogTentacle'), true, 256, 66);
			particle.animation.add('anim', [0, 1], 8, true);
			particle.animation.play('anim', true);
			particle.antialiasing = false;
			particle.scale.set(scale);
			particle.updateHitbox();

			if(dir == 1){
				offscreen = -offscreen;
				horangle = 270;
				verangle = 0;
				xSpawn = 0;
				ySpawn = 720;
			}

			var distanceX = 100;
			var distanceY = 50;
			switch(wall){
				case 1:
					// === LEFT ===

					emitter.x = 0-xx-distanceX;
					emitter.y = ySpawn-offscreen;
					//particle.x = emitter.x;
					angle = horangle;
					//particle.x = sin()
					//var tween = FlxTween.tween(particle, {x: emitter.x+hDistance}, dur, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

				case 2:
					// === DOWN ===
					emitter.x = xSpawn+offscreen;
					emitter.y = 720+distanceY;
					//particle.y = emitter.y;
					angle = verangle;
					partangle = 90;
					//var tween = FlxTween.tween(particle, {y: emitter.y -vDistance}, dur, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

				case 3:
					// === RIGHT ===

					emitter.x = 640+xx+distanceX;
					emitter.y = ySpawn-offscreen;
					//particle.x = emitter.x;
					angle = horangle;
					particle.flipX = true;

					//var tween = FlxTween.tween(particle, {x: emitter.x-hDistance}, dur, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

				case 4:
					// === UP ===
					
					emitter.x = xSpawn+offscreen;
					emitter.y = 0-distanceY;
					//particle.y = emitter.y;
					angle = verangle;
					partangle = 90;
					particle.flipX = true;

					//var tween = FlxTween.tween(particle, {y: emitter.y+vDistance}, dur, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
			}

			particle.cameras = [camHUD];
			particle.visible = true;
			emitter.angle.set(partangle);
			emitter.scale.set(scale);
			emitter.launchAngle.set(angle);
			emitter.speed.set(speed);
			emitter.add(particle);
		}
		emitter.start(true, 5, 1);
    }

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			callOnHaxes('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			if(ClientPrefs.camMovement && !PlayState.isPixelStage){
				campointx = camFollow.x;
				campointy = camFollow.y;
				bfturn = false;
				camlock = false;
			}
			callOnLuas('onMoveCamera', ['dad']);
			callOnHaxes('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			if(ClientPrefs.camMovement && !PlayState.isPixelStage){
				campointx = camFollow.x;
				campointy = camFollow.y;	
				bfturn = true;
				camlock = false;
			}
			callOnLuas('onMoveCamera', ['boyfriend']);
			callOnHaxes('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		/*
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
		*/
		var lol:Int = 0;
		if(isDad)
		{
			if (dad.otherCharacters != null)
			{
				if (DadOtherCharacterCamera <= dad.otherCharacters.length)
				{
					camFollow.set(dad.otherCharacters[DadOtherCharacterCamera].getMidpoint().x + 150, dad.otherCharacters[DadOtherCharacterCamera].getMidpoint().y - 100);
					camFollow.x += dad.otherCharacters[DadOtherCharacterCamera].cameraPosition[0] + opponentCameraOffset[0];
					camFollow.y += dad.otherCharacters[DadOtherCharacterCamera].cameraPosition[1] + opponentCameraOffset[1];					
				}
				else
				{
					camFollow.set(dad.otherCharacters[lol].getMidpoint().x + 150, dad.otherCharacters[lol].getMidpoint().y - 100);
					camFollow.x += dad.otherCharacters[lol].cameraPosition[0] + opponentCameraOffset[0];
					camFollow.y += dad.otherCharacters[lol].cameraPosition[1] + opponentCameraOffset[1];					
				}
			}
			else
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			}
			tweenCamIn();
		}
		else
		{
			if (boyfriend.otherCharacters != null)
			{
				if (BfOtherCharacterCamera <= boyfriend.otherCharacters.length)
				{
					camFollow.set(boyfriend.otherCharacters[BfOtherCharacterCamera].getMidpoint().x - 100, boyfriend.otherCharacters[BfOtherCharacterCamera].getMidpoint().y - 100);
					camFollow.x -= boyfriend.otherCharacters[BfOtherCharacterCamera].cameraPosition[0] - boyfriendCameraOffset[0];
					camFollow.y += boyfriend.otherCharacters[BfOtherCharacterCamera].cameraPosition[1] + boyfriendCameraOffset[1];					
				}
				else
				{
					camFollow.set(boyfriend.otherCharacters[lol].getMidpoint().x - 100, boyfriend.otherCharacters[lol].getMidpoint().y - 100);
					camFollow.x -= boyfriend.otherCharacters[lol].cameraPosition[0] - boyfriendCameraOffset[0];
					camFollow.y += boyfriend.otherCharacters[lol].cameraPosition[1] + boyfriendCameraOffset[1];					
				}
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			}

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = ResultorendSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		dadvocals.volume = 0;
		boyfriendvocals.volume = 0;

		vocals.pause();
		dadvocals.pause();
		boyfriendvocals.pause();

		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;
	
	public function ResultorendSong():Void
	{
		fliplol = false;

		BfOtherCharacterCamera = 0;
		DadOtherCharacterCamera = 0;

		if(!startingSong) {
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
			{
				notes.forEach(function(daNote:Note)
				{
					if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
						health -= 0.05 * healthLoss;
					}
				});
				for (daNote in unspawnNotes)
				{
					if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
						health -= 0.05 * healthLoss;
					}
				}
			}
			else
			{
				notes.forEach(function(daNote:Note)
				{
					if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
						if (daNote.opponentSing)
							dadhealth -= 0.05 * healthLoss;
						if (!daNote.opponentSing)
							bfhealth -= 0.05 * healthLoss;
					}
				});
				for (daNote in unspawnNotes)
				{
					if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
						if (daNote.opponentSing)
							dadhealth -= 0.05 * healthLoss;
						if (!daNote.opponentSing)
							bfhealth -= 0.05 * healthLoss;
					}
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		paused = true;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Array<Dynamic> = [callOnLuas('onResultSong', [], false), callOnHaxes('onResultSong', [], false)];
		if(!ret.contains(FunkinLua.Function_Stop) && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				if (characterPlayingAs != -1 || characterPlayingAs != -2 && !ClientPrefs.getGameplaySetting('botplay', false))
					Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (ClientPrefs.Results)
				Results();
			else
				endSong();
		}
	}
	public function Results():Void
	{
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence('Play Stail is ' + playStailText + ' ' + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		#end
		openSubState(new ResultsScreenSubstate());
	}

	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		
		paused = false;
		var ret:Array<Dynamic> = [callOnLuas('onEndSong', [], false), callOnHaxes('onEndSong', [], false)];
		if(!ret.contains(FunkinLua.Function_Stop) && !transitioning) {
			if (chartingMode)
			{
				openChartEditor();
				return;
			}
			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					if (ClientPrefs.Gengo == 'Jp')
						MusicBeatState.switchState(new japanese.StoryMenuState());
					else
						MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						japanese.StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							if (characterPlayingAs != -1 || characterPlayingAs != -2 && !ClientPrefs.getGameplaySetting('botplay', false))
								Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						japanese.StoryMenuState.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());

				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			ResultorendSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var totalNotes:Int = 0;
	public var hitNotes:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	var accuracyText:FlxText = new FlxText(0, 0, 0, "bruh", 24);
	var accuracyTween:VarTween;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private var ratingTiming:String = "";

	private function popUpScore(note:Note = null, strumtime:Float, player1:Bool = false, playernum:Int = 1):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		var statsToUse = getStats(playernum);

		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		if (!note.opponentSing)
			boyfriendvocals.volume = 1;
		if (note.opponentSing)
			dadvocals.volume = 1;

		if (cpuControlled)
			noteDiff = 0;

		var placement:String = '';

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
			placement = Std.string(statsToUse.combo);
		else
			placement = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxPerspectiveSprite = new FlxPerspectiveSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);
		var daSusting:String = Conductor.LeatherjudgeNote(note, Math.abs(noteDiff) / playbackRate);
		var Leatherscore:Int = Ratings.getScore(daSusting);

		var hitNoteAmount:Float = 0;
		
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			if (ClientPrefs.UiStates == 'Leather-Engine')
			{
				if (cpuControlled)
				{
					totalNotesHit += 1;
					note.ratingMod = 1;
					if(!note.ratingDisabled)
					{
						if (ClientPrefs.MarvelouTrue)
						{
							marvelous++;
							note.rating = 'marvelou';
						}
						else
						{
							sicks++;
							note.rating = 'sick';
						}
					}
					
					hitNoteAmount = 1;
					spawnNoteSplashOnNote(note);
				}
				else
				{
					switch (daSusting)
					{
						case "shit": // shit
							totalNotesHit += 0.25;
							note.ratingMod = 0.25;
							if(!note.ratingDisabled) shits++;
							note.rating = 'shit';
						case "bad": // bad
							totalNotesHit += 0.5;
							note.ratingMod = 0.5;
							hitNoteAmount = 0.3;
							
							if(!note.ratingDisabled) bads++;
							note.rating = 'bad';
						case "good": // good
							totalNotesHit += 0.8;
							note.ratingMod = 0.8;
							hitNoteAmount = 0.8;
							
							if(!note.ratingDisabled) goods++;
							note.rating = 'good';
						case "sick": // sick
							totalNotesHit += 1;
							note.ratingMod = 1;
							hitNoteAmount = 1;
							
							if(!note.ratingDisabled) sicks++;
							note.rating = 'sick';
							spawnNoteSplashOnNote(note);
						case "marvelous":
							totalNotesHit += 1;
							note.ratingMod = 1;
							if(!note.ratingDisabled)
							{
								if (ClientPrefs.MarvelouTrue)
								{
									marvelous++;
									note.rating = 'marvelou';
								}
								else
								{
									sicks++;
									note.rating = 'sick';
								}
							}
							hitNoteAmount = 1;
							spawnNoteSplashOnNote(note);
					}
				}
				score = 0;
				songScore += Leatherscore;
				hitNotes += hitNoteAmount;
			}
			else
			{
				totalNotesHit += daRating.ratingMod;
				note.ratingMod = daRating.ratingMod;
				if(!note.ratingDisabled) daRating.increase();
				note.rating = daRating.name;
				score = daRating.score;
	
				if(daRating.noteSplash && !note.noteSplashDisabled)
				{
					spawnNoteSplashOnNote(note);
				}
			}
		}
		else
		{
			statsToUse.totalNotesHit++;
			if (ClientPrefs.UiStates == 'Leather-Engine')
			{
				if (cpuControlled)
				{
					note.ratingMod = 1;
					if(!note.ratingDisabled)
					{
						if (ClientPrefs.MarvelouTrue)
						{
							statsToUse.marvelous++;
							note.rating = 'marvelou';
						}
						else
						{
							statsToUse.sicks++;
							note.rating = 'sick';
						}
					}
					
					statsToUse.hitNoteAmount = 1;
					if (!player1)
						spawnNoteSplashOnNote(note);
					else
						spawnNoteSplashDadOnNote(note);
				}
				else
				{
					switch (daSusting)
					{
						case "shit": // shit
							note.ratingMod = 0.25;
							if(!note.ratingDisabled) statsToUse.shits++;
							note.rating = 'shit';
						case "bad": // bad
							note.ratingMod = 0.5;
							statsToUse.hitNoteAmount = 0.3;
							
							if(!note.ratingDisabled) statsToUse.bads++;
							note.rating = 'bad';
						case "good": // good
							note.ratingMod = 0.8;
							statsToUse.hitNoteAmount = 0.8;
							
							if(!note.ratingDisabled) statsToUse.goods++;
							note.rating = 'good';
						case "sick": // sick
							note.ratingMod = 1;
							statsToUse.hitNoteAmount = 1;
							
							if(!note.ratingDisabled) statsToUse.sicks++;
							note.rating = 'sick';
							if (!player1)
								spawnNoteSplashOnNote(note);
							else
								spawnNoteSplashDadOnNote(note);
						case "marvelous":
							note.ratingMod = 1;
							if(!note.ratingDisabled)
							{
								if (ClientPrefs.MarvelouTrue)
								{
									statsToUse.marvelous++;
									note.rating = 'marvelou';
								}
								else
								{
									statsToUse.sicks++;
									note.rating = 'sick';
								}
							}
							statsToUse.hitNoteAmount = 1;
							if (!player1)
								spawnNoteSplashOnNote(note);
							else
								spawnNoteSplashDadOnNote(note);
					}
				}
				score = 0;
				songScore += Leatherscore;
				statsToUse.hitNotes += statsToUse.hitNoteAmount;
			}
			else
			{
				note.ratingMod = daRating.ratingMod;
				if(!note.ratingDisabled)
					switch (daSusting)
					{
						case "shit": // shit
						statsToUse.shits++;
						case "bad": // bad
						statsToUse.bads++;
						case "good": // good
						statsToUse.goods++;
						case "sick": // sick
						statsToUse.sicks++;
						case "marvelous":
						statsToUse.sicks++;
					}

				note.rating = daRating.name;
				score = daRating.score;
	
				if(daRating.noteSplash && !note.noteSplashDisabled)
				{
					if (!player1)
						spawnNoteSplashOnNote(note);
					else
						spawnNoteSplashDadOnNote(note);
				}
				if(statsToUse.fullCombo)
					if (statsToUse.shits >= 1 || statsToUse.bads >= 1 || statsToUse.goods >= 1)
						statsToUse.fullCombo = false;
			}
		}

		if (ClientPrefs.UiStates == 'Leather-Engine' && ClientPrefs.sideRatings)
			updateRatingText();

		if(!practiceMode && !cpuControlled) {
			if (ClientPrefs.UiStates != 'Leather-Engine')
				if (characterPlayingAs != 2 && characterPlayingAs != 3)
					songScore += score;
				else
					statsToUse.songScore += score;
			if(!note.ratingDisabled)
			{
				if (characterPlayingAs != 2 && characterPlayingAs != 3)
				{
					songHits++;
					totalPlayed++;
				}
				else
				{
					statsToUse.songHits++;
					statsToUse.totalPlayed++;
				}
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (ClientPrefs.UiStates == 'Forever-Engine')
		{
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
			{
				if ((ratingPercent == 1 && (!cpuControlled || !practiceMode)))
					rating.loadGraphic(Paths.image(pixelShitPart1 + 'allsick' + pixelShitPart2));
				else
					rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
			}
			else
			{
				if (statsToUse.fullCombo && (!cpuControlled || !practiceMode))
					rating.loadGraphic(Paths.image(pixelShitPart1 + 'allsick' + pixelShitPart2));
				else
					rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
			}
		}
		else
		{
			if (ClientPrefs.UiStates == 'Leather-Engine')
				rating.loadGraphic(Paths.image(pixelShitPart1 + daSusting + pixelShitPart2));
		    else
				rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		}

		if(!ClientPrefs.comboCamera)
			rating.cameras = [camHUD];
			
		rating.screenCenter();

		if (ClientPrefs.ratingCharacter)
		{
			rating.cameras = [camGame];
			onRatingOffsetCamera(note, rating);
		}
		else
			rating.x = coolText.x - 40;
		
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		if (ClientPrefs.UiStates == 'Leather-Engine' || ClientPrefs.UiStates == 'Kade-Engine' || ClientPrefs.accuracyTextVisible)
		{
			var noteMath:Float = FlxMath.roundDecimal(noteDiff, 2);

			accuracyText.setPosition(rating.x, rating.y + 100);
			accuracyText.text = ((strumtime < Conductor.songPosition + ClientPrefs.ratingOffset) ? "-" : "") + noteMath + " ms" + ((cpuControlled) ? " (BOT)" : "");
	
			if(!ClientPrefs.comboCamera)
				accuracyText.cameras = [camHUD];
	
			if(ClientPrefs.ratingCharacter)
				accuracyText.cameras = [camGame];

				// if (Math.abs(noteMath) == noteMath)
				if (strumtime < Conductor.songPosition)
					accuracyText.color = FlxColor.ORANGE;
				else
					accuracyText.color = FlxColor.CYAN;
			
			accuracyText.borderStyle = FlxTextBorderStyle.OUTLINE;
			accuracyText.borderSize = 1;
			accuracyText.font = Paths.font("vcr.ttf");
			accuracyText.visible = !ClientPrefs.hideHud && showRating;
			add(accuracyText);
		}

		//if (rating == sick)
		//	accuracyText.color = FlxColor.CYAN;
		//else if (rating == good)
		//	accuracyText.color = FlxColor.ORANGE;
		//else if (rating == bad)
		//	accuracyText.color = FlxColor.GRAY;
		//else if (rating == shit)
		//	accuracyText.color = FlxColor.BROWN;


		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		if(!ClientPrefs.comboCamera)
			comboSpr.cameras = [camHUD];
		
		comboSpr.screenCenter();
		
		if (ClientPrefs.ratingCharacter)
		{
			comboSpr.cameras = [camGame];
			onRatingOffsetCamera(note, comboSpr);
		}
		else
			comboSpr.x = coolText.x;

		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		// /////////////////////////// Combos //////////////////////////////////////////////////////////////////////
		
		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			if(statsToUse.combo >= 10000000)
				seperatedScore.push(Math.floor(statsToUse.combo / 10000000) % 10);
			if(statsToUse.combo >= 1000000)
				seperatedScore.push(Math.floor(statsToUse.combo / 1000000) % 10);
			if(statsToUse.combo >= 100000)
				seperatedScore.push(Math.floor(statsToUse.combo / 100000) % 10);
			if(statsToUse.combo >= 10000)
				seperatedScore.push(Math.floor(statsToUse.combo / 10000) % 10);
			if(statsToUse.combo >= 1000)
				seperatedScore.push(Math.floor(statsToUse.combo / 1000) % 10);
			if(statsToUse.combo >= 100)
				seperatedScore.push(Math.floor(statsToUse.combo / 100) % 10);
			if(statsToUse.combo >= 10)
				seperatedScore.push(Math.floor(statsToUse.combo / 10) % 10);
			seperatedScore.push(statsToUse.combo % 10);
		}
		else
		{
			if(combo >= 10000000)
				seperatedScore.push(Math.floor(combo / 10000000) % 10);
			if(combo >= 1000000)
				seperatedScore.push(Math.floor(combo / 1000000) % 10);
			if(combo >= 100000)
				seperatedScore.push(Math.floor(combo / 100000) % 10);
			if(combo >= 10000)
				seperatedScore.push(Math.floor(combo / 10000) % 10);
			if(combo >= 1000)
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			if(combo >= 100)
				seperatedScore.push(Math.floor(combo / 100) % 10);
			if(combo >= 10)
				seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);
		}

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));

			if (ClientPrefs.UiStates == 'Forever-Engine')
			{
				if (characterPlayingAs != 2 && characterPlayingAs != 3)
				{
					if ((ratingPercent == 1 && (!cpuControlled || !practiceMode)))
						numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'asnum' + Std.int(i) + pixelShitPart2));
					else
						numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				}
				else
				{
					if (statsToUse.fullCombo && (!cpuControlled || !practiceMode))
						numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'asnum' + Std.int(i) + pixelShitPart2));
					else
						numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				}
			}
			else
			{
				if (ClientPrefs.UiStates == 'Leather-Engine')
					numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'asnum' + Std.int(i) + pixelShitPart2));
				else
					numScore = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			}

			if(!ClientPrefs.comboCamera)
				numScore.cameras = [camHUD];

			numScore.screenCenter();
		}
			
		if (ClientPrefs.ratingCharacter)
		{
			numScore.cameras = [camGame];
			onRatingOffsetCamera(note, numScore);
			numScore.x += (43 * daLoop) - 90;
		}
		else
			numScore.x = coolText.x + (43 * daLoop) - 90;
		
		numScore.y += 80;
		numScore.x += ClientPrefs.comboOffset[2];
		numScore.y -= ClientPrefs.comboOffset[3];
		
		if (!ClientPrefs.comboStacking)
			lastScore.push(numScore);

		if (!PlayState.isPixelStage)
		{
			numScore.antialiasing = ClientPrefs.globalAntialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
		}
		else
		{
			numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
		}
		numScore.updateHitbox();

		numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
		numScore.visible = !ClientPrefs.hideHud;

		//if (combo >= 10 || combo == 0)
		if(showComboNum)
			insert(members.indexOf(strumLineNotes), numScore);

		if (accuracyTween == null)
		{
			accuracyTween = FlxTween.tween(accuracyText, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
		}
		else
		{
			accuracyText.alpha = 1;

			accuracyTween.cancel();

			accuracyTween = FlxTween.tween(accuracyText, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
		}
		
		FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				numScore.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});

		daLoop++;
		if(numScore.x > xThing) xThing = numScore.x;
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		*/

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
		
		if (ClientPrefs.UiStates == 'Leather-Engine')
			calculateAccuracy();

		if (ClientPrefs.UiStates == 'Forever-Engine')
			ForeverUpdateScoreText();
	}

	public function onRatingOffsetCamera(note:Note = null, sprite:FlxSprite = null)
	{
		var lol:Int = 0;

		if (ClientPrefs.ratingOtherCharacterCam)
		{
			if (note.opponentSing)
			{
				if (dad.otherCharacters != null)
				{
					if (DadOtherCharacterCamera <= dad.otherCharacters.length)
					{
						sprite.x = dad.otherCharacters[DadOtherCharacterCamera].getMidpoint().x + 150;
						sprite.y = dad.otherCharacters[DadOtherCharacterCamera].getMidpoint().y - 100;
						// sprite.z = dad.otherCharacters[DadOtherCharacterCamera].getMidpoint().z;
						sprite.x += dad.otherCharacters[DadOtherCharacterCamera].cameraPosition[0] + dad.otherCharacters[DadOtherCharacterCamera].ratingPosition[0] + opponentCameraOffset[0];
						sprite.y += dad.otherCharacters[DadOtherCharacterCamera].cameraPosition[1] + dad.otherCharacters[DadOtherCharacterCamera].ratingPosition[1] + opponentCameraOffset[1];
					}
					else
					{
						sprite.x = dad.otherCharacters[lol].getMidpoint().x + 150;
						sprite.y = dad.otherCharacters[lol].getMidpoint().y - 100;
						// sprite.z = dad.otherCharacters[lol].getMidpoint().z;
						sprite.x += dad.otherCharacters[lol].cameraPosition[0] + dad.otherCharacters[lol].ratingPosition[0] + opponentCameraOffset[0];
						sprite.y += dad.otherCharacters[lol].cameraPosition[1] + dad.otherCharacters[lol].ratingPosition[1] + opponentCameraOffset[1];
					}
				}
				else
				{
					if (dad != null)
					{
						sprite.x = dad.getMidpoint().x + 150;
						sprite.y = dad.getMidpoint().y - 100;
						// sprite.z = dad.getMidpoint().z;
						sprite.x -= dad.cameraPosition[0] - dad.ratingPosition[0] - opponentCameraOffset[0];
						sprite.y += dad.cameraPosition[1] + dad.ratingPosition[1] + opponentCameraOffset[1];
					}	
				}
			}
			if (!note.opponentSing)
			{
				if (boyfriend.otherCharacters != null)
				{
					if (BfOtherCharacterCamera <= boyfriend.otherCharacters.length)
					{
						sprite.x = boyfriend.otherCharacters[BfOtherCharacterCamera].getMidpoint().x - 100;
						sprite.y = boyfriend.otherCharacters[BfOtherCharacterCamera].getMidpoint().y - 100;
						// sprite.z = boyfriend.otherCharacters[BfOtherCharacterCamera].getMidpoint().z;
						sprite.x -= boyfriend.otherCharacters[BfOtherCharacterCamera].cameraPosition[0] - boyfriend.otherCharacters[BfOtherCharacterCamera].ratingPosition[0] - boyfriendCameraOffset[0];
						sprite.y += boyfriend.otherCharacters[BfOtherCharacterCamera].cameraPosition[1] + boyfriend.otherCharacters[BfOtherCharacterCamera].ratingPosition[1] + boyfriendCameraOffset[1];
					}
					else
					{
						sprite.x = boyfriend.otherCharacters[lol].getMidpoint().x - 100;
						sprite.y = boyfriend.otherCharacters[lol].getMidpoint().y - 100;
						// sprite.z = boyfriend.otherCharacters[lol].getMidpoint().z;
						sprite.x -= boyfriend.otherCharacters[lol].cameraPosition[0] - boyfriend.otherCharacters[lol].ratingPosition[0] - boyfriendCameraOffset[0];
						sprite.y += boyfriend.otherCharacters[lol].cameraPosition[1] + boyfriend.otherCharacters[lol].ratingPosition[1] + boyfriendCameraOffset[1];
					}
				}
				else
				{
					sprite.x = boyfriend.getMidpoint().x - 100;
					sprite.y = boyfriend.getMidpoint().y - 100;
					// sprite.z = boyfriend.getMidpoint().z;
					sprite.x -= boyfriend.cameraPosition[0] - boyfriend.ratingPosition[0] - boyfriendCameraOffset[0];
					sprite.y += boyfriend.cameraPosition[1] + boyfriend.ratingPosition[1] + boyfriendCameraOffset[1];
				}
			}
		}
		else
		{
			if (note.opponentSing)
			{
				if (dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
				{
					if (note.characters.length <= 1)
					{
						sprite.x = dad.otherCharacters[note.character].getMidpoint().x + 150;
						sprite.y = dad.otherCharacters[note.character].getMidpoint().y - 100;
						// sprite.z = dad.otherCharacters[note.character].getMidpoint().z;
						sprite.x += dad.otherCharacters[note.character].cameraPosition[0] + dad.otherCharacters[note.character].ratingPosition[0] + opponentCameraOffset[0];
						sprite.y += dad.otherCharacters[note.character].cameraPosition[1] + dad.otherCharacters[note.character].ratingPosition[1] + opponentCameraOffset[1];
					}
					else
					{
						for (character in note.characters)
						{
							if (dad.otherCharacters.length - 1 >= character)
							{								
								sprite.x = dad.otherCharacters[character].getMidpoint().x + 150;
								sprite.y = dad.otherCharacters[character].getMidpoint().y - 100;
								// sprite.z = dad.otherCharacters[character].getMidpoint().z;
								sprite.x += dad.otherCharacters[character].cameraPosition[0] + dad.otherCharacters[character].ratingPosition[0] + opponentCameraOffset[0];
								sprite.y += dad.otherCharacters[character].cameraPosition[1] + dad.otherCharacters[character].ratingPosition[1] + opponentCameraOffset[1];
							}
						}
					}
				}
				else
				{
					if (dad != null)
					{
						sprite.x = dad.getMidpoint().x + 150;
						sprite.y = dad.getMidpoint().y - 100;
						// sprite.z = dad.getMidpoint().z;
						sprite.x -= dad.cameraPosition[0] - dad.ratingPosition[0] - opponentCameraOffset[0];
						sprite.y += dad.cameraPosition[1] + dad.ratingPosition[1] + opponentCameraOffset[1];
					}
				}
			}
			if (!note.opponentSing)
			{
				if (boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
				{
					if (note.characters.length <= 1)
					{
						sprite.x = boyfriend.otherCharacters[note.character].getMidpoint().x - 100;
						sprite.y = boyfriend.otherCharacters[note.character].getMidpoint().y - 100;
						// sprite.z = boyfriend.otherCharacters[note.character].getMidpoint().z;
						sprite.x -= boyfriend.otherCharacters[note.character].cameraPosition[0] - boyfriend.otherCharacters[note.character].ratingPosition[0] - boyfriendCameraOffset[0];
						sprite.y += boyfriend.otherCharacters[note.character].cameraPosition[1] + boyfriend.otherCharacters[note.character].ratingPosition[1] + boyfriendCameraOffset[1];
					}
					else
					{
						for (character in note.characters)
						{
							if (boyfriend.otherCharacters.length - 1 >= character)
							{								
								sprite.x = boyfriend.otherCharacters[character].getMidpoint().x - 100;
								sprite.y = boyfriend.otherCharacters[character].getMidpoint().y - 100;
								// sprite.z = boyfriend.otherCharacters[character].getMidpoint().z;
								sprite.x -= boyfriend.otherCharacters[character].cameraPosition[0] - boyfriend.otherCharacters[character].ratingPosition[0] - boyfriendCameraOffset[0];
								sprite.y += boyfriend.otherCharacters[character].cameraPosition[1] + boyfriend.otherCharacters[character].ratingPosition[1] + boyfriendCameraOffset[1];
							}
						}
					}
				}
				else
				{
					if (boyfriend != null)
					{
						sprite.x = boyfriend.getMidpoint().x - 100;
						sprite.y = boyfriend.getMidpoint().y - 100;
						// sprite.z = boyfriend.getMidpoint().z;
						sprite.x -= boyfriend.cameraPosition[0] - boyfriend.ratingPosition[0] - boyfriendCameraOffset[0];
						sprite.y += boyfriend.cameraPosition[1] + boyfriend.ratingPosition[1] + boyfriendCameraOffset[1];
					}
				}
			}
		}
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (/* strumsBlocked[daNote.noteData] != true && */daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
							canMiss = ClientPrefs.antimash;
						}
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					callOnHaxes('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
			callOnHaxes('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	public var dadstrumsBlocked:Array<Bool> = [];
	private function ondadKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getdadKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
		{
			if(!dad.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
							canMiss = ClientPrefs.antimash;
						}
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							DadNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('ondadGhostTap', [key]);
					callOnHaxes('ondadGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key, 2);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums1.members[key];
			if(dadstrumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('ondadKeyPress', [key]);
			callOnHaxes('ondadKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	
	private function onbfKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getbfKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (/* strumsBlocked[daNote.noteData] != true && */daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
							canMiss = ClientPrefs.antimash;
						}
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onbfGhostTap', [key]);
					callOnHaxes('onbfGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key, 1);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums2.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onbfKeyPress', [key]);
			callOnHaxes('onbfKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			callOnLuas('onKeyRelease', [key]);
			callOnHaxes('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function ondadKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getdadKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums1.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			callOnLuas('ondadKeyRelease', [key]);
			callOnHaxes('ondadKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function onbfKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getbfKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums2.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			callOnLuas('onbfKeyRelease', [key]);
			callOnHaxes('onbfKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}
	
	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray[mania].length)
			{
				for (j in 0...keysArray[mania][i].length)
				{
					if(key == keysArray[mania][i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}
	
	private function getdadKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...dadkeysArray[mania].length)
			{
				for (j in 0...dadkeysArray[mania][i].length)
				{
					if(key == dadkeysArray[mania][i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}
	
	private function getbfKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...bfkeysArray[mania].length)
			{
				for (j in 0...bfkeysArray[mania][i].length)
				{
					if(key == bfkeysArray[mania][i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keysArePressed():Bool
	{
		for (i in 0...keysArray[mania].length) {
			for (j in 0...keysArray[mania][i].length) {
				if (FlxG.keys.checkStatus(keysArray[mania][i][j], PRESSED)) return true;
			}
		}
	
		return false;
	}

	private function dadkeysArePressed():Bool
	{
		for (i in 0...dadkeysArray[mania].length) {
			for (j in 0...dadkeysArray[mania][i].length) {
				if (FlxG.keys.checkStatus(dadkeysArray[mania][i][j], PRESSED)) return true;
			}
		}
	
		return false;
	}

	private function bfkeysArePressed():Bool
	{
		for (i in 0...bfkeysArray[mania].length) {
			for (j in 0...bfkeysArray[mania][i].length) {
				if (FlxG.keys.checkStatus(bfkeysArray[mania][i][j], PRESSED)) return true;
			}
		}
	
		return false;
	}
	
	private function dataKeyIsPressed(data:Int):Bool
	{
		for (i in 0...keysArray[mania][data%keysArray[mania].length].length) {
			if (FlxG.keys.checkStatus(keysArray[mania][data%keysArray[mania].length][i], PRESSED)) return true;
		}

		return false;
	}
	
	private function databfKeyIsPressed(data:Int):Bool
	{
		for (i in 0...bfkeysArray[mania][data%bfkeysArray[mania].length].length) {
			if (FlxG.keys.checkStatus(bfkeysArray[mania][data%bfkeysArray[mania].length][i], PRESSED)) return true;
		}

		return false;
	}
	
	private function datadadKeyIsPressed(data:Int):Bool
	{
		for (i in 0...dadkeysArray[mania][data%dadkeysArray[mania].length].length) {
			if (FlxG.keys.checkStatus(dadkeysArray[mania][data%dadkeysArray[mania].length][i], PRESSED)) return true;
		}

		return false;
	}

	private function dadkeyShit():Void
	{
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !dad.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && datadadKeyIsPressed(daNote.noteData)
				&& daNote.canBeHit && !daNote.mustPress && !daNote.tooLate 
				&& !daNote.wasGoodHit && !daNote.blockHit) {
					DadNoteHit(daNote);
				}
			});

			if (dadkeysArePressed() && !endingSong) {
			}
			else
			{
				if (dad.otherCharacters == null)
				{
					if (dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
						dad.dance();
				}
				else
				{
					for(character in dad.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
							character.dance();
					}
				}
			}
		}
	}

	private function bfkeyShit():Void
	{
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				/*
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && dataKeyIsPressed(daNote.noteData) && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
				*/
				// hold note functions
				if (daNote.isSustainNote && databfKeyIsPressed(daNote.noteData)
				&& daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
				&& !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (bfkeysArePressed() && !endingSong) {
			}
			else
			{
				if (boyfriend.otherCharacters == null)
				{
					if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
				else
				{
					for(character in boyfriend.otherCharacters)
					{
						if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
							character.dance();
					}
				}
			}
		}
	}

	private function keyShit():Void
	{
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				/*
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && dataKeyIsPressed(daNote.noteData) && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
				*/
				// hold note functions
				if (daNote.isSustainNote && dataKeyIsPressed(daNote.noteData)
				&& daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
				&& !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (keysArePressed() && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else
			{
				if (characterPlayingAs == 0)
				{
					if (boyfriend.otherCharacters == null)
					{
						if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
							boyfriend.dance();
					}
					else
					{
						for(character in boyfriend.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
								character.dance();
						}
					}
					/*
					if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.dance();
						//boyfriend.animation.curAnim.finish();
					}
					*/
				}
				if (characterPlayingAs == 1)
				{
					if (dad.otherCharacters == null)
					{
						if (dad.holdTimer > Conductor.stepCrochet * 0.0011 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
							dad.dance();
					}
					else
					{
						for(character in dad.otherCharacters)
						{
							if(character.holdTimer > Conductor.stepCrochet * 0.0011 * character.singDuration && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
								character.dance();
						}
					}
				}
			}
		}
	}

	function noteMiss(daNote:Note, playernum:Int = 1):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		if (!daNote.isSustainNote)
			Notelength -= 1;

		var statsToUse = getStats(playernum);
		
		if (characterPlayingAs == 1 || characterPlayingAs == -1 || characterPlayingAs == -2)
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;

		notes.forEachAlive(function(note:Note) {
			//if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
			if (daNote != note && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			combo = 0;
			
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				health -= daNote.missHealth * healthLoss;
			else
			{
				if (daNote.opponentSing)
					dadhealth -= daNote.missHealth * healthLoss;
				if (!daNote.opponentSing)
					bfhealth -= daNote.missHealth * healthLoss;
			}
			if (daNote.opponentSing)
				dadvocals.volume = 0;
			if (!daNote.opponentSing)
				boyfriendvocals.volume = 0;
			
			songMisses++;
		}
		else
		{
			statsToUse.combo = 0;
			statsToUse.misses++;
			if (daNote.opponentSing)
			{
				dadcombo = 0;
				if (characterPlayingAs == 3)
					dadhealth -= daNote.missHealth * healthLoss;
				else
					health += daNote.missHealth * healthLoss;
				dadvocals.volume = 0;
			}
			if (!daNote.opponentSing)
			{
				if (characterPlayingAs == 3)
					bfhealth -= daNote.missHealth * healthLoss;
				else
					health -= daNote.missHealth * healthLoss;
				boyfriendvocals.volume = 0;
			}
			statsToUse.totalNotesHit++; //not actually missing, just for working out the accuracy
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			if (daNote.opponentSing)
				dadvocals.volume = 0;
			if (!daNote.opponentSing)
				boyfriendvocals.volume = 0;
				
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		vocals.volume = 0;
		
		if(!practiceMode)
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
				songScore -= 10;
			else
				statsToUse.songScore -= 10;
		
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
			totalPlayed++;
		else
			statsToUse.totalPlayed++;

		RecalculateRating(true);
		if (characterPlayingAs == 2 || characterPlayingAs == 3)
			MultiCalculateAccuracy(playernum);

		if (ClientPrefs.UiStates == 'Leather-Engine' && ClientPrefs.sideRatings)
			updateRatingText();

		if (ClientPrefs.UiStates == 'Leather-Engine')
			calculateAccuracy();
		
		if (ClientPrefs.UiStates == 'Forever-Engine')
			ForeverUpdateScoreText();

		totalNotes++;

		/*
		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[daNote.noteData] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
		*/
		var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[daNote.noteData] + 'miss' + daNote.animSuffix;
		
		if(daNote.gfNote && gf != null && !daNote.noMissAnimation && gf.hasMissAnimations)
			gf.playAnim(animToPlay, true);

		if (daNote.opponentSing)
		{
			if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < daNote.character))
			{
				if (daNote.characters.length <= 1)
					if (dad.otherCharacters[daNote.character].animation.getByName(animToPlay) != null)
						dad.otherCharacters[daNote.character].playAnim(animToPlay, true);
				else
				{
					for (character in daNote.characters)
					{
						if (dad.otherCharacters.length - 1 >= character)
							if (dad.otherCharacters[character].animation.getByName(animToPlay) != null)
								dad.otherCharacters[character].playAnim(animToPlay, true);
					}
				}
			}
			else
				if (dad != null  && !daNote.noMissAnimation && dad.hasMissAnimations && dad.animation.getByName(animToPlay) != null)
					dad.playAnim(animToPlay, true);
		}
		if (!daNote.opponentSing)
		{
			if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < daNote.character))
			{
				if (daNote.characters.length <= 1)
					if (boyfriend.otherCharacters[daNote.character].animation.getByName(animToPlay) != null)
						boyfriend.otherCharacters[daNote.character].playAnim(animToPlay, true);
				else
				{
					for (character in daNote.characters)
					{
						if (boyfriend.otherCharacters.length - 1 >= character)
							if (boyfriend.otherCharacters[character].animation.getByName(animToPlay) != null)
								boyfriend.otherCharacters[character].playAnim(animToPlay, true);
					}
				}
			}
			else
				if (boyfriend != null  && !daNote.noMissAnimation && boyfriend.hasMissAnimations)
					boyfriend.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		callOnHaxes('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1, playernum:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		var statsToUse = getStats(playernum);
		if (characterPlayingAs == 1 || characterPlayingAs == -1 || characterPlayingAs == -2)
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;
		
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				health -= 0.05 * healthLoss;
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.opponentSing)
						dadhealth -= 0.05 * healthLoss;
					if (!daNote.opponentSing)
						bfhealth -= 0.05 * healthLoss;
				});
			}
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				
				if (characterPlayingAs == 0)
					boyfriendvocals.volume = 0;
				if (characterPlayingAs == 1)
					dadvocals.volume = 0;

				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				combo = 0;
			else
				statsToUse.combo = 0;

			if(!practiceMode)
				if (characterPlayingAs != -2 && characterPlayingAs != 3)
					songScore -= 10;
				else
					statsToUse.songScore -= 10;

			if(!endingSong) {
				if (characterPlayingAs != -2 && characterPlayingAs != 3)
					songMisses++;
				else
					statsToUse.misses++;
			}
			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				totalPlayed++;
			else
				statsToUse.totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[direction] + 'miss';
		
			/*
			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim('sing' + Note.keysShit.get(mania).get('anims')[direction] + 'miss', true);
			}
			*/
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.opponentSing)
				{
					if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < daNote.character))
					{
						if (daNote.characters.length <= 1)
							if (dad.otherCharacters[daNote.character].animation.getByName(animToPlay) != null)
								dad.otherCharacters[daNote.character].playAnim(animToPlay, true);
						else
						{
							for (character in daNote.characters)
							{
								if (dad.otherCharacters.length - 1 >= character)
									if (dad.otherCharacters[character].animation.getByName(animToPlay) != null)
										dad.otherCharacters[character].playAnim(animToPlay, true);
							}
						}
					}
					else
						if (dad != null  && !daNote.noMissAnimation && dad.hasMissAnimations && dad.animation.getByName(animToPlay) != null)
							dad.playAnim(animToPlay, true);

					dadvocals.volume = 0;
				}
				if (!daNote.opponentSing)
				{
					if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < daNote.character))
					{
						if (daNote.characters.length <= 1)
							if (boyfriend.otherCharacters[daNote.character].animation.getByName(animToPlay) != null)
								boyfriend.otherCharacters[daNote.character].playAnim(animToPlay, true);
						else
						{
							for (character in daNote.characters)
							{
								if (boyfriend.otherCharacters.length - 1 >= character)
									if (boyfriend.otherCharacters[character].animation.getByName(animToPlay) != null)
										boyfriend.otherCharacters[character].playAnim(animToPlay, true);
							}
						}
					}
					else
						if (boyfriend != null  && !daNote.noMissAnimation && boyfriend.hasMissAnimations)
							boyfriend.playAnim(animToPlay, true);
					
					boyfriendvocals.volume = 0;
				}
			});
				vocals.volume = 0;
			}
		callOnLuas('noteMissPress', [direction]);
		callOnHaxes('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (characterPlayingAs <= 0)
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;

		if(note.ignoreNote || note.hitCausesMiss) return;
		
		if(!note.noteSplashDisabled && !note.isSustainNote)
		{
			spawnNoteSplashDadOnNote(note);
		}

		if (note.noAnimation)
		{
			if(note.opponentSing)
			{
				if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
				{
					if(note.characters.length <= 0)
						callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
					else
						for(character in note.characters)
							if(dad.otherCharacters.length - 1 >= character)
								callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
				}
				else
					callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
				callOnHaxes('opponentNoteHit', [note]);
			}
			if (!note.opponentSing)
			{
				if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
				{
					if(note.characters.length <= 1)
							callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
					else
						for(character in note.characters)
							if(boyfriend.otherCharacters.length - 1 >= character)
								callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
				}
				else
					callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
				callOnHaxes('goodNoteHit', [note]);
			}
		}

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			/*
			var char:Character = dad;
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
			*/
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData] + altAnim;
			
			if(note.gfNote) {
				gf.playAnim(animToPlay, true);
				gf.holdTimer = 0;
				callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);	
				callOnHaxes('opponentNoteHit', [note]);
			}
			if (!note.gfNote)
			{
				if(note.opponentSing)
				{
					if (dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
					{
						if (note.characters.length <= 1)
						{
							dad.otherCharacters[note.character].playAnim(animToPlay, true);
							dad.otherCharacters[note.character].holdTimer = 0;
							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						}
						else
						{
							for (character in note.characters)
							{
								if (dad.otherCharacters.length - 1 >= character)
								{								
									dad.otherCharacters[character].playAnim(animToPlay, true);
									dad.otherCharacters[character].holdTimer = 0;
									callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
								}
							}
						}
					}
					else
					{
						if (dad != null)
						{
							dad.playAnim(animToPlay, true);
							dad.holdTimer = 0;
							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);	
						}						
					}
					callOnHaxes('opponentNoteHit', [note]);
				}
				if(!note.opponentSing)
				{
					if (boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
					{
						if (note.characters.length <= 1)
						{
							boyfriend.otherCharacters[note.character].playAnim(animToPlay, true);
							boyfriend.otherCharacters[note.character].holdTimer = 0;
							callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						}
						else
						{
							for (character in note.characters)
							{
								if (boyfriend.otherCharacters.length - 1 >= character)
								{								
									boyfriend.otherCharacters[character].playAnim(animToPlay, true);
									boyfriend.otherCharacters[character].holdTimer = 0;	
									callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
								}
							}
						}
					}
					else
					{
						if(boyfriend != null)
						{
							boyfriend.playAnim(animToPlay, true);
							boyfriend.holdTimer = 0;
							callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);		
						}						
					}
					callOnHaxes('goodNoteHit', [note]);
				}
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

			if(note.opponentSing)
				if (SONG.needsDadVoices)
					dadvocals.volume = 1;

			if(!note.opponentSing)
				if (SONG.needsBfVoices)
					boyfriendvocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
		note.hitByOpponent = true;

		//callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.isSustainNote)
			Notelength -= 1;

		if (characterPlayingAs == 1 || characterPlayingAs == -1 || characterPlayingAs == -2)
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;
			
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (!note.isSustainNote)
				totalNotes++;

			if (ClientPrefs.UiStates == 'Leather-Engine')
				calculateAccuracy();

			if (ClientPrefs.UiStates == 'Forever-Engine')
				ForeverUpdateScoreText();

			if(note.hitCausesMiss) {
				noteMiss(note, 1);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType)
					{
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) 
							{
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}

						case 'Latex Note': //Changed Mod SpaceBar Note
							if(!boyfriend.stunned)
							{
								if(!endingSong)
								{
									RecalculateRating();
									if(!note.isSustainNote) {
										//spaceAmount += FlxG.random.int(4, 10);
										spaceAmount += spaceAmountNum;
										FlxG.sound.play(Paths.sound('goopSound'));
										//spawnNoteSplashOnNote(note);
			
										if(boyfriend.latexed != true){
											boyfriend.latexed = true;
											spaceTimer.reset(spaceTimerDefault);
											spaceTimer.active == true;
										}
									}
			
									//spawnNoteSplashOnNote(note);
									if(boyfriend.animation.getByName('hurt') != null) {
										boyfriend.playAnim('hurt', true);
										boyfriend.specialAnim = true;
									}
								}
								vocals.volume = 0;

								if (characterPlayingAs == 0)
									boyfriendvocals.volume = 0;
								if (characterPlayingAs == 1)
									dadvocals.volume = 0;
							}
						case 'Liza Note': //Red Mod Fire Note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
							songScore -= -150;
							camGame.flash(FlxColor.ORANGE, 0.6);
							FlxG.sound.play(Paths.sound('Flame'));
							FlxG.camera.shake(0.1,0.1);
							camHUD.shake(0.1,0.1);
						case 'Pika Note': //Red Mod Light Note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
							songScore -= -150;
							camGame.flash(FlxColor.YELLOW, 0.6);
							FlxG.sound.play(Paths.sound('Thunder'));
							FlxG.camera.shake(0.1,0.1);
							camHUD.shake(0.1,0.1);
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}
			/*
			if (ClientPrefs.UiStates == 'Forever-Engine')
			{
				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				if (note.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!note.isSustainNote)
				{
					combo += 1;
					//if(combo > 9999) combo = 9999;
					popUpScore(note, note.strumTime, ratingTiming, foundRating);
				}
			}
			else
			{
			}
			*/
			
			if (!note.isSustainNote)
			{
				if (characterPlayingAs == 2 || characterPlayingAs == 3)
				{
					var statsToUse = getStats(1);
					statsToUse.combo += 1;
					if (statsToUse.combo > statsToUse.highestCombo)
						statsToUse.highestCombo = statsToUse.combo;
				}
				else
					combo += 1;
				//if(combo > 9999) combo = 9999;
				popUpScore(note, note.strumTime, false, 1);
			}
			else
			{
				if (characterPlayingAs == 2 || characterPlayingAs == 3)
				{
					var statsToUse = getStats(1);
					statsToUse.sustainsHit++; //give acc from sustains
					statsToUse.totalNotesHit++;
				}
			}
			if (characterPlayingAs == 2 || characterPlayingAs == 3)
				MultiCalculateAccuracy(1);

			if (characterPlayingAs != -2 && characterPlayingAs != 3)
				health += note.hitHealth * healthGain;
			else
			{
				if (note.opponentSing)
					dadhealth += note.hitHealth * healthGain;
				if (!note.opponentSing)
					bfhealth += note.hitHealth * healthGain;
			}
			
			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (note.noAnimation)
			{
				if(note.opponentSing)
				{
					if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
					{
						if(note.characters.length <= 0)
							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						else
							for(character in note.characters)
								if(dad.otherCharacters.length - 1 >= character)
									callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
					}
					else
						callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
					callOnHaxes('opponentNoteHit', [note]);
				}
				if (!note.opponentSing)
				{
					if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
					{
						if(note.characters.length <= 1)
								callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						else
							for(character in note.characters)
								if(boyfriend.otherCharacters.length - 1 >= character)
									callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
					}
					else
						callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
					callOnHaxes('goodNoteHit', [note]);
				}
			}

			if(!note.noAnimation) {
				var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (note.opponentSing)
					{
						if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
						{
							if(note.characters.length <= 0)
							{
								dad.otherCharacters[note.character].playAnim(animToPlay + note.animSuffix, true);
								dad.otherCharacters[note.character].holdTimer = 0;

								callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note.character]);
							}
							else
							{
								for(character in note.characters)
								{
									if(dad.otherCharacters.length - 1 >= character)
									{
										dad.otherCharacters[character].playAnim(animToPlay + note.animSuffix, true);
										dad.otherCharacters[character].holdTimer = 0;

										callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus, character]);
									}
								}
							}
						}
						else
						{
							dad.playAnim(animToPlay + note.animSuffix, true);
							dad.holdTimer = 0;

							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
						}
						callOnHaxes('opponentNoteHit', [note]);
					}
					if (!note.opponentSing)
					{
						if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
							if(note.characters.length <= 1)
								{
									boyfriend.otherCharacters[note.character].playAnim(animToPlay + note.animSuffix, true);	
									boyfriend.otherCharacters[note.character].holdTimer = 0;
	
									callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note.character]);						
								}
							else
							{
								for(character in note.characters)
								{
									if(boyfriend.otherCharacters.length - 1 >= character)
										{
											boyfriend.otherCharacters[character].playAnim(animToPlay + note.animSuffix, true);											
											boyfriend.otherCharacters[character].holdTimer = 0;
	
											callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus, character]);
										}
								}
							}
						else
						{
							boyfriend.playAnim(animToPlay + note.animSuffix, true);
							boyfriend.holdTimer = 0;
	
							callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);		
						}
						callOnHaxes('goodNoteHit', [note]);
					}
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				} 
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
			} else {
				var spr:StrumNote = null;
				if (characterPlayingAs != 2 && characterPlayingAs != 3)
					spr = playerStrums.members[note.noteData];
				else
					spr = playerStrums2.members[note.noteData];

				if(spr != null)	
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;
			
			if (note.opponentSing)
				if (SONG.needsDadVoices)
					dadvocals.volume = 1;
			if (!note.opponentSing)
				if (SONG.needsBfVoices)
					boyfriendvocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}
	
	function DadNoteHit(note:Note):Void
	{
		if (!note.isSustainNote)
			Notelength -= 1;

		if (characterPlayingAs == 1 || characterPlayingAs == -1 || characterPlayingAs == -2)
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;
			
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (!note.isSustainNote)
				totalNotes++;

			if (ClientPrefs.UiStates == 'Leather-Engine')
				calculateAccuracy();

			if (ClientPrefs.UiStates == 'Forever-Engine')
				ForeverUpdateScoreText();

			if(note.hitCausesMiss) {
				noteMiss(note, 2);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashDadOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType)
					{
						case 'Hurt Note': //Hurt note
							if(dad.animation.getByName('hurt') != null) 
							{
								dad.playAnim('hurt', true);
								dad.specialAnim = true;
							}

						case 'Latex Note': //Changed Mod SpaceBar Note
							if(!dad.stunned)
							{
								if(!endingSong)
								{
									RecalculateRating();
									if(!note.isSustainNote) {
										//spaceAmount += FlxG.random.int(4, 10);
										spaceAmount += spaceAmountNum;
										FlxG.sound.play(Paths.sound('goopSound'));
										//spawnNoteSplashOnNote(note);
			
										if(dad.latexed != true){
											dad.latexed = true;
											spaceTimer.reset(spaceTimerDefault);
											spaceTimer.active == true;
										}
									}
			
									//spawnNoteSplashOnNote(note);
									if(boyfriend.animation.getByName('hurt') != null) {
										boyfriend.playAnim('hurt', true);
										boyfriend.specialAnim = true;
									}
								}
								vocals.volume = 0;

								if (characterPlayingAs == 0)
									boyfriendvocals.volume = 0;
								if (characterPlayingAs == 1)
									dadvocals.volume = 0;
							}
						case 'Liza Note': //Red Mod Fire Note
							if(dad.animation.getByName('hurt') != null) {
								dad.playAnim('hurt', true);
								dad.specialAnim = true;
							}
							songScore -= -150;
							camGame.flash(FlxColor.ORANGE, 0.6);
							FlxG.sound.play(Paths.sound('Flame'));
							FlxG.camera.shake(0.1,0.1);
							camHUD.shake(0.1,0.1);
						case 'Pika Note': //Red Mod Light Note
							if(dad.animation.getByName('hurt') != null) {
								dad.playAnim('hurt', true);
								dad.specialAnim = true;
							}
							songScore -= -150;
							camGame.flash(FlxColor.YELLOW, 0.6);
							FlxG.sound.play(Paths.sound('Thunder'));
							FlxG.camera.shake(0.1,0.1);
							camHUD.shake(0.1,0.1);
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}
			if (!note.isSustainNote)
			{
				if (characterPlayingAs == 2 || characterPlayingAs == 3)
				{
					var statsToUse = getStats(2);
					statsToUse.combo += 1;
					if (statsToUse.combo > statsToUse.highestCombo)
						statsToUse.highestCombo = statsToUse.combo;
					popUpScore(note, note.strumTime, true, 2);
				}
			}
			else
			{
				if (characterPlayingAs == 2 || characterPlayingAs == 3)
				{
					var statsToUse = getStats(1);
					statsToUse.sustainsHit++; //give acc from sustains
					statsToUse.totalNotesHit++;
				}
			}
			MultiCalculateAccuracy(2);

			if (characterPlayingAs == 2)
				health -= note.hitHealth * healthGain;
			else
			{
				if (note.opponentSing)
					dadhealth += note.hitHealth * healthGain;
				if (!note.opponentSing)
					bfhealth += note.hitHealth * healthGain;
			}

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (note.noAnimation)
			{
				if(note.opponentSing)
				{
					if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
					{
						if(note.characters.length <= 0)
							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						else
							for(character in note.characters)
								if(dad.otherCharacters.length - 1 >= character)
									callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
					}
					else
						callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
					callOnHaxes('opponentNoteHit', [note]);
				}
				if (!note.opponentSing)
				{
					if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
					{
						if(note.characters.length <= 1)
								callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.character]);
						else
							for(character in note.characters)
								if(boyfriend.otherCharacters.length - 1 >= character)
									callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, character]);
					}
					else
						callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
					callOnHaxes('goodNoteHit', [note]);
				}
			}

			if(!note.noAnimation) {
				var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (note.opponentSing)
					{
						if(dad.otherCharacters != null && !(dad.otherCharacters.length - 1 < note.character))
						{
							if(note.characters.length <= 0)
							{
								dad.otherCharacters[note.character].playAnim(animToPlay + note.animSuffix, true);
								dad.otherCharacters[note.character].holdTimer = 0;

								callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note.character]);
							}
							else
							{
								for(character in note.characters)
								{
									if(dad.otherCharacters.length - 1 >= character)
									{
										dad.otherCharacters[character].playAnim(animToPlay + note.animSuffix, true);
										dad.otherCharacters[character].holdTimer = 0;

										callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus, character]);
									}
								}
							}
						}
						else
						{
							dad.playAnim(animToPlay + note.animSuffix, true);
							dad.holdTimer = 0;

							callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
						}
						callOnHaxes('opponentNoteHit', [note]);
					}
					if (!note.opponentSing)
					{
						if(boyfriend.otherCharacters != null && !(boyfriend.otherCharacters.length - 1 < note.character))
							if(note.characters.length <= 1)
								{
									boyfriend.otherCharacters[note.character].playAnim(animToPlay + note.animSuffix, true);	
									boyfriend.otherCharacters[note.character].holdTimer = 0;
	
									callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus, note.character]);						
								}
							else
							{
								for(character in note.characters)
								{
									if(boyfriend.otherCharacters.length - 1 >= character)
										{
											boyfriend.otherCharacters[character].playAnim(animToPlay + note.animSuffix, true);											
											boyfriend.otherCharacters[character].holdTimer = 0;
	
											callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus, character]);
										}
								}
							}
						else
						{
							boyfriend.playAnim(animToPlay + note.animSuffix, true);
							boyfriend.holdTimer = 0;
	
							callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);		
						}
						callOnHaxes('goodNoteHit', [note]);
					}
				}

				if(note.noteType == 'Hey!') {
					if(dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				} 
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
			} else {
				var spr:StrumNote = playerStrums1.members[note.noteData];
				if(spr != null)	
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;
			
			if (note.opponentSing)
				if (SONG.needsDadVoices)
					dadvocals.volume = 1;
			if (!note.opponentSing)
				if (SONG.needsBfVoices)
					boyfriendvocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashDadOnNote(note:Note) {
		if(ClientPrefs.OpponentnoteSplashes && ClientPrefs.opponentStrums && note != null) {
			var strum:StrumNote = null;
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
				strum = opponentStrums.members[note.noteData];
			else
				strum = playerStrums1.members[note.noteData];

			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = null;
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
				strum = playerStrums.members[note.noteData];
			else
				strum = playerStrums2.members[note.noteData];

			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;

		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			if (Note.ammo[mania] <= 11)
			{
				hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][0] / 360;
				sat = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][1] / 100;
				brt = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][2] / 100;
			}
			else
			{
				hue = 0;
				sat = 0;
				brt = 0;
			}
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		for (hx in haxeArray) {
			hx.runFunc('destroy', []);
			hx.destroy();
		} 
		luaArray = [];
		haxeArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, ondadKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, ondadKeyRelease);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onbfKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onbfKeyRelease);
		}
		else
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;

		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate))
		|| (SONG.needsDadVoices && Math.abs(dadvocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate))
		|| (SONG.needsBfVoices && Math.abs(boyfriendvocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
		callOnHaxes('stepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		lDance = !lDance; // true > false; false > true
		/*
			Actually i could make this ^^^ by using
			if (lDance) {
				lDance = false;
			} else {
				lDance = true;
			}
			But this one is literally easier.
		*/

		// booping heads. Actually inspired by vs Cassette Girl mod
		if (ClientPrefs.iconbops == "Cassette") {
			if (lDance){
				iconP1.angle = 8; iconP2.angle = 8; // maybe i should do it with tweens, but i'm lazy // i'll make it in -1.0.0, i promise
			} else { 
				iconP1.angle = -8; iconP2.angle = -8;
			}
		}
		if (ClientPrefs.iconbops == "Golden Apple")
		{
			if (lDance){
				iconP1.scale.set(1.4, 1);
				iconP2.scale.set(1.4, 1.6);

				FlxTween.angle(iconP1, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			} else { 
				iconP1.scale.set(1.4, 1.6);
				iconP2.scale.set(1.4, 1);

				FlxTween.angle(iconP2, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			}
			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
		}
			
		if (ClientPrefs.iconbops == "Bambi") {
		var funny:Float = (healthBar.percent * 0.01) + 0.01;
			if (lDance){
				iconP1.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP1.height - (25 * funny)));
				iconP2.setGraphicSize(Std.int(iconP2.width + (50 * (2 - funny))),Std.int(iconP2.height - (25 * (2 - funny))));
			} else { 
				iconP1.setGraphicSize(Std.int(iconP2.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
				iconP2.setGraphicSize(Std.int(iconP1.width + (50 * (2 - funny))),Std.int(iconP1.height - (25 * (2 - funny))));
			}
		}
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (boyfriend.otherCharacters == null)
		{
			if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				boyfriend.dance();
		}
		else
		{
			for (character in boyfriend.otherCharacters)
				if (curBeat % character.danceEveryNumBeats == 0 && character.animation.curAnim != null && !character.animation.curAnim.name.startsWith('sing') && !character.stunned)
					character.dance();
		}
		if (dad.otherCharacters == null)
		{
			if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();
		}
		else
		{
			for (character in dad.otherCharacters)
				if (curBeat % character.danceEveryNumBeats == 0 && character.animation.curAnim != null && !character.animation.curAnim.name.startsWith('sing'))
					character.dance();
		}
		/*
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') &&)
		{
			dad.dance();
		}
		*/

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
		callOnHaxes('beatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
		callOnHaxes('sectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function callOnHaxes(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		var returnArray:Array<Dynamic> = [];
		#if hscript
		if(exclusions == null) exclusions = [];
		for (script in haxeArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.runFunc(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool) {
				returnVal = cast ret;
			}
			returnArray.push(returnVal);
		}
		#end
		//trace(event, returnVal);
		if (returnArray.contains(FunkinLua.Function_Stop)) return FunkinLua.Function_Stop;
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
		#if hscript
		setOnHaxes(variable, arg);
		#end
	}

	public function setOnHaxes(variable:String, arg:Dynamic) {
		#if hscript
		for (i in haxeArray) {
			i.set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			if(isDad) {
				spr = opponentStrums.members[id];
			} else {
				spr = playerStrums.members[id];
			}
		}
		else
		{
			if(isDad) {
				spr = playerStrums1.members[id];
			} else {
				spr = playerStrums2.members[id];
			}
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}
	function ForeverUpdateRatingText()
	{
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			ratingText.text = 
			"Sick: "
			+ Std.string(sicks)
			+ "\n"
			+ "Good: "
			+ Std.string(goods)
			+ "\n"
			+ "Bad: "
			+ Std.string(bads)
			+ "\n"
			+ "Shit: "
			+ Std.string(shits)
			+ "\n"
			+ "Miss: "
			+ Std.string(songMisses)
			+ "\n";
		}
		else
		{
			ratingText.text = '\n';
		}
		/*
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		else
			ratingText.text = 
			"Dad Side"
			+ "\n"
			+ "Sick: "
			+ Std.string(p1Ratings[1])
			+ "\n"
			+ "Good: "
			+ Std.string(p1Ratings[2])
			+ "\n"
			+ "Bad: "
			+ Std.string(p1Ratings[3])
			+ "\n"
			+ "Shit: "
			+ Std.string(p1Ratings[4])
			+ "\n"
			+ "Miss: "
			+ Std.string(p1Ratings[5])
			+"\nBf Side"
			+ "\n"
			+ "Sick: "
			+ Std.string(p2Ratings[1])
			+ "\n"
			+ "Good: "
			+ Std.string(p2Ratings[2])
			+ "\n"
			+ "Bad: "
			+ Std.string(p2Ratings[3])
			+ "\n"
			+ "Shit: "
			+ Std.string(p2Ratings[4])
			+ "\n"
			+ "Miss: "
			+ Std.string(p2Ratings[5])
			+ "\n";
		*/
	}

	function updateRatingText()
	{
		ratingText.text = returnStupidRatingText();
		ratingText.screenCenter(Y);
	}

	public function returnStupidRatingText(?end:Bool = false):String
	{
		if (!end)
		{
			var ratingArray = [
				marvelous,
				sicks,
				goods,
				bads,
				shits
			];
	
			var MA = ratingArray[1] + ratingArray[2] + ratingArray[3] + ratingArray[4];
			var PA = ratingArray[2] + ratingArray[3] + ratingArray[4];
	
			return (
				((ClientPrefs.MarvelouTrue && ClientPrefs.UiStates =='Leather-Engine') ? 
				"Remaining: " + Notelength + "\n"
				+ "Combos: " + combo + "\n"
				+ "Marvelous: "
				+ Std.string(ratingArray[0])
				+ "\n"
				+ "Sick: "
				+ Std.string(ratingArray[1])
				+ "\n"
				+ "Good: "
				+ Std.string(ratingArray[2])
				+ "\n"
				+ "Bad: "
				+ Std.string(ratingArray[3])
				+ "\n"
				+ "Shit: "
				+ Std.string(ratingArray[4])
				+ "\n"
				+ "Misses: "
				+ Std.string(songMisses)
				+ "\n" : 
				"Remaining: " + Notelength + "\n"
				+ "Combos: " + combo + "\n"
				+ "Sick: "
				+ Std.string(ratingArray[1])
				+ "\n"
				+ "Good: "
				+ Std.string(ratingArray[2])
				+ "\n"
				+ "Bad: "
				+ Std.string(ratingArray[3])
				+ "\n"
				+ "Shit: "
				+ Std.string(ratingArray[4])
				+ "\n"
				+ "Misses: "
				+ Std.string(songMisses) 
				+ "\n" )
				+ (ClientPrefs.MarvelouTrue
					&& ratingArray[0] > 0
					&& MA > 0 ? "MA: " + Std.string(FlxMath.roundDecimal(ratingArray[0] / MA, 2)) + "\n" : 
					(ratingArray[1] > 0
						&& MA > 0 ? "SC: " + Std.string(FlxMath.roundDecimal(ratingArray[1] / MA, 2)) + "\n" : "") )
				+ (ratingArray[2] > 0
					&& PA > 0 ? "PA: " + Std.string(FlxMath.roundDecimal((ratingArray[1] + ratingArray[0]) / PA, 2)) + "\n" : ""));
		}
		else
		{
			var ratingArray = [
				marvelous,
				sicks,
				goods,
				bads,
				shits
			];

			var notleratingArray = [
				sicks,
				goods,
				bads,
				shits
			];
	
			var MA = ratingArray[1] + ratingArray[2] + ratingArray[3] + ratingArray[4];
			var PA = ratingArray[2] + ratingArray[3] + ratingArray[4];
	
			if (ClientPrefs.UiStates =='Leather-Engine')
			{
				return (
					(ClientPrefs.MarvelouTrue ? 
					"Combos: " + combo + "\n"
					+ "Marvelous: "
					+ Std.string(ratingArray[0])
					+ "\n"
					+ "Sick: "
					+ Std.string(ratingArray[1])
					+ "\n"
					+ "Good: "
					+ Std.string(ratingArray[2])
					+ "\n"
					+ "Bad: "
					+ Std.string(ratingArray[3])
					+ "\n"
					+ "Shit: "
					+ Std.string(ratingArray[4])
					+ "\n"
					+ "Misses: "
					+ Std.string(songMisses)
					+ "\n"
					+ "Scores: "
					+ Std.string(songScore)
					+ "\n"
					+ "Accuracy: "
					+ Std.string(accuracy)
					+ "%\n" : 
					"Combos: " + combo + "\n"
					+ "Sick: "
					+ Std.string(ratingArray[1])
					+ "\n"
					+ "Good: "
					+ Std.string(ratingArray[2])
					+ "\n"
					+ "Bad: "
					+ Std.string(ratingArray[3])
					+ "\n"
					+ "Shit: "
					+ Std.string(ratingArray[4])
					+ "\n"
					+ "Misses: "
					+ Std.string(songMisses)
					+ "\n"
					+ "Scores: "
					+ Std.string(songScore)
					+ "\n"
					+ "Accuracy: "
					+ Std.string(accuracy)
					+ "%\n" )
					+ (ClientPrefs.MarvelouTrue
						&& ratingArray[0] > 0
						&& MA > 0 ? "MA: " + Std.string(FlxMath.roundDecimal(ratingArray[0] / MA, 2)) + "\n" : 
						(ratingArray[1] > 0
							&& MA > 0 ? "SC: " + Std.string(FlxMath.roundDecimal(ratingArray[1] / MA, 2)) + "\n" : "") )
					+ (ratingArray[2] > 0
						&& PA > 0 ? "PA: " + Std.string(FlxMath.roundDecimal((ratingArray[1] + ratingArray[0]) / PA, 2)) + "\n" : ""));
			}
			else
			{
				return (
					"Combos: " + combo + "\n"
					+ "Sick: "
					+ Std.string(notleratingArray[0])
					+ "\n"
					+ "Good: "
					+ Std.string(notleratingArray[1])
					+ "\n"
					+ "Bad: "
					+ Std.string(notleratingArray[2])
					+ "\n"
					+ "Shit: "
					+ Std.string(notleratingArray[3])
					+ "\n"
					+ "Misses: "
					+ Std.string(songMisses)
					+ "\n"
					+ "Scores: "
					+ Std.string(songScore)
					+ "\n"
					+ "Accuracy: "
					+ Std.string(${Highscore.floorDecimal(ratingPercent * 100, 2)})
					+ "\n"
					+ (notleratingArray[0] > 0
						&& MA > 0 ? "SC: " + Std.string(FlxMath.roundDecimal(notleratingArray[0] / MA, 2)) + "\n" : "")
					+ (notleratingArray[1] > 0
						&& PA > 0 ? "PA: " + Std.string(FlxMath.roundDecimal((notleratingArray[0]) / PA, 2)) + "\n" : ""));
			}
		}
	}

	public function calculateAccuracy()
	{
		if (totalNotes != 0)
			accuracy = FlxMath.roundDecimal(100.0 / (totalNotes / hitNotes), 2);
		updateRating();
		updateScoreText();
	}
	
	function updateRank(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		var accuracyToRank:Array<Bool> = [
			statsToUse.accuracy <= 40,
			statsToUse.accuracy <= 50,
			statsToUse.accuracy <= 60,
			statsToUse.accuracy <= 70,
			statsToUse.accuracy <= 80,
			statsToUse.accuracy <= 90,
			statsToUse.accuracy <= 100,
		];

		var fcShit:Array<Bool> = [
			statsToUse.misses == 0 && Math.floor(statsToUse.accuracy) == 69,
			statsToUse.misses == 0 && statsToUse.accuracy < 69,
			statsToUse.misses == 0 && statsToUse.goods == 0 && statsToUse.bads == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0 && statsToUse.bads == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0 && statsToUse.shits == 0,
			statsToUse.misses == 0,
			statsToUse.misses <= 10,
			statsToUse.misses > 10,
			statsToUse.misses > 1000,
		];

		for (i in 0...accuracyToRank.length)
		{
			if (accuracyToRank[i])
			{
				statsToUse.curRank = ranksList[i];
				var fcText = "";
				for (i in 0...fcShit.length)
				{
					if (fcShit[i])
					{
						fcText = fcList[i];
						break;
					}
				}
				statsToUse.curRank += " " + fcText;

				break;
			}
		}
	}
	
	function MultiCalculateAccuracy(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		var notesAddedUp = statsToUse.sustainsHit + (statsToUse.sicks) + (statsToUse.goods * 0.7) + (statsToUse.bads * 0.4) + (statsToUse.shits * 0);
		if (ClientPrefs.UiStates == 'Leather-Engine')
			if (ClientPrefs.MarvelouTrue)
				notesAddedUp =  statsToUse.sustainsHit + (statsToUse.marvelous + statsToUse.sicks) + (statsToUse.goods * 0.8) + (statsToUse.bads * 0.5) + (statsToUse.shits * 0.265);
			else
				notesAddedUp =  statsToUse.sustainsHit + (statsToUse.sicks) + (statsToUse.goods * 0.8) + (statsToUse.bads * 0.5) + (statsToUse.shits * 0.25);
		if (ClientPrefs.UiStates == 'Zoro-Engine')
			notesAddedUp = statsToUse.sustainsHit + statsToUse.sicks + (statsToUse.goods * 0.75) + (statsToUse.bads * 0.3) + (statsToUse.shits * 0.1);
		statsToUse.accuracy = FlxMath.roundDecimal((notesAddedUp / statsToUse.totalNotesHit) * 100, 2);

		updateRank(playernum);
	}

	function getStats(playernum:Int = 1)
	{
		var stats = null;
		if (characterPlayingAs == 2 || characterPlayingAs == 3)
		{
			stats = p1Ratings.Stats;
	
			if (playernum != 1)
				stats = p2Ratings.Stats;

		}
		return stats;
	}

	function updateHUD(playernum:Int = 1):Void
	{
		var statsToUse = getStats(playernum);

		statsToUse.scorelerp = Math.floor(FlxMath.lerp(statsToUse.scorelerp, statsToUse.songScore, 0.4)); //funni lerp
		statsToUse.acclerp = FlxMath.roundDecimal(FlxMath.lerp(statsToUse.acclerp, statsToUse.accuracy, 0.4), 2);

		if (Math.abs(statsToUse.scorelerp - statsToUse.songScore) <= 10)
			statsToUse.scorelerp = statsToUse.songScore;

		if ((statsToUse.acclerp - statsToUse.accuracy) <= 0.05)
			statsToUse.acclerp = statsToUse.accuracy;

		var player = "Player:" + (playernum == 1 ? 'P2' : 'P1');
		var score = "Score:" + statsToUse.scorelerp;
		var rank = "Rank: " + statsToUse.curRank;
		var acc = "Accuracy: " + statsToUse.acclerp + "%";
		var miss = "Misses: " + statsToUse.misses;

		var sick = "Sicks: " + statsToUse.sicks;
		var good = "Goods: " + statsToUse.goods;
		var bad = "Bads: " + statsToUse.bads;
		var shit = "Shits: " + statsToUse.shits;

		var comb = "Combo: " + statsToUse.combo;
		var highestcomb = "Highest Combo: " + statsToUse.highestCombo;
		var maxhp = "MaxHealth: " + (Math.floor(maxhealth * 500) / 10) + '%';
		var hp = "Health: " + Math.floor((playernum == 1 ? bfhealth : dadhealth) * 500) / 10 + '%';
		if (characterPlayingAs == 2)
		{
			if (fliplol)
			{
				if (playernum == 1)
					hp = "Health: " + Math.floor((maxhealth - health) * 500) / 10 + '%';
				if (playernum != 1)
					hp = "Health: " + Math.floor(health * 500) / 10 + '%';
			}
			else
			{
				if (playernum == 1)
					hp = "Health: " + Math.floor(health * 500) / 10 + '%';
				if (playernum != 1)
					hp = "Health: " + Math.floor((maxhealth - health) * 500) / 10 + '%';
			}
		}
		var minhp = "MinHealth: " + Math.floor(minhealth * 500) / 10 + '%';

		var listOShit = [player,score, rank, acc, miss, sick, good, bad, shit, comb, highestcomb, maxhp, hp, minhp];
		var text = "";
		text = "";
		for (i in 0...listOShit.length)
		{
			if ((i == 5 || i == 9 || i == 11))
				text += "\n";

			/*
			if (SaveData.hudPos != "Default")
				text += "\n";
			else
				text += "|";

			text += listOShit[i];

			if (SaveData.hudPos == "Default")
				text += "|";
			*/
			text += "\n";
			text += listOShit[i];
		}
		if (playernum == 1)
			P1scoreTxt.text = text;
		else
			P2scoreTxt.text = text;
	}

	public function updateRating()
		ratingStr = Ratings.getRank(accuracy, songMisses);

	public function updateScoreText()
	{
		if (characterPlayingAs != 2 && characterPlayingAs != 3)
		{
			scoreTxt.text = ("Score: " + songScore + " | " + "Misses: " + songMisses + " | " + "Accuracy: " + accuracy + "% | " + ratingStr);
	
			if (ClientPrefs.Gengo == 'Eng')
				scoreTxt.text = ("Score: " + songScore + " | " + "Misses: " + songMisses + " | " + "Accuracy: " + accuracy + "% | " + ratingStr);
			if (ClientPrefs.Gengo == 'Jp')
				scoreTxt.text = ("スコア: " + songScore + " | " + "ミス数: " + songMisses + " | " + "精度: " + accuracy + "% | " + ratingStr);
	
			scoreTxt.screenCenter(X);
		}
		else
		{
			scoreTxt.text = "";
		}
	}

	private final divider:String = ' - ';

	public function ForeverUpdateScoreText()
	{
		var importSongScore = songScore;
		var importPlayStateCombo = combo;
		var importMisses = songMisses;
		if (ClientPrefs.Gengo == 'Jp')
			scoreBar.text = 'スコア: $importSongScore';
		else
			scoreBar.text = 'Score: $importSongScore';

		// testing purposes
		var displayAccuracy:Bool = ClientPrefs.DisplayAccuracy;
		if (displayAccuracy)
		{
			if (characterPlayingAs != 2 && characterPlayingAs != 3)
			{
				if (ClientPrefs.Gengo == 'Jp')
				{
					scoreBar.text += divider + '精度: ' + '${Highscore.floorDecimal(ratingPercent * 100, 2)}%$ratingFC'; // Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
					scoreBar.text += divider + 'コンボブレイク数: ' + Std.string(songMisses);
					scoreBar.text += divider + 'ランク: ' + '$ratingName';
				}
				else
				{
					scoreBar.text += divider + 'Accuracy: ' + '${Highscore.floorDecimal(ratingPercent * 100, 2)}%$ratingFC'; // Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
					scoreBar.text += divider + 'Combo Breaks: ' + Std.string(songMisses);
					scoreBar.text += divider + 'Rank: ' + '$ratingName';
				}
			}
			else
			{
				scoreBar.text = '';
				/*
				if (ClientPrefs.Gengo == 'Jp')
				{
					scoreBar.text += divider + '精度: ' + '${Highscore.floorDecimal(ratingPercent * 100, 2)}%$ratingFC'; // Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
					scoreBar.text += divider + 'コンボブレイク数: Dad側' + Std.string(p1Ratings[5]) + ' Bf側' + Std.string(p2Ratings[5]);
					scoreBar.text += divider + 'ランク: ' + '$ratingName';
				}
				else
				{
					scoreBar.text += divider + 'Accuracy: ' + '${Highscore.floorDecimal(ratingPercent * 100, 2)}%$ratingFC'; // Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
					scoreBar.text += divider + 'Combo Breaks: Dad Side' + Std.string(p1Ratings[5]) + ' Bf Side' + Std.string(p2Ratings[5]);
					scoreBar.text += divider + 'Rank: ' + '$ratingName';
				}
				*/
			}
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (ClientPrefs.Counter != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
			ForeverUpdateRatingText();
		}
	}

	function bossStuff() {
		var offset = 50; //was 250

		tentacleEmitter = new FlxEmitter(0, 0);
		add(tentacleEmitter);
		tentacleEmitter.cameras = [camHUD];

		tentacleEmitter2 = new FlxEmitter(0, 0);
		add(tentacleEmitter2);
		tentacleEmitter2.cameras = [camHUD];

		//water shit
		particleEmitter2 = new FlxEmitter(0, 0);
		add(particleEmitter2);
		particleEmitter2.cameras = [camHUD];

		//sharks
		sharkEmitter = new FlxEmitter(0, 0);
		add(sharkEmitter);
		sharkEmitter.cameras = [camHUD];

		//waves
		particleEmitter = new FlxEmitter(0, 0);
		add(particleEmitter);
		particleEmitter.cameras = [camHUD];
	}

	public function killBF(spaceTimer:FlxTimer):Void{
		if (characterPlayingAs != -2 && characterPlayingAs != 3)
			health = minhealth;
		else
			bfhealth = minhealth;
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Array<Dynamic> = [callOnLuas('onRecalculateRating', [], false), callOnHaxes('onRecalculateRating', [], false)];
		if(!ret.contains(FunkinLua.Function_Stop))
		{
			if (ClientPrefs.UiStates == 'Forever-Engine')
			{
				if (sicks < 0 && goods < 0 && bads < 0
				&& shits < 0 && songMisses < 0)
				{
					ratingFC = " [NULL]";
					ratingName = "S+";
				}

				if(totalPlayed < 1) //Prevent divide by 0
					ratingName = 'S+';
				else
				{
					ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

					// Rating Name
					if(ratingPercent >= 1)
						ratingName = ForeverratingStuff[ForeverratingStuff.length-1][0]; //Uses last string
					else
					{
						for (i in 0...ForeverratingStuff.length-1)
						{
							if(ratingPercent < ForeverratingStuff[i][1])
							{
								ratingName = ForeverratingStuff[i][0];
								break;
							}
						}
					}
				}
				ratingFC = " [None]";
	
				if (sicks > 0) ratingFC = " [SFC]";
				if (goods > 0) ratingFC = " [GFC]";
				if (bads > 0) ratingFC = " [FC]";
				if (songMisses > 0) ratingFC = "";
			}
			else
			{
				if(totalPlayed < 1) //Prevent divide by 0
					ratingName = '?';
				else
				{
					// Rating Percent
					ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
					//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);
	
					// Rating Name
					if(ratingPercent >= 1)
					{
						//ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
						if((ClientPrefs.Reating == 'Leather Engine'))
							ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
	
						if(ClientPrefs.Reating == 'Psych Engine')
							ratingName = oldratingStuff[oldratingStuff.length-1][0]; //Uses last string
	
						if(ClientPrefs.Gengo == 'Jp' && ClientPrefs.JPScore)
							ratingName = JpratingStuff[JpratingStuff.length-1][0]; //Uses last string
	
					}
					else
					{
						/*
						for (i in 0...ratingStuff.length-1)
						{
							if(ratingPercent < ratingStuff[i][1])
							{
								ratingName = ratingStuff[i][0];
								break;
							}
						}
						*/
						if(ClientPrefs.Reating == 'Leather Engine') {
							for (i in 0...ratingStuff.length-1)
							{
								if(ratingPercent < ratingStuff[i][1])
								{
									ratingName = ratingStuff[i][0];
									break;
								}
							}
						}
	
						if(ClientPrefs.Reating == 'Psych Engine') {
							for (i in 0...oldratingStuff.length-1)
							{
								if(ratingPercent < oldratingStuff[i][1])
								{
									ratingName = oldratingStuff[i][0];
									break;
								}
							}
						}
						if(ClientPrefs.Gengo == 'Jp' && ClientPrefs.JPScore)
						{
							for (i in 0...JpratingStuff.length-1)
							{
								if(ratingPercent < JpratingStuff[i][1])
								{
									ratingName = JpratingStuff[i][0];
									break;
								}
							}
						}
					}
				}
	
				// Rating FC
				ratingFC = "";
				if (ClientPrefs.UiStates == 'Leather-Engine' && ClientPrefs.MarvelouTrue)
					if (marvelous > 0) ratingFC = "MFC";
	
				if (sicks > 0) ratingFC = "SFC";
				if (goods > 0) ratingFC = "GFC";
				if (bads > 0 || shits > 0) ratingFC = "FC";
				if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
				else if (songMisses >= 10) ratingFC = "Clear";
			}
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;

							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}

/*
class Underlay extends FlxSprite
{
	var strumGroup:FlxTypedGroup<StrumNote>;
	public var isPlayer:Bool = false;
	override public function new(strumGroup:FlxTypedGroup<StrumNote>)
	{
		super(0,-1000);
		this.strumGroup = strumGroup;
		makeGraphic(1,3000, FlxColor.BLACK);
		this.scrollFactor.set();
		this.cameras = [PlayState.instance.camHUD];
	}
	override function update(elapsed:Float)
	{
		this.x = strumGroup.members[0].x;
		this.alpha = ClientPrefs.underlayAlpha;
		this.visible = true;

		if (strumGroup.members[0].alpha == 0 || !strumGroup.members[0].visible)
			this.visible = false;

		if (this.visible)
		{
			for (i in 0...strumGroup.members.length)
			{
				if (strumGroup.members[i].curID == Note.ammo[strumGroup.members[i].curMania]-1)
				{
					
					this.width = (strumGroup.members[i].get_inWorldX() + (strumGroup.members[i].get_inWorldScaleX()*160)) - strumGroup.members[0].get_inWorldX();
					setGraphicSize(Std.int(width), 3000);
					updateHitbox();
					//break;
				}
			}
		}
		if (width < 50)
			this.visible = false;

		super.update(elapsed);
	}
}
*/