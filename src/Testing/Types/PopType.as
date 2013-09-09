package Testing.Types {
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
		
		override public function can_produce(value:AbstractArg):Boolean {
			return value.inStack;
		}
		
		override protected function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return false;
		}
		
		override protected function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return false;
		}
		
		
		override protected function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new PopAbstraction(value.value);
		}
		
		override protected function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			throw new Error("!!!");
		}
		
		override protected function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			throw new Error("!!!");
		}
		
	}

}