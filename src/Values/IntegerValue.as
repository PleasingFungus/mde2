package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class IntegerValue extends Value {
		
		private var value:Number;
		public function IntegerValue(value:Number) {
			if (value > int.MAX_VALUE)
				value = int.MAX_VALUE; //dubious
			if (value != int(value))
				throw new Error("Unexpected float!");
			this.value = value;
		}
		
		override public function toString():String {
			if (value == C.INT_NULL)
				return "NIL";
			return value.toString();
		}
		
		override public function toNumber():Number {
			if (value == C.INT_NULL)
				return 0;
			return value;
		}
		
		public static function fromNumber(n:Number):Value {
			if (n == C.INT_NULL || n > int.MAX_VALUE || n < int.MIN_VALUE || isNaN(n) || n != int(n))
				return U.V_UNKNOWN;
			return new IntegerValue(n);
		}
		
		public static function fromValue(v:Value):Value {
			if (v is IntegerValue)
				return v as IntegerValue;
			return fromNumber(v.toNumber());
		}
	}

}