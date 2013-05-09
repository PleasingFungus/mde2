package Displays {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Zoomer extends FlxGroup {
		
		private var scrollPosition:int;
		public function Zoomer() {
			super();
		}
		
		override public function update():void {
			super.update();
			checkScroll();
		}
		
		private function checkScroll():void {
			if (!FlxG.mouse.wheel)
				return;
			if (!canScrollFurther(FlxG.mouse.wheel))
				return;
			
			scrollPosition += FlxG.mouse.wheel;
			if (Math.abs(scrollPosition) >= DISTANCE_BETWEEN_SCROLLS)
				changeZoom(scrollPosition);
		}
		
		private function changeZoom(direction:int):void {
			FlxG.camera.scroll.x += (FlxG.width / 2) / U.zoom;
			FlxG.camera.scroll.y += (FlxG.height / 2) / U.zoom;
			
			U.zoom = nextZoomIn(direction);
			
			FlxG.camera.scroll.x -= (FlxG.width / 2) / U.zoom;
			FlxG.camera.scroll.y -= (FlxG.height / 2) / U.zoom;
			
			scrollPosition = 0;
		}
		
		private function canScrollFurther(direction:int):Boolean {
			var nextZoom:Number = nextZoomIn(direction);
			return nextZoom <= 1 && nextZoom >= 1/4;
		}
		
		private function nextZoomIn(direction:int):Number {
			var newZoomPower:int = Math.round(Math.log(U.zoom) / Math.LN2) + (direction > 0 ? 1 : -1);
			var newZoom:Number = Math.pow(2, newZoomPower);
			return newZoom;
		}
		
		private const DISTANCE_BETWEEN_SCROLLS:Number = 3;
	}

}