package Values {
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Value {
		
		public function Value() { }
		
		public function toString():String { return null; }
		public function shortString():String { return toString(); }
		public function toFormat():HighlightFormat { return null; }
		
		public function toNumber():Number { return NaN; }
		
		public function get unknown():Boolean { return this == U.V_UNKNOWN; }
		public function get unpowered():Boolean { return this == U.V_UNPOWERED; }
		
		public function eq(v:Value):Boolean {
			return v && (v.toNumber() == toNumber() || this == v);
		}
	}

}