package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ColorText {
		
		public var color:uint;
		public var text:String;
		public function ColorText(Color:uint, Text:String) {
			color = Color;
			text = Text;
		}
		
		public static function vecFromArray(array:Array):Vector.<ColorText> {
			var vec:Vector.<ColorText> = new Vector.<ColorText>;
			for each (var cText:ColorText in array)
				vec.push(cText);
			return vec;
		}
	}

}