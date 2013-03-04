package UI {
	import org.flixel.FlxBasic;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ButtonManager extends FlxBasic {
		
		public var moused:Boolean;
		public function ButtonManager() {
			super();
			if (U.buttonManager)
				moused = U.buttonManager.moused;
			U.buttonManager = this;
		}
		
		override public function update():void {
			moused = false;
		}
		
		override public function destroy():void {
			if (this == U.buttonManager)
				U.buttonManager = null;
		}
		
	}

}