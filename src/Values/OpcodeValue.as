package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeValue extends FixedValue {
		
		public var description:String;
		public var longName:String;
		
		public function OpcodeValue(Name:String, value:int, Description:String = null, LongName:String = null) {
			super(Name, value);
			description = Description;
			longName = LongName ? LongName : Name;
		}
		
		override public function toString():String { return name + " (" + value + ")"; }
		
		public function getName():String { return name; }
		
		public function get verboseName():String {
			if (longName)
				return longName + " (" + name + ")";
			return toString();
		}
		
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
		
		public static const OP_NOOP:OpcodeValue = new OpcodeValue("NOOP", 0, "No action. Go to next instruction.", "No Operation");
		public static const OP_ADD:OpcodeValue = new OpcodeValue("ADD", 1, "Add the SOURCE register to the TARGET register, and store the sum in the DESTINATION register.", "Add");
		public static const OP_SUB:OpcodeValue = new OpcodeValue("SUB", 2, "Subtract the TARGET register from the SOURCE register, and store the difference in the DESTINATION register.", "Subtract");
		public static const OP_MUL:OpcodeValue = new OpcodeValue("MUL", 3, "Multiply the SOURCE register with the TARGET register, and store the product in the DESTINATION register.", "Multiply");
		public static const OP_DIV:OpcodeValue = new OpcodeValue("DIV", 4, "Divide the SOURCE register by the TARGET register, and store the quotient in the DESTINATION register.", "Divide");
		public static const OP_SET:OpcodeValue = new OpcodeValue("SET", 5, "Set the TARGET register to the SOURCE value.", "Set");
		public static const OP_JMP:OpcodeValue = new OpcodeValue("JMP", 6, "Jump over the TARGET value, to the instruction after.", "Jump");
		public static const OP_SAV:OpcodeValue = new OpcodeValue("SAV", 7, "Set memory at the value of the TARGET register to the value of the SOURCE register.", "Save");
		public static const OP_NOT:OpcodeValue = new OpcodeValue("NOT", 8);
		public static const OP_AND:OpcodeValue = new OpcodeValue("AND", 9);
		public static const OP_OR:OpcodeValue = new OpcodeValue("OR", 10);
		public static const OP_GT:OpcodeValue = new OpcodeValue("GT", 11);
		public static const OP_SAVI:OpcodeValue = new OpcodeValue("SETM", 12, "Set memory at the TARGET value to the SOURCE value.", "Set Memory");
		public static const OP_LD:OpcodeValue = new OpcodeValue("LD", 13, "Set the DESTINATION register to the value of memory at the value of the TARGET register.", "Load");
		public static const OP_ADDM:OpcodeValue = new OpcodeValue("ADDM", 14, "Set memory at the TARGET value to the sum of the SOURCE value and the DESTINATION value.", "Add Memory");
		public static const OPS:Array = [OP_NOOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SET, OP_JMP, OP_SAV, OP_NOT, OP_AND, OP_OR, OP_GT, OP_SAVI, OP_ADDM];
		
	}

}