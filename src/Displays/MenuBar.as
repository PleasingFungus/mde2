package Displays {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuBar extends FlxSprite {
		
		public function MenuBar(Height:int, Color:uint = 0xffbcbcbc) {
			super();
			makeGraphic(FlxG.width, Height, Color);
			scrollFactor.x = scrollFactor.y = 0;
		}
		
		override public function update():void {
			super.update();
			if (overlapsPoint(FlxG.mouse, true))
				U.buttonManager.moused = true;
		}
		
	}

}