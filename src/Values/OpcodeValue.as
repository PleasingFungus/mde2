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
		
		public static function fromValue(v:Value):OpcodeValue {
			if (v is OpcodeValue)
				return v as OpcodeValue;
			else if (v is InstructionValue)
				return (v as InstructionValue).operation;
			for each (var op:OpcodeValue in OPS)
				if (op.toNumber() == v.toNumber())
					return op;
			return OP_NOOP;
		}
		
		public static const OP_NOOP:OpcodeValue = new OpcodeValue("NOOP", 0);
		public static const OP_ADD:OpcodeValue = new OpcodeValue("ADD", 1);
		public static const OP_SUB:OpcodeValue = new OpcodeValue("SUB", 2);
		public static const OP_MUL:OpcodeValue = new OpcodeValue("MUL", 3);
		public static const OP_DIV:OpcodeValue = new OpcodeValue("DIV", 4);
		public static const OP_SET:OpcodeValue = new OpcodeValue("SET", 5);
		public static const OP_JMP:OpcodeValue = new OpcodeValue("JMP", 6);
		public static const OP_SAV:OpcodeValue = new OpcodeValue("SAV", 7);
		public static const OP_NOT:OpcodeValue = new OpcodeValue("NOT", 8);
		public static const OP_AND:OpcodeValue = new OpcodeValue("AND", 9);
		public static const OP_OR:OpcodeValue = new OpcodeValue("OR", 10);
		public static const OP_GT:OpcodeValue = new OpcodeValue("GT", 11);
		public static const OP_SAVI:OpcodeValue = new OpcodeValue("SAVI", 12);
		public static const OPS:Array = [OP_NOOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SET, OP_JMP, OP_SAV, OP_NOT, OP_AND, OP_OR, OP_GT, OP_SAVI];
		
	}

}