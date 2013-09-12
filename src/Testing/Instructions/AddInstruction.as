package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddInstruction extends RegInstruction {
		
		public function AddInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (isNaN(registers[args[1].value]) || isNaN(registers[args[2].value]))
				throw new Error("Attempting to read undefined value from registers!");
			registers[args[0].value] = registers[args[1].value] + registers[args[2].value];
			if (abstract.value != C.INT_NULL && abstract.value != registers[args[0].value])
				throw new Error("Mismatch between expected value and stored value!");
			return C.INT_NULL;
		}
		
		override protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_ADD;
		}
		
	}

}