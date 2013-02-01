package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.InstructionArg;
	import flash.utils.Dictionary;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SetInstruction extends Instruction {
		
		public function SetInstruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			super(registers, abstract, noop);
		}
		
		override protected function findArgs(registers:Vector.<int>, abstract:InstructionAbstraction):Vector.<InstructionArg> {
			var args:Vector.<InstructionArg> = new Vector.<InstructionArg>;
			args.push(new InstructionArg(InstructionArg.REG, registers[0]));
			args.push(new InstructionArg(InstructionArg.INT, abstract.value));
			return args;
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary):void {
			registers[args[0].value] = args[1].value;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_SET, args[0].value, args[1].value, C.INT_NULL);
		}
		
	}

}