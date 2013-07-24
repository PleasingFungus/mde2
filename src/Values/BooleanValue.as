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
		
		override public function toString():String { return boolValue ? "!0" : "0"; }
		
		override public function toNumber():Number { return boolValue ? 1 : 0; }
		
		public function get true_():Boolean { return boolValue; }
		
		public static function fromValue(v:Value):BooleanValue {
			if (v is BooleanValue)
				return v as BooleanValue;
			else if (v is InstructionValue)
				return (v as InstructionValue).operation != OpcodeValue.OP_NOOP ? TRUE : FALSE;
			return v.toNumber() ? TRUE : FALSE;
		}
		
		public static const TRUE:BooleanValue = new BooleanValue(true);
		public static const FALSE:BooleanValue = new BooleanValue(false);
		
		public static const NUMERIC_TRUE:IntegerValue = new IntegerValue(1);
		public static const NUMERIC_FALSE:IntegerValue = new IntegerValue(0);
	}

}