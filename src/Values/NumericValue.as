package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NumericValue extends Value {
		
		private var value:Number;
		public function NumericValue(value:Number) {
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
		
		public static function fromValue(v:Value):NumericValue {
			if (v is NumericValue)
				return v as NumericValue;
			return new NumericValue(v.toNumber());
		}
	}

}