package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveInstruction extends RegInstruction {
		
		public function SaveInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (isNaN(registers[args[0].value]) || isNaN(registers[args[1].value]))
				throw new Error("Attempting to read undefined value from registers!");
			
			memory[registers[args[1].value]] = registers[args[0].value];
			
			if (abstract.memoryAddress != C.INT_NULL && abstract.memoryAddress != registers[args[1].value])
				throw new Error("Mismatch between expected address & saved address!");
			if (abstract.memoryValue != C.INT_NULL && abstract.memoryValue != registers[args[0].value])
				throw new Error("Mismatch between expected value & saved value!");
			
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_SAV, args[0].value, args[1].value, C.INT_NULL, abstract.toString(), abstract.toFormat());
		}
	}

}