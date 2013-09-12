package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PushInstruction extends RegInstruction {
		
		public function PushInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (isNaN(registers[args[0].value]))
				throw new Error("Attempting to read undefined value from registers!");
			
			stack.push(registers[args[0].value]);
			
			if (abstract.stackValue != C.INT_NULL && abstract.stackValue != stack[stack.length - 1])
				throw new Error("Mismatch between expected value & pushed value!");
			
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_PUSH, args[0].value, C.INT_NULL, C.INT_NULL, abstract.toString(), abstract.toFormat());
		}
	}

}