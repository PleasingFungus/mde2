package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Configuration {
		
		public var valueRange:Range;
		public var setValue:Function
		public function Configuration(ValueRange:Range, SetValue:Function) {
			valueRange = ValueRange;
			setValue = SetValue;
		}
		
	}

}