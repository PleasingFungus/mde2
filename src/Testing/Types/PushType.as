package Testing.Types {
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.PushAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PushType extends InstructionType {
		
		public function PushType() {
			super("Push");
		}
		
		override public function toString():String {
			return "<"+this.name+">";
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_PUSH;
		}
		
		override protected function can_produce(value:AbstractArg):Boolean {
			return value.inStack;
		}
		
		override protected function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return can_produce_with_one_of(value, args);
		}
		
		override protected function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return arg.inRegisters && arg.value == value.value;
		}
		
		
		override protected function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new PushAbstraction(value.value);
		}
		
		override protected function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return new PushAbstraction(value.value);
		}
		
		override protected function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return new PushAbstraction(value.value);
		}
		
	}

}