package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.PopAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PopInstruction extends RegInstruction {
		
		public function PopInstruction(registers:Vector.<int>, abstract:PopAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			registers[args[0].value] = stack.pop();
			
			if (abstract.value != C.INT_NULL && abstract.value != registers[args[0].value])
				throw new Error("Mismatch between expected value and stored value!");
			
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_POP, C.INT_NULL, C.INT_NULL, args[0].value, abstract.toString(), abstract.toFormat());
		}
	}

}