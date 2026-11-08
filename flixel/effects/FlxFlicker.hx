package flixel.effects;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxPool;
import flixel.util.FlxTimer;

class FlxFlicker implements IFlxDestroyable
{
	static var _pool:FlxPool<FlxFlicker> = new FlxPool<FlxFlicker>(FlxFlicker.new);
	static var _boundObjects:Map<FlxObject, FlxFlicker> = new Map<FlxObject, FlxFlicker>();

	public static function flicker(Object:FlxObject, Duration:Float = 1, Interval:Float = 0.04, EndVisibility:Bool = true, ForceRestart:Bool = true,
			?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):FlxFlicker
	{
		if (Object == null)
			return null;

		var existing = _boundObjects.get(Object);
		if (existing != null)
		{
			if (!ForceRestart)
				return existing;
			existing.stop();
		}

		var effect = _pool.get();
		_boundObjects.set(Object, effect);
		effect.start(Object, Duration, Interval, EndVisibility, CompletionCallback, ProgressCallback);
		return effect;
	}

	public static function isFlickering(Object:FlxObject):Bool
	{
		return Object != null && _boundObjects.exists(Object);
	}

	public static function stopFlickering(Object:FlxObject):Void
	{
		var effect = Object == null ? null : _boundObjects.get(Object);
		if (effect != null)
			effect.stop();
	}

	public static function pauseFlickering(Object:FlxObject):Void
	{
		var effect = Object == null ? null : _boundObjects.get(Object);
		if (effect != null)
			effect.pause();
	}

	public static function resumeFlickering(Object:FlxObject):Void
	{
		var effect = Object == null ? null : _boundObjects.get(Object);
		if (effect != null)
			effect.resume();
	}

	public static function stopAll():Void
	{
		var effects:Array<FlxFlicker> = [];
		for (effect in _boundObjects)
			effects.push(effect);
		for (effect in effects)
			if (effect.object != null && _boundObjects.get(effect.object) == effect)
				effect.stop();
	}

	public static function pauseAll():Void
	{
		for (effect in _boundObjects)
			effect.pause();
	}

	public static function resumeAll():Void
	{
		for (effect in _boundObjects)
			effect.resume();
	}

	public var object(default, null):FlxObject;
	public var endVisibility(default, null):Bool = true;
	public var timer(default, null):FlxTimer;
	public var completionCallback(default, null):FlxFlicker->Void;
	public var progressCallback(default, null):FlxFlicker->Void;
	public var duration(default, null):Float = 0;
	public var interval(default, null):Float = 0;
	public var toggles(default, null):Int = 0;
	public var isPaused(get, never):Bool;
	public var isRunning(get, never):Bool;
	public var elapsed(get, never):Float;
	public var progress(get, never):Float;

	function get_isPaused():Bool
	{
		return timer != null && !timer.active;
	}

	function get_isRunning():Bool
	{
		return object != null && timer != null && _boundObjects.get(object) == this;
	}

	function get_elapsed():Float
	{
		if (timer == null)
			return 0;
		return toggles * interval + timer.elapsedTime;
	}

	function get_progress():Float
	{
		return duration <= 0 ? 0 : Math.min(1, elapsed / duration);
	}

	public function destroy():Void
	{
		if (timer != null)
			timer.cancel();
		if (object != null && _boundObjects.get(object) == this)
			_boundObjects.remove(object);
		clear();
	}

	function clear():Void
	{
		object = null;
		timer = null;
		completionCallback = null;
		progressCallback = null;
		duration = 0;
		interval = 0;
		toggles = 0;
		endVisibility = true;
	}

	function start(Object:FlxObject, Duration:Float, Interval:Float, EndVisibility:Bool, ?CompletionCallback:FlxFlicker->Void,
			?ProgressCallback:FlxFlicker->Void):Void
	{
		object = Object;
		duration = Math.isNaN(Duration) || Duration < 0 ? 0 : Duration;
		interval = Math.isNaN(Interval) || Interval <= 0 ? Math.max(FlxG.elapsed, 0.001) : Interval;
		endVisibility = EndVisibility;
		completionCallback = CompletionCallback;
		progressCallback = ProgressCallback;
		toggles = 0;
		var loops = duration <= 0 ? 0 : Math.max(1, Math.ceil(duration / interval));
		timer = new FlxTimer().start(interval, flickerProgress, loops);
	}

	public function pause():Void
	{
		if (timer != null)
			timer.active = false;
	}

	public function resume():Void
	{
		if (timer != null)
			timer.active = true;
	}

	public function stop():Void
	{
		if (!isRunning)
			return;
		var target = object;
		if (timer != null)
			timer.cancel();
		target.visible = true;
		release();
	}

	public function finish():Void
	{
		if (!isRunning)
			return;
		var target = object;
		var callback = completionCallback;
		if (timer != null)
			timer.cancel();
		target.visible = endVisibility;
		if (callback != null)
			callback(this);
		if (object == target && _boundObjects.get(target) == this)
			release();
	}

	function release():Void
	{
		if (object == null || _boundObjects.get(object) != this)
			return;
		_boundObjects.remove(object);
		if (timer != null)
			timer.cancel();
		clear();
		_pool.put(this);
	}

	function flickerProgress(currentTimer:FlxTimer):Void
	{
		if (timer != currentTimer || object == null || _boundObjects.get(object) != this)
			return;

		var target = object;
		target.visible = !target.visible;
		toggles++;
		if (progressCallback != null)
			progressCallback(this);

		if (timer != currentTimer || object != target || _boundObjects.get(target) != this)
			return;

		if (currentTimer.loops > 0 && currentTimer.loopsLeft == 0)
			finish();
	}

	@:keep
	function new() {}
}
