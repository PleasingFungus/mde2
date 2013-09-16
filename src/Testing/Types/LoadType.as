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
		
		override protected function can_produce(value:AbstractArg):Boolean {
			return value.inRegisters;
		}
		
		
		override public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			if (can_produce_with_one_of(value, args))
				return 0;
			return 1;
		}
		
		override protected function can_produce_with_one_of(valueAbstr:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			for each (var arg:AbstractArg in args)
				if (can_produce_with_one_contextual(valueAbstr, arg, args))
					return true;
			return false;
		}
		
		private function can_produce_with_one_contextual(value:AbstractArg, arg:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return ((arg.inMemory && arg.value == value.value) ||
					(arg.inRegisters && arg.value >= U.MIN_MEM && arg.value <= U.MAX_MEM && !AbstractArg.addrInVec(arg.value, args)));
		}
		
		override protected function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			throw new Error("Shouldn't be called!");
		}
		
		override protected function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			throw new Error("Shouldn't be called!");
		}
		
		
		override public function produceMinimally(value:AbstractArg, args:Vector.<AbstractArg>, argsToUse:int = C.INT_NULL):InstructionAbstraction {
			if (argsToUse == C.INT_NULL)
				argsToUse = requiredArgsToProduce(value, args);
			switch (argsToUse) {
				case 0:  
					for each (var arg:AbstractArg in args)
						if (can_produce_with_one_contextual(value, arg, args))
							return produce_with_one(value, arg);
					throw new Error("!!");
				case 1: default: return produce_unrestrainted_contextual(value, args);
			}
		}
		
		override protected function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			throw new Error("Shouldn't be called!");
		}
		
		private function produce_unrestrainted_contextual(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			do {
				var addr:int = C.randomRange(U.MIN_MEM, U.MAX_MEM);
			} while (AbstractArg.addrInVec(addr, args));
			return new LoadAbstraction(addr, value.value);
		}
		
		override protected function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			if (arg.inMemory)
				return new LoadAbstraction(arg.address, value.value);
			if (arg.inRegisters)
				return new LoadAbstraction(arg.value, value.value);
			throw new Error("Invalid arg to load abstraction!");
		}
		
		override protected function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			throw new Error("Not implemented!");
		}
	}

}