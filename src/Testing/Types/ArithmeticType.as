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
		
		
		override protected function can_produce(value:AbstractArg):Boolean {
			return value.inRegisters;
		}
		
		override protected function can_produce_with_one(valueAbstr:AbstractArg, argAbstr:AbstractArg):Boolean {
			var arg:int = argAbstr.value;
			var value:int = valueAbstr.value;
			
			var b:int = produceArgB(arg, value);
			if (b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value)
				return true;
			
			if (symmetric)
				return false;
			
			b = produceValue(arg, value);
			return b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value;
		}
		
		override protected function can_produce_with(valueAbstr:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			var value:int = valueAbstr.value;
			
			for (var i:int = 0; i < args.length; i++) {
				var a:int = args[i].value;
				for (var j:int = i; j < args.length; j++) {
					var b:int = args[j].value;
					if (produceValue(a, b) == value || (!symmetric && produceValue(b, a) == value))
						return true;
				}
			}
			return false;
		}
		
		
		override protected function produce_with_one(valueAbstr:AbstractArg, argAbstr:AbstractArg):InstructionAbstraction {
			var arg:int = argAbstr.value;
			var value:int = valueAbstr.value;
			
			if (symmetric) {
				var order:int = int(FlxG.random() * 2); //0 or 1
				return new abstraction(order ? arg : produceArgB(arg, value),
									   order ?  produceArgB(arg, value) : arg);
			}
			
			var b:int = produceArgB(arg, value);
			if (b <= U.MAX_INT && b >= U.MIN_INT && produceValue(arg, b) == value)
				return new abstraction(arg, b);
			return new abstraction(arg, produceValue(arg, value));
		}
		
		override protected function produce_with(valueAbstr:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			var value:int = valueAbstr.value;
			
            var pairs:Array = [];
			for (var i:int = 0; i < args.length; i++) {
				var a:int = args[i].value;
				for (var j:int = i; j < args.length; j++) {
					var b:int = args[j].value;
					if (produceValue(a, b) == value)
                        pairs.push([a, b]);
					if (!symmetric && produceValue(b, a) == value)
						pairs.push([b, a]);
				}
			}
            var pair:Array = C.randomChoice(pairs);
			if (!symmetric)
				return new abstraction(pair[0], pair[1]);
			
			var order:int = int(FlxG.random() * 2); //0 or 1
			return new abstraction(pair[order], pair[1 - order]);
		}
		
		
	}

}