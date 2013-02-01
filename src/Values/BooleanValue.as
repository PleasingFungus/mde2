package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BooleanValue extends Value {
		
		public var boolValue:Boolean;
		public function BooleanValue(BoolValue:Boolean) {
			super();
			boolValue = BoolValue;
		}
		
		override public function toString():String { return boolValue ? "T" : "F"; }
		
		override public function toNumber():Number { return boolValue ? 1 : 0; }
		
		public function get true_():Boolean { return boolValue; }
		
		public static const TRUE:BooleanValue = new BooleanValue(true);
		public static const FALSE:BooleanValue = new BooleanValue(false);
	}

}