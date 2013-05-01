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
		
		public function eq(other:ColorText):Boolean {
			return other.color == color && other.text == text;
		}
		
		public static function vecFromArray(array:Array):Vector.<ColorText> {
			var vec:Vector.<ColorText> = new Vector.<ColorText>;
			for each (var cText:ColorText in array)
				vec.push(cText);
			return vec;
		}
		
		public static function singleVec(colorText:ColorText):Vector.<ColorText> {
			return vecFromArray([colorText]);
		}
		
		public static function vecEqual(a:Vector.<ColorText>, b:Vector.<ColorText>):Boolean {
			if (a.length != b.length)
				return false;
			for (var i:int = 0; i < a.length; i++)
				if (!a[i].eq(b[i]))
					return false;
			return true;
		}
	}

}