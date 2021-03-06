package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import flash.utils.Dictionary;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AndInstruction extends RegInstruction {
		
		public function AndInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary):int {
			registers[args[0].value] = registers[args[1].value] && registers[args[2].value];
			return C.INT_NULL;
		}
		
		override protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_AND;
		}
		
	}

}