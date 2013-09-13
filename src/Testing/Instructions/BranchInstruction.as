package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import flash.utils.Dictionary;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	import Testing.Types.InstructionType;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BranchInstruction extends Instruction {
		
		public function BranchInstruction(registers:Vector.<int>) {
			super(registers, new InstructionAbstraction(InstructionType.BEQ, registers, C.INT_NULL), false);
		}
		
		override protected function findArgs(registers:Vector.<int>, _:InstructionAbstraction):Vector.<InstructionArg> {
			var args:Vector.<InstructionArg> = new Vector.<InstructionArg>;
			args.push(new InstructionArg(InstructionArg.INT, registers[0]));
			for each (var arg:int in registers.slice(1))
				args.push(new InstructionArg(InstructionArg.REG, arg));
			return args;
		}
		
		override public function toString():String {
			return type.name +" " +args[0].value; //TODO
		}
		
		override public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			if (registers[args[1].value] == registers[args[2].value])
				return args[0].value;
			return C.INT_NULL;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_BEQ, args[1].value, args[2].value, args[0].value, abstract.toString(), null);
		}
		
	}

}