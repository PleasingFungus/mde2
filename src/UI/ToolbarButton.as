package UI {
	import Controls.Key;
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ToolbarButton extends GraphicButton {
		
		public function ToolbarButton(X:int, Sprite:Class, Callback:Function, ShortName:String, LongName:String = null, Hotkey:Key = null) {
			if (!LongName)
				LongName = ShortName;
			super(X, 8, Sprite, Callback, LongName, Hotkey);
			
			var extraWidth:int = 10;
			var labelText:FlxText = new ToolbarText(X - extraWidth / 2 - 1, Y + fullHeight - 2, fullWidth + extraWidth, ShortName);
			add(labelText);
			
			setScroll(0);
			labelText.scrollFactor.x = labelText.scrollFactor.y = 0; 
		}
		
	}

}