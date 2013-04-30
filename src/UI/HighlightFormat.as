package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class HighlightFormat {
		
		public var formatString:String;
		public var colorStrings:Vector.<ColorText>;
		public function HighlightFormat(FormatString:String, ColorStrings:Vector.<ColorText>) {
			formatString = FormatString;
			colorStrings = ColorStrings;
		}
		
		public function makeHighlightText(X:int, Y:int, Width:int):HighlightText {
			return new HighlightText(X, Y, Width, formatString, colorStrings);
		}
		
	}

}