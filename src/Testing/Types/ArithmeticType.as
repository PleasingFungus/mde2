package Testing.Types {
	import Testing.Abstractions.InstructionAbstraction;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ArithmeticType extends InstructionType {
		
		protected var symmetric:Boolean = true;
		protected var abstraction:Class;
		public function ArithmeticType(Name:String, Abstraction:Class) {
			super(Name);
			abstraction = Abstraction;
		}
		
		
		protected function operate(a:int, b:int):int {
			return C.INT_NULL;
		}
		
		protected function reverseOp(a:int, b:int):int {
			return C.INT_NULL;
		}
		
		
		override public function can_produce(value:int):Boolean {
			return true;
		}
		
		override public function can_produce_with_one(value:int, arg:int):Boolean {
			var a2:int = reverseOp(value, arg);
			if (a2 <= U.MAX_INT && a2 >= U.MIN_INT)
				return true;
			
			if (!symmetric)
				return false;
			
			a2 = operate(arg, value);
			return a2 <= U.MAX_INT && a2 >= U.MIN_INT;
		}
		
		override public function can_produce_with_one_of(value:int, args:Vector.<int>):Boolean {
			for each (var arg:int in args)
				if (can_produce_with_one(value, arg))
					return true;
			return false;
		}
		
		override public function can_produce_with(value:int, args:Vector.<int>):Boolean {
			for (var i:int = 0; i < args.length; i++) {
				var a1:int = args[i];
				for (var j:int = i; j < args.length; j++) {
					var a2:int = args[j];
					if (operate(a1, a2) == value || (!symmetric && operate(a2, a1) == value))
						return true;
				}
			}
			return false;
		}
		
		
		override public function produce_with_one(value:int, depth:int, arg:int):InstructionAbstraction {
			if (symmetric) {
				var order:int = int(FlxG.random() * 2); //0 or 1
				return new abstraction(depth, order ? arg : reverseOp(value, arg), order ?  reverseOp(value, arg) : arg);
			}
			
			var a2:int = reverseOp(value, arg);
			if (a2 <= U.MAX_INT && a2 >= U.MIN_INT)
				return new abstraction(depth, reverseOp(value, arg), arg);
			return new abstraction(depth, arg, operate(arg, value));
		}
		
		override public function produce_with(value:int, depth:int, args:Vector.<int>):InstructionAbstraction {
            var pairs:Array = [];
			for (var i:int = 0; i < args.length; i++) {
				var a1:int = args[i];
				for (var j:int = i; j < args.length; j++) {
					var a2:int = args[j];
					if (operate(a1, a2) == value)
                        pairs.push([a1, a2]);
					if (!symmetric && operate(a2, a1) == value)
						pairs.push([a2, a1]);
				}
			}
            var pair:Array = C.randomChoice(pairs);
			if (!symmetric)
				return new abstraction(depth, pair[0], pair[1]);
			
			var order:int = int(FlxG.random() * 2); //0 or 1
			return new abstraction(depth, pair[order], pair[1 - order]);
		}
		
		
	}

}