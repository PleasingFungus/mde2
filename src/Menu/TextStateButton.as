package Menu {
	import UI.TextButton;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class TextStateButton extends TextButton {
		
		protected var state:Class;
		public function TextStateButton(State:Class, name:String) {
			state = State;
			super( -1, -1, name, go);
			setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
			fades = true;
		}
		
		protected function go():void {
			FlxG.switchState(new state());
		}
	}

}