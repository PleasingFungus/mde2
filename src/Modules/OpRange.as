package Modules {
	import Values.NumericValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpRange extends Range {
		
		public function OpRange(Min:OpcodeValue, Max:OpcodeValue) {
			super(Min.toNumber(), Max.toNumber(), Min.toNumber());
		}
		
		override public function nameOf(value:int):String {
			return OpcodeValue.fromValue(new NumericValue(value)).toString();
		}
	}

}