package Helpers {
	import Controls.Key;
	import flash.geom.Rectangle;
	import org.flixel.*
	import Controls.ControlSet;
	
	/**
	 * ...
	 * @author Nicholas Feinberg
	 */
	public class ArrowHelper extends FlxGroup {
		
		private var keys:Vector.<KeyHelper>;
		public var presses:Array;
		private var context:String;
		
		public function ArrowHelper(Context:String = null) {
			keys = new Vector.<KeyHelper>;
			
			for each (var directionKey:Key in ControlSet.DIRECTION_KEYS) {
				var helper:KeyHelper = new KeyHelper(directionKey);
				helper.scrollFactor.x = helper.scrollFactor.y = 0;
				keys.push(helper);
				add(helper);
			}
			
			keys[1].x = keys[3].x = FlxG.width / 2 - keys[1].width / 2;
			keys[0].y = keys[2].y = keys[3].y = FlxG.height - keys[3].height - BUFFER;
			keys[1].y = keys[3].y - keys[1].height - BUFFER;
			keys[0].x = keys[1].x - keys[0].width - BUFFER;
			keys[2].x = keys[1].x + keys[1].width + BUFFER;
			
			context = Context ? "SCROLLER-"+Context : null;
			if (context && U.save.data[context])
				exists = false;
		}
		
		override public function update():void {
			super.update();
			
			var pressTime:Number = 0;
			for each (var key:KeyHelper in keys) {
				if (!key.presses)
					return;
				pressTime += key.pressTime;
			}
			if (pressTime >= PRESS_LIMIT) {
				exists = false;
				if (context)
					U.save.data[context] = true;
			}
		}
		
		protected static const BUFFER:int = 4;
		protected static const PRESS_LIMIT:Number = 1.6; //seconds
	}

}