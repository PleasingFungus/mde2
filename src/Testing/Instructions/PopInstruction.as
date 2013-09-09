package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PopInstruction extends RegInstruction {
		
		public function PopInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			registers[args[0]] = stack.pop();
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_POP, C.INT_NULL, C.INT_NULL, args[0].value, abstract.toString(), abstract.toFormat());
		}
	}

}