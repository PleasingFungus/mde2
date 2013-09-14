package UI {
	import Controls.ControlSet;
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
		
		public var arrowScrollFraction:Number;
		
		protected var slider:FlxSprite;
		protected var upArrow:FlxSprite;
		protected var downArrow:FlxSprite;
		protected var rail:FlxSprite;
		
		protected var barClicked:Boolean;
		protected var keyHoldTime:Number;
		protected var lastKeyDirection:Number;
		protected var tick:int;
		
		public function Scrollbar(X:int, Y:int, Height:int) {
			super();
			
			x = X;
			y = Y;
			width = 48;
			height = Height;
			
			arrowScrollFraction = 1 / 20;
			
			create();
		}
		
		public function create():void {
			members = [];
			
			//slider bit
			slider = new FlxSprite(x, -1).makeGraphic(20, 8, 0xffa0a0a0, true, "sliderBar");
			slider.framePixels.fillRect(new Rectangle(1, 1, slider.width - 2, slider.height - 2), 0xff202020);
			
			upArrow = new FlxSprite(x, y, _up_arrow);
			downArrow = new FlxSprite(x, y + height, _down_arrow);
			downArrow.y -= downArrow.height;
			
			//"rail"
			rail = new FlxSprite(slider.x + slider.width / 2 - 4/2, y + upArrow.height).makeGraphic(4, height - upArrow.height - downArrow.height, 0xffa0a0a0);
			slider.y = rail.y;
			add(rail);
			add(upArrow)
			add(downArrow);
			add(slider);
			
			keyHoldTime = 0;
			lastKeyDirection = 0;
		}
		
		override public function update():void {
			super.update();
			checkClick();
			checkKeys();
			checkScroll();
			tick++;
		}
		
		protected function checkClick():void {
			var adjMouse:FlxPoint = getAdjMouse();
			var barMoused:Boolean = ((adjMouse.y >= rail.y && adjMouse.y <= rail.y + rail.height) &&
									 (adjMouse.x >= slider.x && adjMouse.x <= slider.x + slider.width) &&
									 (!U.buttonManager || !U.buttonManager.moused));
			if (barMoused && U.buttonManager)
				U.buttonManager.moused = true
			
			if (FlxG.mouse.justPressed()) {
				if (barMoused) {
					barClicked = true;
					moveSlider(adjMouse.y);
				} else if (upArrow.overlapsPoint(adjMouse, true)) {
					moveSlider(slider.y - rail.height * arrowScrollFraction);
				} else if (downArrow.overlapsPoint(adjMouse, true)) {
					moveSlider(slider.y + rail.height * arrowScrollFraction);
				}
			}
			
			if (barClicked) {
				if (FlxG.mouse.pressed())
					moveSlider(adjMouse.y);
				else
					barClicked = false;
			}
		}
		
		private function checkKeys():void {
			if (ControlSet.UP_KEY.pressed())
				keyscroll( -1);
			else if (ControlSet.DOWN_KEY.pressed())
				keyscroll(1);
			else
				keyHoldTime = lastKeyDirection = 0;
		}
		
		private function keyscroll(direction:int):void {
			var magnitude:Number;
			if (lastKeyDirection != direction) {
				lastKeyDirection = direction;
				keyHoldTime = 0;
				magnitude = 3;
			} else {
				keyHoldTime += FlxG.elapsed;
				if (keyHoldTime < DEROCK_TIME)
					return;
				magnitude = 1;
			}
			
			var delta:Number = direction * magnitude * (rail.height - slider.height) / 20;
			moveSlider(delta + slider.y);
		}
		
		private function checkScroll():void {
			if (Math.abs(FlxG.mouse.wheelChange()) > 1)
				moveSlider(-FlxG.mouse.wheelChange() * (rail.height - slider.height) / 20 + slider.y);
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
		
		public function set scrollFraction(fraction:Number):void {
			slider.y = rail.y + (rail.height - slider.height) * fraction;
		}
		
		public function setFlxScrollFactor(x:int, y:int):Scrollbar {
			for each (var member:FlxBasic in members)
				if (member is FlxObject) {
					var obj:FlxObject = member as FlxObject;
					obj.scrollFactor.x = x;
					obj.scrollFactor.y = y;
				}
			return this;
		}
		
		private const DEROCK_TIME:Number = 1 / 3;
		
		[Embed(source = "../../lib/art/ui/upscrollarrow.png")] private const _up_arrow:Class;
		[Embed(source = "../../lib/art/ui/downscrollarrow.png")] private const _down_arrow:Class;
	}

}