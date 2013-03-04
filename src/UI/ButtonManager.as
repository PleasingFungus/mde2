package UI {
	import org.flixel.FlxBasic;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ButtonManager extends FlxBasic {
		
		public var clicked:Boolean;
		public function ButtonManager() {
			super();
			U.buttonManager = this;
		}
		
		override public function update():void {
			clicked = false;
		}
		
		override public function destroy():void {
			if (this == U.buttonManager)
				U.buttonManager = null;
		}
		
	}

}