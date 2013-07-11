package Values {
	import UI.ColorText;
	import UI.HighlightFormat;
	import UI.HighlightText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeValue extends FixedValue {
		
		public var description:String;
		public var highlitDescription:HighlightFormat;
		public var longName:String;
		
		public function OpcodeValue(Name:String, value:int, Description:String = null, LongName:String = null) {
			super(Name, value);
			description = Description;
			longName = LongName ? LongName : Name;
			
			if (description)
				generateHighlitDescription();
		}
		
		private function generateHighlitDescription():void {
			var colorStrings:Vector.<ColorText> = new Vector.<ColorText>;
			var keywords:Array = [U.SOURCE, U.TARGET, U.DESTINATION];
			var splitStrings:Array = [description];
			for each (var keyword:ColorText in keywords) {
				var newSplit:Array = [];
				for each (var splitString:String in splitStrings) {
					var subSplitStrings:Array = splitString.split(keyword.text.toUpperCase());
					for each (var subSplitString:String in subSplitStrings) {
						newSplit.push(subSplitString);
						newSplit.push(keyword.text.toUpperCase());
					}
					if (newSplit.length && keyword.text.toUpperCase() == newSplit[newSplit.length - 1])
						newSplit.pop();
				}
				splitStrings = newSplit;
			}
			
			var escapedString:String = '';
			for each (splitString in splitStrings) {
				var matchedKeyword:Boolean = false;
				for each (keyword in keywords)
					if (keyword.text.toUpperCase() == splitString) {
						escapedString += "{}";
						colorStrings.push(keyword);
						matchedKeyword = true;
					}
				if (!matchedKeyword)
					escapedString += splitString;
			}
			
			highlitDescription = new HighlightFormat(verboseName + ": " + escapedString, colorStrings);
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
		public static const OP_JMP:OpcodeValue = new OpcodeValue("JMP", 6, "Jump over the DESTINATION value, to the instruction after.", "Jump");
		public static const OP_SAV:OpcodeValue = new OpcodeValue("SAV", 7, "Set memory at the value of the TARGET register to the value of the SOURCE register.", "Save");
		public static const OP_BEQ:OpcodeValue = new OpcodeValue("BEQ", 8, "Jump over the DESTINATION value if the SOURCE register equals the TARGET register.", "Branch");
		public static const OP_SAVI:OpcodeValue = new OpcodeValue("SETM", 12, "Set memory at the TARGET value to the SOURCE value.", "Set Memory");
		public static const OP_LD:OpcodeValue = new OpcodeValue("LD", 13, "Set the DESTINATION register to the value of memory at the value of the TARGET register.", "Load");
		public static const OP_ADDM:OpcodeValue = new OpcodeValue("ADDM", 14, "Set memory at the TARGET value to the sum of the SOURCE value and the DESTINATION value.", "Add Memory");
		public static const OPS:Array = [OP_NOOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SET, OP_JMP, OP_SAV, OP_BEQ, OP_SAVI, OP_ADDM];
	}

}