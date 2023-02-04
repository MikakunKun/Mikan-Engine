package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static final mikanEngineVersion:String = MacroTools.getEngineVersion();
	public static final psychEngineVersion:String = '0.6.3'; // to maximize compatibility
	public static var curSelected:Int = 0;
	public static var curSelected_x:Int = 0;
	public static var curSelected_y:Int = 0;
	public static var launchChance:Dynamic = null;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'sonota',
		'options'
	];

	/* var optionShit:Array<String> = [
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		#if !switch 'donate', #end
		'sonota',
		'options'
	]; */

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var qatarText:FlxText;
	var SelectedName:FlxText;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.7;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			/*
			if ((i % 2) == 0)
			{
				var offset:Float = 108 - (Math.max((optionShit.length % 2), 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, ((i % 2) * 140)  + offset);
			}
			else
			{
				var offset:Float = 108 - (Math.max((optionShit.length % 2), 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, ((i % 2) * 140)  + offset);
			}
			*/
			if ((i % 2) == 0)
			{
				var offset:Float = 108 - (Math.max(((optionShit.length + 1) % 2), 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(100, ((i / 2) * 140)  + offset);
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				if (ClientPrefs.Gengo == 'Jp')
				{
					if (ClientPrefs.JPMenu == 'kurokamizero')
					{
						menuItem.frames = Paths.getSparrowAtlas('jpmainmenu/kurokami-san/menu_' + optionShit[i]);
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);	
					}
					else
					{
						menuItem.frames = Paths.getSparrowAtlas('jpmainmenu/waramoti-san/menu_' + optionShit[i]);
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);					
					}			
				}
				else
				{
					menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
					menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);	
				}
				menuItem.animation.play('idle');
				menuItem.ID = i;
				// menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
			else
			{
				var offset:Float = 108 - (Math.max(((optionShit.length + 1) % 2), 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(600, (((i - 1) / 2) * 140)  + offset);
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				if (ClientPrefs.Gengo == 'Jp')
				{
					if (ClientPrefs.JPMenu == 'kurokamizero')
					{
						menuItem.frames = Paths.getSparrowAtlas('jpmainmenu/kurokami-san/menu_' + optionShit[i]);
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);	
					}
					else
					{
						menuItem.frames = Paths.getSparrowAtlas('jpmainmenu/waramoti-san/menu_' + optionShit[i]);
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);					
					}			
				}
				else
				{
					menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
					menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);	
				}
				menuItem.animation.play('idle');
				menuItem.ID = i;
				// menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);
		
		if (FlxG.save.data.firstTimeUsing == null) {
			FlxG.save.data.firstTimeUsing = true;
		}

		var texts:Array<String> = [
			"Mikan Engine v" + mikanEngineVersion,
			"Psych Engine v" + psychEngineVersion,
			"Friday Night Funkin' v" + Application.current.meta.get('version')
		];
		for (i in 0...texts.length) {
			var versionShit:FlxText = new FlxText(12, ((FlxG.height - 24) - (18 * i) - 18), 0, texts[i], 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit);

			if (i == texts.length - 2) // position of the qatar shit
				{
					qatarText = versionShit;
				}
		}
		SelectedName = new FlxText(12, (FlxG.height - 24), 0, optionShit[0], 12);
		SelectedName.scrollFactor.set();
		if (ClientPrefs.Gengo == 'Jp')
			SelectedName.setFormat(Paths.font("jpvcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.Gengo == 'Eng')
			SelectedName.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(SelectedName);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		// camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), 440);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-2, 0, -1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(2, 0, 1);
			}

			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1, -1, 0);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1, 1, 0);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.mouse.visible = false;

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								if (ClientPrefs.Gengo == 'Jp')
								{
									switch (daChoice)
									{
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										#if MODS_ALLOWED
										case 'mods':
											MusicBeatState.switchState(new japanese.ModsMenuState());
										#end
										case 'awards':
											MusicBeatState.switchState(new japanese.AchievementsMenuState());
										case 'sonota':
											LoadingState.loadAndSwitchState(new japanese.sonotas.OptionsState());
										case 'credits':
											MusicBeatState.switchState(new japanese.CreditsState());
										case 'options':
											LoadingState.loadAndSwitchState(new japanese.options.OptionsState());
									}
								}
								else
								{
									switch (daChoice)
									{
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										#if MODS_ALLOWED
										case 'mods':
											MusicBeatState.switchState(new ModsMenuState());
										#end
										case 'awards':
											MusicBeatState.switchState(new AchievementsMenuState());
										case 'sonota':
											LoadingState.loadAndSwitchState(new sonotas.OptionsState());
										case 'credits':
											MusicBeatState.switchState(new CreditsState());
										case 'options':
											LoadingState.loadAndSwitchState(new options.OptionsState());
									}
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			// spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0, huh_x:Int = 0, huh_y:Int = 0)
	{
		/*
		curSelected_x += huh_x;
		curSelected_y += huh_y;

		if (curSelected_y == ((menuItems.length + 1) % 2))
		{
			curSelected = 0;
			curSelected_y = 0;
		}
		if (curSelected_y < 0)
		{
			curSelected = menuItems.length - 1;
			curSelected_y = ((menuItems.length + 1) % 2) - 1;
		}

		if (curSelected_x == ((menuItems.length + 1) % 4))
		{
			curSelected = 0;
			curSelected_x = 0;
		}
		if (curSelected_x < 0)
		{
			curSelected = menuItems.length - 1;
			curSelected_x = ((menuItems.length + 1) % 4) - 1;
		}

		curSelected = ((curSelected_x % 4) + (curSelected_y));
		*/

		curSelected += huh;
		if (huh == 2)
		{
			// 左で下
			if (curSelected == (menuItems.length % 2))
				curSelected = 1;
			
			// 右で上
			if (curSelected == 0)
				curSelected = menuItems.length - 5;

			// 右で下
			if (curSelected == (menuItems.length + 1))
				curSelected = 0;

			// 左で上
			if (curSelected < (0 - 1))
				curSelected = menuItems.length - 2;
		}

		if (curSelected == menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				if (ClientPrefs.Gengo == 'Jp')
				{
					switch (FlxG.random.int(1, 100))
					{
						case 45:
							SelectedName.text = 'あなたが「過去と未来の狭間」選択してるのは、 ' + optionShit[curSelected] + 'です。';
						default:
							SelectedName.text = 'あなたが今選択してるのは、 ' + optionShit[curSelected] + 'です。';
					}
				}
				if (ClientPrefs.Gengo == 'Eng')
					SelectedName.text = 'Now you have selected ' + optionShit[curSelected] + '.';
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
