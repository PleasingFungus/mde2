package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import flash.utils.Dictionary;
	import Values.OpcodeValue;
	import Values.InstructionValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NotAnInstruction extends RegInstruction {
		
		public function NotAnInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary):int {
			registers[args[0].value] = !registers[args[1].value];
			return C.INT_NULL;
		}
		
		override protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_NOT;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_NOT, args[1].value, C.INT_NULL, args[0].value, abstract.toString(), abstract.toFormat());
		}
		
	}

}