package flixel.shark;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

class FlixelShark
{
    public static inline var NAME:String = "FlixelShark";
    public static inline var VERSION:String = "1.0.0";
    public static var effectsEnabled:Bool = true;
    public static var reducedMotion:Bool = false;
    public static var defaultTweenDuration:Float = 0.25;

    public static var isMobile(get, never):Bool;
    static function get_isMobile():Bool
    {
        #if (android || ios)
        return true;
        #else
        return false;
        #end
    }

    public static var isDesktop(get, never):Bool;
    static function get_isDesktop():Bool return !isMobile;

    public static function setFrameRate(value:Int):Int
    {
        var fps = Std.int(FlxMath.bound(value, 1, 240));
        FlxG.updateFramerate = fps;
        FlxG.drawFramerate = fps;
        return fps;
    }

    public static function getFrameRate():Int return FlxG.updateFramerate;

    public static function centerSprite(sprite:FlxSprite, ?camera:FlxCamera):FlxSprite
    {
        if (sprite == null) return null;
        if (camera == null) camera = FlxG.camera;
        if (camera == null) return sprite;
        sprite.x = camera.scroll.x + (camera.width - sprite.width) * 0.5;
        sprite.y = camera.scroll.y + (camera.height - sprite.height) * 0.5;
        return sprite;
    }

    public static function centerSpriteX(sprite:FlxSprite, ?camera:FlxCamera):FlxSprite
    {
        if (sprite == null) return null;
        if (camera == null) camera = FlxG.camera;
        if (camera != null) sprite.x = camera.scroll.x + (camera.width - sprite.width) * 0.5;
        return sprite;
    }

    public static function centerSpriteY(sprite:FlxSprite, ?camera:FlxCamera):FlxSprite
    {
        if (sprite == null) return null;
        if (camera == null) camera = FlxG.camera;
        if (camera != null) sprite.y = camera.scroll.y + (camera.height - sprite.height) * 0.5;
        return sprite;
    }

    public static function flicker(object:FlxObject, duration:Float = 1, interval:Float = 0.04, endVisibility:Bool = true,
        forceRestart:Bool = true, ?onComplete:FlxFlicker->Void, ?onProgress:FlxFlicker->Void):FlxFlicker
    {
        if (object == null) return null;
        if (!effectsEnabled || reducedMotion)
        {
            object.visible = endVisibility;
            return null;
        }
        return FlxFlicker.flicker(object, duration, interval, endVisibility, forceRestart, onComplete, onProgress);
    }

    public static function stopFlicker(object:FlxObject):Void
    {
        if (object != null && FlxFlicker.isFlickering(object)) FlxFlicker.stopFlickering(object);
    }

    public static function fadeIn(sprite:FlxSprite, duration:Float = -1, ?onComplete:FlxTween->Void):FlxTween
    {
        if (sprite == null) return null;
        if (duration < 0) duration = defaultTweenDuration;
        if (!effectsEnabled || reducedMotion || duration <= 0)
        {
            sprite.alpha = 1;
            return null;
        }
        FlxTween.cancelTweensOf(sprite, ["alpha"]);
        sprite.alpha = 0;
        return FlxTween.tween(sprite, {alpha: 1}, duration, {ease: FlxEase.quadOut, onComplete: onComplete});
    }

    public static function fadeOut(sprite:FlxSprite, duration:Float = -1, ?onComplete:FlxTween->Void):FlxTween
    {
        if (sprite == null) return null;
        if (duration < 0) duration = defaultTweenDuration;
        if (!effectsEnabled || reducedMotion || duration <= 0)
        {
            sprite.alpha = 0;
            return null;
        }
        FlxTween.cancelTweensOf(sprite, ["alpha"]);
        return FlxTween.tween(sprite, {alpha: 0}, duration, {ease: FlxEase.quadIn, onComplete: onComplete});
    }

    public static function moveTo(sprite:FlxSprite, x:Float, y:Float, duration:Float = -1, ?onComplete:FlxTween->Void):FlxTween
    {
        if (sprite == null) return null;
        if (duration < 0) duration = defaultTweenDuration;
        if (!effectsEnabled || reducedMotion || duration <= 0)
        {
            sprite.setPosition(x, y);
            return null;
        }
        FlxTween.cancelTweensOf(sprite, ["x", "y"]);
        return FlxTween.tween(sprite, {x: x, y: y}, duration, {ease: FlxEase.quadInOut, onComplete: onComplete});
    }

    public static function setCameraZoom(zoom:Float, ?camera:FlxCamera):Void
    {
        if (camera == null) camera = FlxG.camera;
        if (camera != null) camera.zoom = Math.max(0.01, zoom);
    }

    public static function zoomTo(zoom:Float, duration:Float = -1, ?camera:FlxCamera):FlxTween
    {
        if (camera == null) camera = FlxG.camera;
        if (camera == null) return null;
        zoom = Math.max(0.01, zoom);
        if (duration < 0) duration = defaultTweenDuration;
        if (!effectsEnabled || reducedMotion || duration <= 0)
        {
            camera.zoom = zoom;
            return null;
        }
        FlxTween.cancelTweensOf(camera, ["zoom"]);
        return FlxTween.tween(camera, {zoom: zoom}, duration, {ease: FlxEase.quadInOut});
    }

    public static function setBackgroundColor(color:FlxColor, ?camera:FlxCamera):Void
    {
        if (camera == null) camera = FlxG.camera;
        if (camera != null) camera.bgColor = color;
    }

    public static function clamp(value:Float, min:Float, max:Float):Float
    {
        if (min > max)
        {
            var swap = min;
            min = max;
            max = swap;
        }
        return FlxMath.bound(value, min, max);
    }

    public static function lerp(from:Float, to:Float, ratio:Float):Float
    {
        return from + (to - from) * clamp(ratio, 0, 1);
    }

    public static function configure(?fps:Int = 60, ?enableEffects:Bool = true, ?reduceMotion:Bool = false):Void
    {
        setFrameRate(fps);
        effectsEnabled = enableEffects;
        reducedMotion = reduceMotion;
    }
}
