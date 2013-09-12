package Testing.Types {
	import Testing.Tests.Test;
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.PopAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PopType extends InstructionType {
		
		public function PopType() {
			super("Pop");
		}
		
		override public function toString():String {
			return "<"+this.name+">";
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_POP;
		}
		
		override public function can_produce_in_state(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			if (!can_produce(value))
				return false;
			
			var inStack:int = 0;
			for each (var arg:AbstractArg in args)
				if (arg.inStack)
					inStack += 1;
			return inStack < Test.STACK_SIZE; //can't promise another value to be popped off the stack if the stack is already full of promises!
		}
		
		override protected function can_produce(value:AbstractArg):Boolean {
			return value.inRegisters;
		}
		
		override protected function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return true;
		}
		
		override protected function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return true;
		}
		
		
		override protected function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new PopAbstraction(value.value);
		}
		
		override protected function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return new PopAbstraction(value.value);
		}
		
		override protected function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return new PopAbstraction(value.value);
		}
		
	}

}