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
		
		public function setValue(v:int):int {
			return value = Math.min(Math.max(v, valueRange.min), valueRange.max);
		}
		
		public function increment():int {
			return value = Math.min(value + 1, valueRange.max);
		}
		
		public function decrement():int {
			return value = Math.max(value - 1, valueRange.min);
		}
	}

}