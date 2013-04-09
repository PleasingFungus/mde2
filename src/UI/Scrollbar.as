package UI {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Scrollbar extends FlxGroup {
		
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		
		protected var slider:FlxSprite;
		protected var rail:FlxSprite;
		
		protected var barClicked:Boolean;
		protected var tick:int;
		
		public function Scrollbar(X:int, Y:int, Height:int) {
			super();
			
			x = X;
			y = Y;
			width = 48;
			height = Height;
			
			create();
		}
		
		public function create():void {
			members = [];
			
			//slider bit
			slider = new FlxSprite(x, -1).makeGraphic(20, 8, 0xffa0a0a0, true, "sliderBar");
			slider.framePixels.fillRect(new Rectangle(1, 1, slider.width - 2, slider.height - 2), 0xff202020);
			slider.y = y;
			
			//TODO: arrows
			
			//"rail"
			rail = new FlxSprite(slider.x + slider.width / 2 - 4/2, y).makeGraphic(4, height, 0xffa0a0a0);
			add(rail);
			add(slider);
		}
		
		override public function update():void {
			super.update();
			checkClick();
			checkScroll();
			tick++;
		}
		
		protected function checkClick():void {
			var adjMouse:FlxPoint = getAdjMouse();
			var barMoused:Boolean = ((adjMouse.y >= rail.y && adjMouse.y <= rail.y + rail.height) &&
									 (adjMouse.x >= slider.x && adjMouse.x <= slider.x + slider.height) &&
									 (!U.buttonManager || !U.buttonManager.moused));
			if (barMoused && U.buttonManager)
				U.buttonManager.moused = true
			
			if (FlxG.mouse.justPressed() && barMoused) {
				barClicked = true;
				moveSlider(adjMouse.y);
			}
			
			if (barClicked) {
				if (FlxG.mouse.pressed())
					moveSlider(adjMouse.y);
				else
					barClicked = false;
			}
		}
		
		private function checkScroll():void {
			if (Math.abs(FlxG.mouse.wheelChange()) > 1)
				moveSlider(FlxG.mouse.wheelChange() * (rail.height - slider.height) / 20 + slider.y);
		}
		
		private function getAdjMouse():FlxPoint {
			return new FlxPoint(FlxG.mouse.x + FlxG.camera.scroll.x * (slider.scrollFactor.x - 1), 
								FlxG.mouse.y + FlxG.camera.scroll.y * (slider.scrollFactor.y - 1));
		}
		
		private function moveSlider(targetY:int):void {
			slider.y = Math.max(rail.y,
								Math.min(rail.y + rail.height - slider.height,
										 targetY - slider.height / 2));
		}
		
		public function get scrollFraction():Number {
			return (slider.y - rail.y) / (rail.height - slider.height);
		}
	}

}