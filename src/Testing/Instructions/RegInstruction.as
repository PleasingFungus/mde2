package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	import Testing.InstructionArg
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class RegInstruction extends Instruction {
		
		public function RegInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override protected function findArgs(registers:Vector.<int>, abstract:InstructionAbstraction):Vector.<InstructionArg> {
			var args:Vector.<InstructionArg> = new Vector.<InstructionArg>;
			for each (var reg:int in registers) {
				if (reg < 0)
					throw new Error("!!!");
				args.push(new InstructionArg(InstructionArg.REG, reg));
			}
			return args;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(getOpcode(), args[2].value, args[1].value, args[0].value);
		}
		
		protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_NOOP;
		}
	}

}