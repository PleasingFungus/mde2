package Testing.Types {
	import Testing.Abstractions.MulAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.OpcodeValue;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MulType extends ArithmeticType {
		
		public function MulType() {
			super("Mul", MulAbstraction);
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_MUL;
		}
		
		
		override protected function produceValue(a:int, b:int):int {
			return a * b;
		}
		
		override protected function produceArgB(a:int, v:int):int {
			if (a)
				return v / a;
			return NaN;
		}
		
		override public function can_produce_with_one(value:int, arg:int):Boolean {
			return C.factorsOf(Math.abs(value)).indexOf(arg) != -1;
		}
		
		
		override public function produce_unrestrained(value:int):InstructionAbstraction {
			if (!value) {
				var order:int = int(FlxG.random() * 2);
				return new MulAbstraction(order ? C.randomRange(U.MIN_INT, U.MAX_INT + 1) : 0, order ? 0 : C.randomRange(U.MIN_INT, U.MAX_INT + 1));
			}
			
			var factors:Array = C.factorsOf(Math.abs(value));
            var a1:int = C.randomChoice(factors);
            var a2:int = value / a1;
			return new MulAbstraction(a1, a2);
		}
		
	}

}