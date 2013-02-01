package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeValue extends FixedValue {
		
		public function OpcodeValue(Name:String, value:int) {
			super(Name, value);
		}
		
		override public function toString():String { return name + " (" + value + ")"; }
		
		public function getName():String { return name; }
		
		public static const OP_NOOP:OpcodeValue = new OpcodeValue("NOOP", 0);
		public static const OP_ADD:OpcodeValue = new OpcodeValue("ADD", 1);
		public static const OP_SUB:OpcodeValue = new OpcodeValue("SUB", 2);
		public static const OP_MUL:OpcodeValue = new OpcodeValue("MUL", 3);
		public static const OP_DIV:OpcodeValue = new OpcodeValue("DIV", 4);
		public static const OP_SET:OpcodeValue = new OpcodeValue("SET", 5);
		public static const OP_CPY:OpcodeValue = new OpcodeValue("CPY", 6);
		public static const OP_SAV:OpcodeValue = new OpcodeValue("SAV", 7);
		public static const OPS:Array = [OP_NOOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SET, OP_CPY, OP_SAV];
		
	}

}