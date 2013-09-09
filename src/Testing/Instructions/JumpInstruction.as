package Testing.Instructions {
	import Testing.Abstractions.InstructionAbstraction;
	import flash.utils.Dictionary;
	import Testing.Abstractions.JumpAbstraction;
	import Testing.Types.JumpType;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class JumpInstruction extends Instruction {
		
		public function JumpInstruction(address:int, noop:Boolean = false) {
			var args:Vector.<int> = new Vector.<int>;
			args.push(address);
			super(args, new JumpAbstraction(address), noop);
		}
		
		override protected function findArgs(registers:Vector.<int>, _:InstructionAbstraction):Vector.<InstructionArg> {
			var args:Vector.<InstructionArg> = new Vector.<InstructionArg>;
			args.push(new InstructionArg(InstructionArg.INT, registers[0]));
			return args;
		}
		
		override public function toString():String {
			return type.name +" " +args[0].value;
		}
		
		override public function execute(_:Dictionary, __:Dictionary, ___:Vector.<int>):int {
			return args[0].value;
		}
		
		override public function toMemValue():InstructionValue {
			return new InstructionValue(OpcodeValue.OP_JMP, args[0].value, args[0].value, args[0].value, abstract.toString(), abstract.toFormat());
		}
		
	}

}