package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.LoadAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LoadInstruction extends RegInstruction {
		
		public function LoadInstruction(registers:Vector.<int>, abstract:LoadAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (isNaN(registers[args[1].value]))
				throw new Error("Attempting to read undefined value from registers!");
			if (isNaN( memory[registers[args[1].value]]))
				throw new Error("Attempting to read undefined value from memory!");
			
			registers[args[0].value] = memory[registers[args[1].value]];
			
			if (abstract.value != C.INT_NULL && abstract.value != registers[args[0].value])
				throw new Error("Mismatch between expected value and stored value!");
			
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_LD, C.INT_NULL, args[1].value, args[0].value, abstract.toString(), abstract.toFormat());
		}
		
	}

}