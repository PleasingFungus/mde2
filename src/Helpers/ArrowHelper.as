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
		
		public function ArrowHelper() {
			keys = new Vector.<KeyHelper>;
			
			for each (var directionKey:Key in ControlSet.DIRECTION_KEYS) {
				var helper:KeyHelper = new KeyHelper(directionKey);
				helper.scrollFactor.x = helper.scrollFactor.y = 0;
				keys.push(helper);
				add(helper);
			}
			
			keys[0].x = BUFFER;
			keys[2].x = FlxG.width - keys[2].width - BUFFER;
			keys[0].y = keys[2].y = FlxG.height / 2 - keys[0].height / 2;
			keys[1].y = BUFFER;
			keys[3].y = FlxG.height - keys[3].height - BUFFER;
			keys[1].x = keys[3].x = FlxG.width / 2 - keys[1].width / 2;
		}
		
		override public function update():void {
			super.update();
			
			var pressTime:Number = 0;
			for each (var key:KeyHelper in keys) {
				if (!key.presses)
					return;
				pressTime += key.pressTime;
			}
			if (pressTime >= PRESS_LIMIT)	
				exists = false;
		}
		
		protected static const BUFFER:int = 4;
		protected static const PRESS_LIMIT:Number = 1.6; //seconds
	}

}