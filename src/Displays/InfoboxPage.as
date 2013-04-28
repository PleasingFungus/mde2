package Displays {
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InfoboxPage extends FlxGroup {
		
		private var textArea:FlxSprite;
		public function InfoboxPage(Width:int, Height:int) {
			super();
			setDimensions(Width, Height);
		}
		
		public function setDimensions(Width:int, Height:int):void {
			textArea = new FlxSprite().makeGraphic(Width, Height, 0xffffffff, true);
		}
		
		public function setLoc(X:int, Y:int):void {
			textArea.x = X;
			textArea.y = Y;
		}
		
		override public function draw():void {
			textArea.fill(0xff202020);
			for each (var o:FlxSprite in members)
				textArea.stamp(o, o.x - textArea.x, o.y - textArea.y);
			
			textArea.draw();
		}
		
	}

}