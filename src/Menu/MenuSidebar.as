package Menu {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuSidebar extends FlxGroup {
		
		private var bg:FlxSprite;
		public function MenuSidebar(Width:int, Color:uint = 0xffbcbcbc) {
			super();
			add(bg = new FlxSprite().makeGraphic(Width, FlxG.height, Color));
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
			//TODO
		}
		
		override public function update():void {
			super.update();
			if (bg.overlapsPoint(FlxG.mouse, true))
				U.buttonManager.moused = true;
		}
		
		public function get width():int {
			return bg.width;
		}
	}

}