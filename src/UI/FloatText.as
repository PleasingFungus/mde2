package UI {
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FloatText extends FlxSprite {
		
		public var text:FlxText;
		public function FloatText(Text:FlxText) {
			text = Text;
			super( -1, -1);
			init();
		}
		
		protected function init():void {
			var w:int = text.textWidth + BORDER_WIDTH * 6;
			var h:int = text.height + BORDER_WIDTH * 4;
			makeGraphic(w, h, DARK_COLOR, true, "float" + w + "," + h);
			stamp(new FlxSprite().makeGraphic(w - BORDER_WIDTH * 2, h - BORDER_WIDTH * 2, LIGHT_COLOR), BORDER_WIDTH, BORDER_WIDTH);
			stamp(new FlxSprite().makeGraphic(w - BORDER_WIDTH * 4, h - BORDER_WIDTH * 4, DARK_COLOR), BORDER_WIDTH*2, BORDER_WIDTH*2);
		}
		
		override public function draw():void {
			if (width != text.textWidth + BORDER_WIDTH * 6 || height != text.height + BORDER_WIDTH * 4)
				init();
			
			super.draw();
			
			text.x = x + BORDER_WIDTH*2;
			text.y = y + BORDER_WIDTH*2;
			text.draw();
		}
		
		protected const BORDER_WIDTH:int = 2;
		protected const LIGHT_COLOR:uint = 0xff666666;
		protected const DARK_COLOR:uint = 0xff202020;
	}

}