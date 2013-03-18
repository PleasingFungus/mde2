package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FixedValue extends Value {
		
		protected var name:String;
		protected var value:Number;
		public function FixedValue(Name:String, value:Number) {
			name = Name;
			this.value = value;
		}
		
		override public function toString():String { return name; }
		
		override public function toNumber():Number { return value; }
		
		public static var NULL:FixedValue = new FixedValue("NIL", C.INT_NULL);
	}

}