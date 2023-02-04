package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import openfl.geom.Matrix;
import flixel.math.FlxAngle;
import openfl.geom.Vector3D;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxSort;
import flixel.animation.FlxAnimation;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

import openfl.geom.PerspectiveProjection;
import openfl.geom.Matrix3D;
import openfl.utils.PerspectiveMatrix3D;

//hey
//if youre reading this, youre probably looking how i did the fake 3d z axis stuff for this mod

//im thinking of making this a library in the future or something idk, still needs more work before i do that, depends if i have time to finish stuff
//you can use this code for other mods/engines if you want, just credit and whatever

/**
 * Extension of FlxSprite that allows for Z perspective.
 * Perspective math is built directly into the drawing and everything execpt layering is handled automatically.

 * Modification by TheZoroForce240
 
 * Still WIP
*/
class FlxPerspectiveSprite extends FlxSprite
{

    public var z:Float = 0; //the

    //converted version used for the actual position, dont need to mess with this
    //in world basically means where its actually repositioned to since flixel doesnt do proper 3d
    private var _inWorldX:Float = 1;
    private var _inWorldY:Float = 1;
    private var _inWorldZ:Float = 1;
    private var _inWorldPos:Vector3D;
    private var _rectPos:Vector3D;
    //public var forceUpdateHitbox:Bool = true;

    private var _inWorldScaleX:Float = 1;
    private var _inWorldScaleY:Float = 1;

    public static var zNear:Float = 0;
    public static var zFar:Float = 100;
    private static var defaultFOV:Float = 90;


    private static var perspectiveProjection:PerspectiveProjection = null;
    private static var perspectiveMatrix:Matrix3D = null;

    static function initMatrix()
    {
        //testing matrix stuffs
        perspectiveProjection = new PerspectiveProjection();
        perspectiveProjection.fieldOfView = 90;
        //perspectiveProjection.projectionCenter.x = FlxG.width/2;
        //perspectiveProjection.projectionCenter.y = FlxG.height/2;

        perspectiveMatrix = perspectiveProjection.toMatrix3D();
    }



    override public function new(X:Float = 0, Y:Float = 0, Z:Float = 0)
    {
        if (perspectiveMatrix == null)
        {
            initMatrix();
        }
        super(X, Y);
        z = Z;
        _inWorldPos = new Vector3D();
        _rectPos = new Vector3D();

        _point.set(x, y);
        _inWorldPos.setTo(_point.x,_point.y,z/1000); //do divide 1000 so z value doesnt have to be a really small decimal
        calculatePerspective(_inWorldPos, defaultFOV*(Math.PI/180));
        _inWorldX = _inWorldPos.x;
        _inWorldY = _inWorldPos.y;
        _inWorldZ = _inWorldPos.z;
        _point.set(_inWorldX, _inWorldY);

    }

    public function get_inWorldX():Float {return _inWorldX; }
    public function get_inWorldY():Float {return _inWorldY; }
    public function get_inWorldZ():Float {return _inWorldZ; }

    public function get_inWorldScaleX():Float {return _inWorldScaleX; }
    public function get_inWorldScaleY():Float {return _inWorldScaleY; }

    public inline function getScaleRatioX():Float {return _inWorldScaleX/scale.x; }
    public inline function getScaleRatioY():Float {return _inWorldScaleY/scale.y; } //not really nessessary since both x/y should be the same but whatever
    public inline function getZScale():Float {return 1/-_inWorldZ; }

    /**
        Converts a Vector3D to its in world coordinates using perspective math
    **/
    public static function calculatePerspective(pos:Vector3D, FOV:Float)
    {
        //var perMat = new PerspectiveProjection(); //dumbass matrix

        /* math from the opengl lol
            found from this website https://ogldev.org/www/tutorial12/tutorial12.html
        */

        //TODO: maybe try using actual matrix???
        
        var newz = pos.z - 1;
        var zRange = zNear - zFar;
        var tanHalfFOV = Math.tan(FOV/2);

        //var m00 = 1/(tanHalfFOV);
        //var m11 = 1/tanHalfFOV;
        //var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
        //var m23 = 2 * zFar * zNear / zRange;
        //var m32 = 1;

        var xOffsetToCenter = pos.x - FlxG.width/2; //so the perspective focuses on the center of the screen
        var yOffsetToCenter = pos.y - FlxG.height/2;

        var zPerspectiveOffset = (newz+(2 * zFar * zNear / zRange));
        var xPerspective = xOffsetToCenter*(1/tanHalfFOV);
        var yPerspective = yOffsetToCenter/(1/tanHalfFOV);
        xPerspective /= -zPerspectiveOffset;
        yPerspective /= -zPerspectiveOffset;

        pos.x = xPerspective+FlxG.width/2; //offset it back to normal
        pos.y = yPerspective+FlxG.height/2;
        pos.z = zPerspectiveOffset;

        

        //pos.z -= 1;
        //pos = perspectiveMatrix.transformVector(pos);

        return pos;
    }

    /**
	 * Determines the function used for rendering in blitting:
	 * `copyPixels()` for simple sprites, `draw()` for complex ones.
	 * Sprites are considered simple when they have an `angle` of `0`, a `scale` of `1`,
	 * don't use `blend`, `pixelPerfectRender` is `true`, and when they have a `z` of `0`.
	 *
	 * @param   camera   If a camera is passed its `pixelPerfectRender` flag is taken into account
	 */
	override public function isSimpleRenderBlit(?camera:FlxCamera):Bool
    {
        var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && z == 0 && blend == null;
        result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
        return result;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);


        _inWorldScaleX = scale.x * getZScale();
        _inWorldScaleY = scale.y * getZScale();

        //update hitbox
        //width = Math.abs(_inWorldScaleX) * frameWidth;
		//height = Math.abs(_inWorldScaleY) * frameHeight;
		//offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		//centerOrigin();
    }


    /**
	 * Call this function to figure out the on-screen position of the object.
	 *
	 * @param   Point    Takes a `FlxPoint` object and assigns the post-scrolled X and Y values of this object to it.
	 * @param   Camera   Specify which game camera you want.
	 *                   If `null`, it will just grab the first global camera.
	 * @return  The Point you passed in, or a new Point if you didn't pass one,
	 *          containing the screen X and Y position of this object.
	 */
	override function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
    {
        if (point == null)
            point = FlxPoint.get();

        if (Camera == null)
            Camera = FlxG.camera;

        point.set(x, y);
        if (pixelPerfectPosition)
            point.floor();

        //move here so the z stuff includes scroll factors
        point.subtract(Camera.scroll.x * scrollFactor.x, Camera.scroll.y * scrollFactor.y);

        var totalZ = z;
        var FOV = defaultFOV;

        if (Std.isOfType(Camera, FlxPerspectiveCamera)) //offset if perspectiveCam
        {
            var temp:Dynamic = Camera;
            var perCam:FlxPerspectiveCamera = temp;
            point.x += perCam.xPerspective;
            point.y += perCam.yPerspective;
            totalZ += perCam.zPerspective;
            FOV = perCam.FOV;
        }


        //new stuff lol
        _inWorldPos.setTo(point.x,point.y,totalZ/1000); //do divide 1000 so z value doesnt have to be a really small decimal
        calculatePerspective(_inWorldPos, FOV*(Math.PI/180));
        _inWorldX = _inWorldPos.x;
        _inWorldY = _inWorldPos.y;
        _inWorldZ = _inWorldPos.z;

        point.set(_inWorldX, _inWorldY);

        return point;
    }


    /**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen.
	 */
    var scaledOffset:FlxPoint = new FlxPoint();
	override public function draw():Void
    {
        checkEmptyFrame();

        if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
            return;

        if (dirty) // rarely
            calcFrame(useFramePixels);

        for (camera in cameras)
        {
            //if (z == 0) //temp fix, will figure out proper isonscreen later
           //{
                if (!camera.visible || !camera.exists || !isOnScreen(camera))
                    continue;
            //}
 


            scaledOffset.set(offset.x*getScaleRatioX(), offset.y*getScaleRatioX());
            getScreenPosition(_point, camera).subtractPoint(scaledOffset);
            
            

            if (isSimpleRender(camera))
                drawSimple(camera);
            else
                drawComplex(camera);

            #if FLX_DEBUG
            FlxBasic.visibleCount++;
            #end
        }

        #if FLX_DEBUG
        if (FlxG.debugger.drawDebug)
            drawDebug();
        #end
    }

    

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created.
	 * @param camera  Optional camera used for scrollFactor, if null `FlxG.camera` is used.
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
    override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
    {
        if (newRect == null)
            newRect = FlxRect.get();
        
        if (camera == null)
            camera = FlxG.camera;
        
        newRect.setPosition(x, y);
        var totalZ = z;
        var FOV = defaultFOV;
        if (Std.isOfType(camera, FlxPerspectiveCamera)) //offset if perspectiveCam
        {
            var temp:Dynamic = camera;
            var perCam:FlxPerspectiveCamera = temp;
            newRect.x += perCam.xPerspective;
            newRect.y += perCam.yPerspective;
            totalZ += perCam.zPerspective;
            FOV = perCam.FOV;
        }
        if (pixelPerfectPosition)
            newRect.floor();
        var scaledOrigin = FlxPoint.weak(origin.x * scale.x, origin.y * scale.y);
        newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - scaledOrigin.x;
        newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - scaledOrigin.y;
        if (isPixelPerfectRender(camera))
            newRect.floor();
        newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));

        _rectPos.setTo(newRect.x,newRect.y,totalZ/1000);
        calculatePerspective(_rectPos, FOV*(Math.PI/180)); //needs to calculate again for some reason, tried just inputting current in world pos and didnt work
        newRect.x = _rectPos.x;
        newRect.y = _rectPos.y;
        

        return newRect.getRotatedBounds(angle, scaledOrigin, newRect);
    }
    
    


    override function drawComplex(camera:FlxCamera):Void
    {
        _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());

        _matrix.translate(-origin.x*getScaleRatioX(), -origin.y*getScaleRatioX());
        _matrix.scale(scale.x * getZScale(), scale.y * getZScale());

        if (bakedRotationAngle <= 0)
        {
            updateTrig();

            if (angle != 0)
                _matrix.rotateWithTrig(_cosAngle, _sinAngle);
        }

        _point.add(origin.x*getScaleRatioX(), origin.y*getScaleRatioX());
        _matrix.translate(_point.x, _point.y);

        if (isPixelPerfectRender(camera))
        {
            _matrix.tx = Math.floor(_matrix.tx);
            _matrix.ty = Math.floor(_matrix.ty);
        }

        camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
    }




    /**
        Returns in-world 3D coordinates using polar angle, azimuthal angle and a radius.
        (Spherical to Cartesian)

        @param	theta Angle used along the polar axis.
        @param	phi Angle used along the azimuthal axis.
        @param	radius Distance to center.
    **/
    public static function getCartesianCoords3D(theta:Float, phi:Float, radius:Float):Vector3D
    {
        var pos:Vector3D = new Vector3D();
        var rad = FlxAngle.TO_RAD;
        pos.x = Math.cos(theta*rad)*Math.sin(phi*rad);
        pos.y = Math.cos(phi*rad);
        pos.z =  Math.sin(theta*rad)*Math.sin(phi*rad);
        pos.x *= radius;
        pos.y *= radius;
        pos.z *= radius;

        return pos;
    }

    /**
        Returns the radius, polar angle, and azimuthal angle from in-world 3D Coordinates.
    **/
    public static function getSphericalCoords(pos:Vector3D):Vector3D
    {
        //TODO
        //figure out this shit
        //pos.x = 
        return pos;
    }


    public static function sortByZ(order:Int, sprite1:FlxPerspectiveSprite, sprite2:FlxPerspectiveSprite):Int
    {
        return FlxSort.byValues(order, sprite1.z, sprite2.z);
    }

    public static function sortByZTrail(order:Int, sprite1:FlxPerspectiveTrail, sprite2:FlxPerspectiveTrail):Int
    {
        return FlxSort.byValues(order, sprite1.z, sprite2.z);
    }
}


/**
 * Edit of FlxTrail to work with FlxPerspectiveSprites, also fixes the fast animation speed bug.
 *
 * Nothing too fancy, just a handy little class to attach a trail effect to a FlxSprite.
 * Inspired by the way "Buck" from the inofficial #flixel IRC channel
 * creates a trail effect for the character in his game.
 * Feel free to use this class and adjust it to your needs.
 * @author Gama11
 */
class FlxPerspectiveTrail extends FlxTypedSpriteGroup<FlxPerspectiveSprite>
{
     /**
      * Stores the FlxSprite the trail is attached to.
      */
     public var target(default, null):FlxPerspectiveSprite;
 
     /**
      * How often to update the trail.
      */
     public var delay:Int;
 
     /**
      * Whether to check for X changes or not.
      */
     public var xEnabled:Bool = true;
 
     /**
      * Whether to check for Y changes or not.
      */
     public var yEnabled:Bool = true;
 
     /**
      * Whether to check for angle changes or not.
      */
     public var rotationsEnabled:Bool = true;
 
     /**
      * Whether to check for scale changes or not.
      */
     public var scalesEnabled:Bool = true;
 
     /**
      * Whether to check for frame changes of the "parent" FlxSprite or not.
      */
     public var framesEnabled:Bool = true;
 
     /**
      * Counts the frames passed.
      */
     var _counter:Int = 0;
 
     /**
      * How long is the trail?
      */
     var _trailLength:Int = 0;
 
     /**
      * Stores the trailsprite image.
      */
     var _graphic:FlxGraphicAsset;
 
     /**
      * The alpha value for the next trailsprite.
      */
     var _transp:Float = 1;
 
     /**
      * How much lower the alpha value of the next trailsprite is.
      */
     var _difference:Float;
 
     var _recentPositions:Array<FlxPoint> = [];
     var _recentZ:Array<Float> = [];
     var _recentAngles:Array<Float> = [];
     var _recentScales:Array<FlxPoint> = [];
     var _recentFrames:Array<Int> = [];
     var _recentFlipX:Array<Bool> = [];
     var _recentFlipY:Array<Bool> = [];
     var _recentAnimations:Array<FlxAnimation> = [];

     public var z:Float = 0;
 
     /**
      * Stores the sprite origin (rotation axis)
      */
     var _spriteOrigin:FlxPoint;
 
     /**
      * Creates a new FlxTrail effect for a specific FlxSprite.
      *
      * @param	Target		The FlxSprite the trail is attached to.
      * @param  	Graphic		The image to use for the trailsprites. Optional, uses the sprite's graphic if null.
      * @param	Length		The amount of trailsprites to create.
      * @param	Delay		How often to update the trail. 0 updates every frame.
      * @param	Alpha		The alpha value for the very first trailsprite.
      * @param	Diff		How much lower the alpha of the next trailsprite is.
      */
     public function new(Target:FlxPerspectiveSprite, ?Graphic:FlxGraphicAsset, Length:Int = 10, Delay:Int = 3, Alpha:Float = 0.4, Diff:Float = 0.05):Void
     {
         super();
 
         _spriteOrigin = FlxPoint.get().copyFrom(Target.origin);
 
         // Sync the vars
         target = Target;
         delay = Delay;
         _graphic = Graphic;
         _transp = Alpha;
         _difference = Diff;
         z = target.z;
 
         // Create the initial trailsprites
         increaseLength(Length);
         solid = false;
     }
 
     override public function destroy():Void
     {
         FlxDestroyUtil.putArray(_recentPositions);
         FlxDestroyUtil.putArray(_recentScales);
 
         _recentAngles = null;
         _recentPositions = null;
         _recentZ = null;
         _recentScales = null;
         _recentFrames = null;
         _recentFlipX = null;
         _recentFlipY = null;
         _recentAnimations = null;
         _spriteOrigin = null;
 
         target = null;
         _graphic = null;
 
         super.destroy();
     }
 
     /**
      * Updates positions and other values according to the delay that has been set.
      */
     override public function update(elapsed:Float):Void
     {
         // Count the frames
         _counter++;

         z = target.z;
 
         // Update the trail in case the intervall and there actually is one.
         if (_counter >= delay && _trailLength >= 1)
         {
             _counter = 0;
 
             // Push the current position into the positons array and drop one.
             var spritePosition:FlxPoint = null;
             if (_recentPositions.length == _trailLength)
             {
                 spritePosition = _recentPositions.pop();
             }
             else
             {
                 spritePosition = FlxPoint.get();
             }
 
             spritePosition.set(target.x - target.offset.x, target.y - target.offset.y);
             _recentPositions.unshift(spritePosition);
             _recentZ.unshift(target.z);
 
             // Also do the same thing for the Sprites angle if rotationsEnabled
             if (rotationsEnabled)
             {
                 cacheValue(_recentAngles, target.angle);
             }
 
             // Again the same thing for Sprites scales if scalesEnabled
             if (scalesEnabled)
             {
                 var spriteScale:FlxPoint = null; // sprite.scale;
                 if (_recentScales.length == _trailLength)
                 {
                     spriteScale = _recentScales.pop();
                 }
                 else
                 {
                     spriteScale = FlxPoint.get();
                 }
 
                 spriteScale.set(target.scale.x, target.scale.y);
                 _recentScales.unshift(spriteScale);
             }
 
             // Again the same thing for Sprites frames if framesEnabled
             if (framesEnabled && _graphic == null)
             {
                 cacheValue(_recentFrames, target.animation.frameIndex);
                 cacheValue(_recentFlipX, target.flipX);
                 cacheValue(_recentFlipY, target.flipY);
                 cacheValue(_recentAnimations, target.animation.curAnim);
             }
 
             // Now we need to update the all the Trailsprites' values
             var trailSprite:FlxPerspectiveSprite;
 
             for (i in 0..._recentPositions.length)
             {
                 trailSprite = members[i];
                 trailSprite.x = _recentPositions[i].x;
                 trailSprite.y = _recentPositions[i].y;
                 trailSprite.z = _recentZ[i];
 
                 // And the angle...
                 if (rotationsEnabled)
                 {
                     trailSprite.angle = _recentAngles[i];
                     trailSprite.origin.x = _spriteOrigin.x;
                     trailSprite.origin.y = _spriteOrigin.y;
                 }
 
                 // the scale...
                 if (scalesEnabled)
                 {
                     trailSprite.scale.x = _recentScales[i].x;
                     trailSprite.scale.y = _recentScales[i].y;
                 }
 
                 // and frame...
                 if (framesEnabled && _graphic == null)
                 {
                     trailSprite.animation.frameIndex = _recentFrames[i];
                     trailSprite.flipX = _recentFlipX[i];
                     trailSprite.flipY = _recentFlipY[i];
 
                     trailSprite.animation.curAnim = _recentAnimations[i];
                 }
 
                 // Is the trailsprite even visible?
                 trailSprite.exists = true;
             }
         }
 
         super.update(elapsed);
     }
 
     function cacheValue<Dynamic>(array:Array<Dynamic>, value:Dynamic)
     {
         array.unshift(value);
         FlxArrayUtil.setLength(array, _trailLength);
     }
 
     public function resetTrail():Void
     {
         _recentPositions.splice(0, _recentPositions.length);
         _recentZ.splice(0, _recentZ.length);
         _recentAngles.splice(0, _recentAngles.length);
         _recentScales.splice(0, _recentScales.length);
         _recentFrames.splice(0, _recentFrames.length);
         _recentFlipX.splice(0, _recentFlipX.length);
         _recentFlipY.splice(0, _recentFlipY.length);
         _recentAnimations.splice(0, _recentAnimations.length);
 
         for (i in 0...members.length)
         {
             if (members[i] != null)
             {
                 members[i].exists = false;
             }
         }
     }
 
     /**
      * A function to add a specific number of sprites to the trail to increase its length.
      *
      * @param 	Amount	The amount of sprites to add to the trail.
      */
     public function increaseLength(Amount:Int):Void
     {
         // Can't create less than 1 sprite obviously
         if (Amount <= 0)
         {
             return;
         }
 
         _trailLength += Amount;
 
         // Create the trail sprites
         for (i in 0...Amount)
         {
             var trailSprite = new FlxPerspectiveSprite(0, 0);
 
             if (_graphic == null)
             {
                 trailSprite.loadGraphicFromSprite(target);
             }
             else
             {
                 trailSprite.loadGraphic(_graphic);
             }
             trailSprite.active = false;
             trailSprite.exists = false;
             add(trailSprite);
             trailSprite.alpha = _transp;
             _transp -= _difference;
             trailSprite.solid = solid;
 
             if (trailSprite.alpha <= 0)
             {
                 trailSprite.kill();
             }
         }
     }
 
     /**
      * In case you want to change the trailsprite image in runtime...
      *
      * @param 	Image	The image the sprites should load
      */
     public function changeGraphic(Image:Dynamic):Void
     {
         _graphic = Image;
 
         for (i in 0..._trailLength)
         {
             members[i].loadGraphic(Image);
         }
     }
 
     /**
      * Handy little function to change which events affect the trail.
      *
      * @param 	Angle 	Whether the trail reacts to angle changes or not.
      * @param 	X 		Whether the trail reacts to x changes or not.
      * @param 	Y 		Whether the trail reacts to y changes or not.
      * @param	Scale	Wheater the trail reacts to scale changes or not.
      */
     public function changeValuesEnabled(Angle:Bool, X:Bool = true, Y:Bool = true, Scale:Bool = true):Void
     {
         rotationsEnabled = Angle;
         xEnabled = X;
         yEnabled = Y;
         scalesEnabled = Scale;
     }
}

class FlxPerspectiveCamera extends FlxCamera
{
    //adds these so you can edit the global x/y/z of all sprites without affecting the camera position (because changing the camera x/y doesnt make the perspective work properly)
    //will only offset FlxPerspectiveSprites
    //mainly using this for fnf modcharting with multiple playfields
    public var xPerspective:Float = 0;
    public var yPerspective:Float = 0;
    public var zPerspective:Float = 0;

    
    public var FOV:Float = 90; //change also change fov if you want i guess
}