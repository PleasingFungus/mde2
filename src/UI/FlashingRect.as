package UI {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FlashingRect extends FlxSprite {
		
		public var maxColor:uint;
		public var minColor:uint;
		public var period:Number;
		private var cycle:Number;
		public function FlashingRect(X:int, Y:int, Width:int, Height:int,
									 MaxColor:uint = 0xffffffff, MinColor:uint = 0xff808080,
									 Alpha:Number = 0.5, Period:Number = 2) {
			maxColor = MaxColor;
			minColor = MinColor;
			period = Period;
			cycle = 0;
			
			super(X, Y);
			makeGraphic(Width, Height, minColor);
			alpha = Alpha;
			blend = "add";
		}
		
		override public function update():void {
			super.update();
			cycle += FlxG.elapsed;
		}
		
		override public function draw():void {
			setColor();
			super.draw();
		}
		
		protected function setColor():void {
			var colorFraction:Number = (Math.sin(Math.PI * 2 * (cycle / period)) + 1) / 2; //ranges 0-1
			var interpolatedColor:uint = C.interpolateColors(minColor, maxColor, colorFraction);
			color = interpolatedColor;
		}
	}

}