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
		
		override public function can_produce(value:int):Boolean {
			return value == 0 || value == 1;
		}
		
		override public function can_produce_with_one(value:int, arg:int):Boolean {
			return value == !arg;
		}
		
		override public function can_produce_with_one_of(value:int, args:Vector.<int>):Boolean {
			for each (var arg:int in args)
				if (value == !arg)
					return true;
			return false;
		}
		
		override public function can_produce_with(value:int, args:Vector.<int>):Boolean {
			return can_produce_with_one_of(value, args);
		}
		
		override public function produce_unrestrained(value:int):InstructionAbstraction {
			if (value == 1)
				return new NotAnAbstraction(0);
			return new NotAnAbstraction(C.randomRange(U.MIN_INT, U.MAX_INT+1));
		}
		
		override public function produce_with_one(value:int, arg:int):InstructionAbstraction {
			return new NotAnAbstraction(arg);
		}
		
		override public function produce_with(value:int, args:Vector.<int>):InstructionAbstraction {
			for each (var arg:int in args)
				if (value == !arg)
					return new NotAnAbstraction(arg);
			throw new Error("Can't generate Not!");
		}
		
	}

}