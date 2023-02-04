package;

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.utils.Assets;
import FlxPerspectiveSprite.FlxPerspectiveTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;

	var bfflip_X:Bool;
	var opponentflip_X:Bool;

	var maxhealth:Float;
	var minhealth:Float;

	// multiple characters stuff
	var characters:Array<CharacterData>;

	// shaggy
	var trail:Null<Bool>;
	var trailLength:Null<Int>;
	var trailDelay:Null<Int>;
	var trailStalpha:Null<Float>;
	var trailDiff:Null<Float>;
}

typedef CharacterData =
{
	var name:String;
	var positionArray:Array<Float>;
	var positionOffset:Array<Float>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxPerspectiveSprite
{
	public var alreadyLoaded:Bool = true; //Used by "Change Character" event
	public var bfflip_X:Bool = false;
	public var opponentflip_X:Bool = false;
	public var latexed = false;

	public var otherCharacters:Array<Character>;

	//public var coolTrail:FlxPerspectiveTrail;
	
	public var trail:Bool = false;
	public var trailLength:Int = 10;
	public var trailDelay:Int = 3;
	public var trailStalpha:Float = 0.4;
	public var trailDiff:Float = 0.05;

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var maxhealth:Float = 2; //maxhealth Bar & Max Health
	public var minhealth:Float = 0; //MinHealth Bar & Min Health

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	
	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;

		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';


				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);

				if(json.characters == null || json.characters.length <= 1)
				{
					var spriteType = "sparrow";
					//sparrow
					//packer
					//texture
					#if MODS_ALLOWED
					var modTxtToFind:String = Paths.modsTxt(json.image);
					var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
					
					//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
					//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
					
					if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
					#else
					if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
					#end
					{
						spriteType = "packer";
					}
						
					#if MODS_ALLOWED
					var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
					var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
						
					//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
					//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
						
					if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
					#else
					if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
					#end
					{
						spriteType = "texture";
					}

					switch (spriteType){
							
						case "packer":
							frames = Paths.getPackerAtlas(json.image);
							
						case "sparrow":
								frames = Paths.getSparrowAtlas(json.image);
							
						case "texture":
							frames = AtlasFrameMaker.construct(json.image);
					}
					imageFile = json.image;
	
					if(json.scale != 1) {
						jsonScale = json.scale;
						setGraphicSize(Std.int(width * jsonScale));
						updateHitbox();
					}
	
					if (json.maxhealth >= 0)
						maxhealth = json.maxhealth;
					else
						maxhealth = 2;
					
					if (json.minhealth <= json.maxhealth)
						minhealth = json.minhealth;
					else
						minhealth = 0;
					
					positionArray = json.position;
					cameraPosition = json.camera_position;

					trail = json.trail;
					trailDelay = json.trailDelay;
					trailLength = json.trailLength;
					trailStalpha = json.trailStalpha;
					trailDiff = json.trailDiff;
	
					healthIcon = json.healthicon;
					singDuration = json.sing_duration;
					flipX = !!json.flip_x;
					if(json.no_antialiasing) {
						antialiasing = false;
						noAntialiasing = true;
					}
	
					if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
						healthColorArray = json.healthbar_colors;
	
					antialiasing = !noAntialiasing;
					if(!ClientPrefs.globalAntialiasing) antialiasing = false;
	
					animationsArray = json.animations;
					if(animationsArray != null && animationsArray.length > 0) {
						for (anim in animationsArray) {
							var animAnim:String = '' + anim.anim;
							var animName:String = '' + anim.name;
							var animFps:Int = anim.fps;
							var animLoop:Bool = !!anim.loop; //Bruh
							var animIndices:Array<Int> = anim.indices;
							if(animIndices != null && animIndices.length > 0) {
								animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
							} else {
								animation.addByPrefix(animAnim, animName, animFps, animLoop);
							}
			
							if(anim.offsets != null && anim.offsets.length > 1) {
								addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
							}
						}
					} else {
						quickAnimAdd('idle', 'BF idle dance');
					}
					cameraPosition = json.camera_position;
					//trace('Loaded file to character ' + curCharacter);
					
					//if(json.trail == true)
						//coolTrail = new FlxPerspectiveTrail(this, null, json.trailLength, json.trailDelay, json.trailStalpha, json.trailDiff);	
				}
				else
					loadNamedConfiguration(json);
		}
		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

		if(curCharacter != '' && otherCharacters == null && animation.curAnim != null)
			{
				updateHitbox();
	
				if (isPlayer)
				{
					flipX = !flipX;
		
					/*// Doesn't flip for BF, since his are already in the right place???
					if (!curCharacter.startsWith('bf'))
					{
						// var animArray
						if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
						{
							var oldRight = animation.getByName('singRIGHT').frames;
							animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
							animation.getByName('singLEFT').frames = oldRight;
						}
		
						// IF THEY HAVE MISS ANIMATIONS??
						if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
						{
							var oldMiss = animation.getByName('singRIGHTmiss').frames;
							animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
							animation.getByName('singLEFTmiss').frames = oldMiss;
						}
					}*/
					if(!isPlayer)
					{
						// Doesn't flip for BF, since his are already in the right place???
						if(opponentflip_X)
						{
							var oldOffRight = animOffsets.get("singRIGHT");
							var oldOffLeft = animOffsets.get("singLEFT");
			
							// var animArray
							var oldRight = animation.getByName('singRIGHT').frames;
							animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
							animation.getByName('singLEFT').frames = oldRight;
			
							animOffsets.set("singRIGHT", oldOffLeft);
							animOffsets.set("singLEFT", oldOffRight);
			
							// IF THEY HAVE MISS ANIMATIONS??
							if (animation.getByName('singRIGHTmiss') != null)
							{
								var oldOffRightMiss = animOffsets.get("singRIGHTmiss");
								var oldOffLeftMiss = animOffsets.get("singLEFTmiss");
			
								var oldMiss = animation.getByName('singRIGHTmiss').frames;
								animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
								animation.getByName('singLEFTmiss').frames = oldMiss;
			
								animOffsets.set("singRIGHTmiss", oldOffLeftMiss);
								animOffsets.set("singLEFTmiss", oldOffRightMiss);
							}
						}
					}
					if(isPlayer)
					{
						// Doesn't flip for BF, since his are already in the right place???
						if(bfflip_X)
						{
							var oldOffRight = animOffsets.get("singRIGHT");
							var oldOffLeft = animOffsets.get("singLEFT");
			
							// var animArray
							var oldRight = animation.getByName('singRIGHT').frames;
							animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
							animation.getByName('singLEFT').frames = oldRight;
			
							animOffsets.set("singRIGHT", oldOffLeft);
							animOffsets.set("singLEFT", oldOffRight);
			
							// IF THEY HAVE MISS ANIMATIONS??
							if (animation.getByName('singRIGHTmiss') != null)
							{
								var oldOffRightMiss = animOffsets.get("singRIGHTmiss");
								var oldOffLeftMiss = animOffsets.get("singLEFTmiss");
			
								var oldMiss = animation.getByName('singRIGHTmiss').frames;
								animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
								animation.getByName('singLEFTmiss').frames = oldMiss;
			
								animOffsets.set("singRIGHTmiss", oldOffLeftMiss);
								animOffsets.set("singLEFTmiss", oldOffRightMiss);
							}
						}
					}
				}
			}

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}
	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			switch(curCharacter)
			{
				case 'pico-speaker':
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				var dadVar:Float = 4;

				if (holdTimer >= Conductor.stepCrochet * 0.001 * dadVar * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	function loadNamedConfiguration(config:CharacterFile)
	{
		if(config.characters == null || config.characters.length <= 1)
		{
			return;
		}
		else
		{
			otherCharacters = [];

			for(characterData in config.characters)
			{
				var character:Character;

				if(!isPlayer)
					character = new Character(x, y, characterData.name, isPlayer);
				else
					character = new Boyfriend(x, y, characterData.name);

				if (characterData.positionArray == null)
				{
					if(flipX)
						characterData.positionOffset[0] = 0 - characterData.positionOffset[0];
	
					character.positionArray[0] += characterData.positionOffset[0];
					character.positionArray[1] += characterData.positionOffset[1];					
				}
				else
				{
					if(flipX)
						characterData.positionArray[0] = 0 - characterData.positionArray[0];
	
					character.positionArray[0] += characterData.positionArray[0];
					character.positionArray[1] += characterData.positionArray[1];
				}
			
				otherCharacters.push(character);

				if(config.camera_position != null)
				{
					if(flipX)
						config.camera_position[0] = 0 - config.camera_position[0];
		
					cameraPosition = config.camera_position;
				}
			}
		}

		if (config.maxhealth >= 0)
			maxhealth = config.maxhealth;
		else
			maxhealth = 2;
		
		if (config.minhealth <= config.maxhealth)
			minhealth = config.minhealth;
		else
			minhealth = 0;
		
		if(config.scale != 1) {
			jsonScale = config.scale;
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}

		positionArray = config.position;

		healthIcon = config.healthicon;
		singDuration = config.sing_duration;
		flipX = !!config.flip_x;
		if(config.no_antialiasing) {
			antialiasing = false;
			noAntialiasing = true;
		}

		if(config.healthbar_colors != null && config.healthbar_colors.length > 2)
			healthColorArray = config.healthbar_colors;

		antialiasing = !noAntialiasing;
		if(!ClientPrefs.globalAntialiasing) antialiasing = false;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
