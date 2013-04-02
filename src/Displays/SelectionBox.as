package Displays {
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SelectionBox extends FlxSprite {
		
		private var clickPoint:Point;
		public function SelectionBox() {
			clickPoint = U.mouseLoc;
			super(clickPoint.x, clickPoint.y);
			makeGraphic(1, 1, 0xffffffff);
			color = 0x519dcf;
			alpha = 0.6;
		}
		
		override public function update():void {
			if (FlxG.mouse.pressed())
				updateArea();
			else
				exists = false;
			super.update();
		}
		
		private function updateArea():void {
			var mouseLoc:Point = U.mouseLoc;
			scale.x = Math.abs(mouseLoc.x - clickPoint.x);
			scale.y = Math.abs(mouseLoc.y - clickPoint.y);
			x = Math.min(mouseLoc.x, clickPoint.x) + scale.x / 2;
			y = Math.min(mouseLoc.y, clickPoint.y) + scale.y / 2;
		}
	}

}