package Testing.Types {
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.NotAnAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NotAType extends InstructionType {
		
		public function NotAType() {
			super("Not");
		}
		
		override public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			if (can_produce_with_one_of(value, args))
				return 0;
			return 1;
		}
		
		override public function can_produce(value:AbstractArg):Boolean {
			return value.inRegisters && (value.value == 0 || value.value == 1);
		}
		
		override public function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return value.value == !arg.value;
		}
		
		override public function can_produce_with_one_of(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			for each (var arg:AbstractArg in args)
				if (value.value == !arg.value)
					return true;
			return false;
		}
		
		override public function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return can_produce_with_one_of(value, args);
		}
		
		override public function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			if (value.value == 1)
				return new NotAnAbstraction(0);
			return new NotAnAbstraction(C.randomRange(U.MIN_INT, U.MAX_INT+1));
		}
		
		override public function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return new NotAnAbstraction(arg.value);
		}
		
		override public function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			for each (var arg:AbstractArg in args)
				if (value.value == !arg.value)
					return new NotAnAbstraction(arg.value);
			throw new Error("Can't generate Not!");
		}
		
	}

}