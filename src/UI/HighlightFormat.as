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
		
		public function update(text:HighlightText):void {
			if (text.formatString == formatString && ColorText.vecEqual(colorStrings, text.colorStrings))
				return;
			
			text.formatString = formatString;
			text.colorStrings = colorStrings;
			text.generate();
		}
		
		public function makeHighlightText(X:int, Y:int, Width:int):HighlightText {
			return new HighlightText(X, Y, Width, formatString, colorStrings);
		}
		
		public static function plain(text:String):HighlightFormat {
			return new HighlightFormat(text, new Vector.<ColorText>);
		}
	}

}