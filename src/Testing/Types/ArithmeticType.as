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
		
		
		protected function produceValue(a:int, b:int):int {
			return C.INT_NULL;
		}
		
		protected function produceArgB(a:int, v:int):int {
			return C.INT_NULL;
		}
		
		
		override public function can_produce(value:int):Boolean {
			return true;
		}
		
		override public function can_produce_with_one(value:int, arg:int):Boolean {
			var b:int = produceArgB(value, arg);
			if (b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value)
				return true;
			
			if (!symmetric)
				return false;
			
			b = produceValue(arg, value);
			return b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value;
		}
		
		override public function can_produce_with_one_of(value:int, args:Vector.<int>):Boolean {
			for each (var arg:int in args)
				if (can_produce_with_one(value, arg))
					return true;
			return false;
		}
		
		override public function can_produce_with(value:int, args:Vector.<int>):Boolean {
			for (var i:int = 0; i < args.length; i++) {
				var a:int = args[i];
				for (var j:int = i; j < args.length; j++) {
					var b:int = args[j];
					if (produceValue(a, b) == value || (!symmetric && produceValue(b, a) == value))
						return true;
				}
			}
			return false;
		}
		
		
		override public function produce_with_one(value:int, depth:int, arg:int):InstructionAbstraction {
			if (symmetric) {
				var order:int = int(FlxG.random() * 2); //0 or 1
				return new abstraction(depth,
									   order ? arg : produceArgB(arg, value),
									   order ?  produceArgB(arg, value) : arg);
			}
			
			var b:int = produceArgB(arg, value);
			if (b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value)
				return new abstraction(depth, arg, b);
			return new abstraction(depth, arg, produceValue(arg, value));
		}
		
		override public function produce_with(value:int, depth:int, args:Vector.<int>):InstructionAbstraction {
            var pairs:Array = [];
			for (var i:int = 0; i < args.length; i++) {
				var a:int = args[i];
				for (var j:int = i; j < args.length; j++) {
					var b:int = args[j];
					if (produceValue(a, b) == value)
                        pairs.push([a, b]);
					if (!symmetric && produceValue(b, a) == value)
						pairs.push([b, a]);
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