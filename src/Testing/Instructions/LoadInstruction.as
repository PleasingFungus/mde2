package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LoadInstruction extends RegInstruction {
		
		public function LoadInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary):int {
			if (isNaN( memory[registers[args[1].value]]))
				throw new Error("!!!");
			registers[args[0].value] = memory[registers[args[1].value]];
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_LD, C.INT_NULL, args[1].value, args[0].value);
		}
		
	}

}