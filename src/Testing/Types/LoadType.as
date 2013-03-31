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
		
		//override public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			//return Math.max(super.requiredArgsToProduce(value, args) - 1, 0);
		//} //breaks produceMinimally
		
		override public function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return false;
			
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
			return (arg.inMemory && arg.value == value.value) || (arg.inRegisters && arg.value >= U.MIN_INT && arg.value <= U.MAX_MEM);
		}
		
		
		override public function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return new LoadAbstraction(C.randomRange(U.MIN_MEM, U.MAX_MEM), value.value);
		}
		
		override public function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			if (arg.inMemory)
				return new LoadAbstraction(arg.address, value.value);
			return new LoadAbstraction(C.randomRange(U.MIN_MEM, U.MAX_MEM), value.value);
		}
		
		override public function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			throw new Error("Not implemented!");
		}
	}

}