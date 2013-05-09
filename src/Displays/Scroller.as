package Displays {
	import Controls.ControlSet;
	import flash.geom.Point;
	import Helpers.ArrowHelper;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Scroller extends FlxGroup {
		
		private var scrollSpeed:Point;
		public function Scroller(Context:String = null) {
			super();
			
			scrollSpeed = new Point;
			if (U.tutorialState >= U.TUT_BEAT_TUT_2)
				add(new ArrowHelper(Context));
		}
		
		override public function update():void {
			super.update();
			checkControls();
			checkScroll();
		}
		
		private function checkControls():void {
			if (ControlSet.DOWN_KEY.pressed())
				scrollSpeed.y = Math.min(MAX_SPEED, Math.max(0, scrollSpeed.y + ACCEL * FlxG.elapsed));
			else if (ControlSet.UP_KEY.pressed())
				scrollSpeed.y = Math.max( -MAX_SPEED, Math.min(0, scrollSpeed.y - ACCEL * FlxG.elapsed));
			else if (scrollSpeed.y > 0)
				scrollSpeed.y = Math.min(scrollSpeed.y + ACCEL * 4 * FlxG.elapsed, 0);
			else if (scrollSpeed.y < 0)
				scrollSpeed.y = Math.max(scrollSpeed.y - ACCEL * 4 * FlxG.elapsed, 0);
			
			if (ControlSet.RIGHT_KEY.pressed())
				scrollSpeed.x = Math.min(MAX_SPEED, Math.max(0, scrollSpeed.x + ACCEL * FlxG.elapsed));
			else if (ControlSet.LEFT_KEY.pressed())
				scrollSpeed.x = Math.max( -MAX_SPEED, Math.min(0, scrollSpeed.x - ACCEL * FlxG.elapsed));
			else if (scrollSpeed.x > 0)
				scrollSpeed.x = Math.min(scrollSpeed.x + ACCEL * 4 * FlxG.elapsed, 0);
			else if (scrollSpeed.x < 0)
				scrollSpeed.x = Math.max(scrollSpeed.x - ACCEL * 4 * FlxG.elapsed, 0);
			
			if (ControlSet.HOME_KEY.justPressed())
				FlxG.camera.scroll.x = FlxG.camera.scroll.y = 0;
		}
		
		public function checkScroll():void {
			FlxG.camera.scroll.x += scrollSpeed.x;
			FlxG.camera.scroll.y += scrollSpeed.y;
		}
		
		private function get MAX_SPEED():int {
			return 65 / U.zoom;
		}
		private const ACCEL:Number = MAX_SPEED / 2;
	}

}