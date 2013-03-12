package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeValue extends FixedValue {
		
		public var description:String;
		
		public function OpcodeValue(Name:String, value:int, Description:String = null) {
			super(Name, value);
			description = Description;
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
		
		public static const OP_NOOP:OpcodeValue = new OpcodeValue("NOOP", 0, "No action. Go to next instruction.");
		public static const OP_ADD:OpcodeValue = new OpcodeValue("ADD", 1, "Add the source register to the target register, and store the sum in the destination register.");
		public static const OP_SUB:OpcodeValue = new OpcodeValue("SUB", 2, "Subtract the target register from the source register, and store the difference in the destination register.");
		public static const OP_MUL:OpcodeValue = new OpcodeValue("MUL", 3, "Multiply the source register with the target register, and store the product in the destination register.");
		public static const OP_DIV:OpcodeValue = new OpcodeValue("DIV", 4, "Divide the source register by the target register, and store the quotient in the destination register.");
		public static const OP_SET:OpcodeValue = new OpcodeValue("SET", 5, "Set the target register to the source value.");
		public static const OP_JMP:OpcodeValue = new OpcodeValue("JMP", 6, "Jump over the target value, to the instruction after.");
		public static const OP_SAV:OpcodeValue = new OpcodeValue("SAV", 7, "Set memory at the value of the target register to the value of the source register.");
		public static const OP_NOT:OpcodeValue = new OpcodeValue("NOT", 8);
		public static const OP_AND:OpcodeValue = new OpcodeValue("AND", 9);
		public static const OP_OR:OpcodeValue = new OpcodeValue("OR", 10);
		public static const OP_GT:OpcodeValue = new OpcodeValue("GT", 11);
		public static const OP_SAVI:OpcodeValue = new OpcodeValue("SAVI", 12, "Set memory at the target value to the source value.");
		public static const OPS:Array = [OP_NOOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SET, OP_JMP, OP_SAV, OP_NOT, OP_AND, OP_OR, OP_GT, OP_SAVI];
		
	}

}