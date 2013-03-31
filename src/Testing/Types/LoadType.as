package Testing.Types {
	import Testing.Abstractions.LoadAbstraction;
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LoadType extends InstructionType {
		
		public function LoadType() {
			super("Load");
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_LD;
		}
		
		override public function can_produce(value:AbstractArg):Boolean {
			return value.inRegisters;
		}
		
		override public function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			var memArg:AbstractArg = null;
			for each (var arg:AbstractArg in args)
				if (arg.inMemory && arg.value == value.value) {
					memArg = arg; //this is very unlikely
					break;
				}
			if (!memArg)
				return false;
			
			for each (arg in args)
				if (arg.inRegisters && arg.value == memArg.address)
					return true;
			return false;
		}
		
		override public function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return (arg.inMemory && arg.value == value.value) || (arg.inRegisters && arg.value > int.MAX_VALUE && arg.value < (int.MAX_VALUE - int.MIN_VALUE));
		}
		
		
		override public function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new LoadAbstraction(value.address, value.value);
		}
		
		override public function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return new LoadAbstraction(value.address, value.value);
		}
		
		override public function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return new LoadAbstraction(value.address, value.value);
		}
	}

}