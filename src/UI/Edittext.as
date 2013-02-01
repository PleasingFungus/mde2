package UI {
	import org.flixel.FlxText;
	import flash.text.TextFieldType;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Edittext extends FlxText {
		
		public function Edittext(X:Number, Y:Number, Width:uint, Text:String=null, EmbeddedFont:Boolean=true) {
			super(X, Y, Width, Text, EmbeddedFont);
			_textField.type = TextFieldType.INPUT;
			
			//DEBUG
			_textField.background = true;
			_textField.backgroundColor = 0xffff0000;
		}
		
	}

}