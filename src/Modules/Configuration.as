package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Configuration {
		
		public var valueRange:Range;
		public var value:int;
		public function Configuration(ValueRange:Range) {
			valueRange = ValueRange;
			value = valueRange.initial;
		}
		
		public function setValue(v:int):void {
			value = v;
		}
	}

}