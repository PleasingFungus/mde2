package UI {
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ToolbarText extends FlxText {
		
		public function ToolbarText(X:int, Y:int, Width:int, Text:String) {
			super(X, Y, Width, Text);
			U.TOOLBAR_FONT.configureFlxText(this, 0xffffff, 'center');
			scrollFactor.x = scrollFactor.y = 0;
		}
		
	}

}