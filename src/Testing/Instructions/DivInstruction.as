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
		
		override public function execute(memory:Dictionary, registers:Dictionary):int {
			registers[args[0].value] = registers[args[2].value] ? int(registers[args[1].value] / registers[args[2].value]) : NaN;
			return C.INT_NULL;
		}
		
		override protected function getOpcode():OpcodeValue {
			return OpcodeValue.OP_DIV;
		}
		
	}

}