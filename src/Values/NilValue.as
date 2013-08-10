package Values {
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NilValue extends Value {
		
		public function NilValue() { }
		
		override public function toString():String { return ' '; }
		override public function toFormat():HighlightFormat { return FORMAT; }
		
		public static const NIL:NilValue = new NilValue;
		private static const FORMAT:HighlightFormat = new HighlightFormat(' ', new Vector.<ColorText>);
	}

}