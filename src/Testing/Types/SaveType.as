package Testing.Types {
	import Testing.Abstractions.SaveAbstraction;
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveType extends InstructionType {
		
		public function SaveType() {
			super("Save");
		}
		
		override public function toString():String {
			return "<"+this.name+">";
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_SAV;
		}
		
		
		override public function can_produce(value:AbstractArg):Boolean {
			return value.inMemory;
		}
		
		override public function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			var valueArg:AbstractArg, memArg:AbstractArg;
			for each (var arg:AbstractArg in args) {
				if (arg.inMemory)
					continue;
				if (arg.value == value.value)
					valueArg = arg;
				if (arg.value == value.address)
					memArg = arg;
			}
			return valueArg && memArg;
		}
		
		override public function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return arg.inRegisters && arg.value == value.value;
		}
		
		
		override public function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new SaveAbstraction(value.value, value.address);
		}
		
		override public function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return new SaveAbstraction(value.value, value.address);
		}
		
		override public function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return new SaveAbstraction(value.value, value.address);
		}
		
	}

}