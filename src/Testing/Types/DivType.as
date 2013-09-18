package Testing.Types {
	import Testing.Abstractions.DivAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.OpcodeValue;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DivType extends ArithmeticType {
		
		public function DivType() {
			super("Div", DivAbstraction);
			symmetric = false;
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_DIV;
		}
		
		override public function get symbol():String { return '/'; }
		
		
		override protected function produceValue(a:int, b:int):int {
			if (b)
				return a / b;
			return NaN;
		}
		
		override protected function produceArgB(a:int, v:int):int {
			if ((!v && a) || (!a && !v))
				return NaN;
			if (!a)
				return FlxG.random() > 0.5 ? C.randomRange(U.MIN_INT, 0) : C.randomRange(1, U.MAX_INT);
			return v / a;
		}
		
		
		override protected function produce_unrestrained(valueAbstr:AbstractArg):InstructionAbstraction {
			var value:int = valueAbstr.value;
			
			var divisor:int = FlxG.random() > 0.5 ? C.randomRange(U.MIN_INT, 0) : C.randomRange(1, U.MAX_INT);
			if (value == 0)
				return new DivAbstraction(0, divisor);
            var a1:int = value * divisor;
			return new DivAbstraction(a1, divisor);
		}
		
		override public function produce(...args):InstructionAbstraction { return new DivAbstraction(args[0], args[1]); }
		
	}

}