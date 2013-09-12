package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import flash.utils.Dictionary;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DivInstruction extends RegInstruction {
		
		public function DivInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (isNaN(registers[args[1].value]) || isNaN(registers[args[2].value]))
				throw new Error("Attempting to read undefined value from registers!");
			if (!registers[args[2].value])
				throw new Error("Dividing by zero!");
			
			registers[args[0].value] = int(registers[args[1].value] / registers[args[2].value]);
			
			if (abstract.value != C.INT_NULL && abstract.value != registers[args[0].value])
				throw new Error("Mismatch between expected value and stored value!");
			
			return C.INT_NULL;
		}
		
		override protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_DIV;
		}
		
	}

}