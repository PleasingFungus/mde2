package Testing.Types {
	import Testing.Abstractions.DivAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.OpcodeValue;
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
		
		override public function can_produce(value:int):Boolean {
			return value != 0;
		}
		
		
		override protected function operate(a:int, b:int):int {
			if (b)
				return a / b;
			return NaN;
		}
		
		override protected function reverseOp(v:int, b:int):int {
			return v * b;
		}
		
		
		override public function produce_unrestrained(value:int, depth:int):InstructionAbstraction {
            var a1:int = C.randomRange(U.MIN_INT, U.MAX_INT + 1);
            var a2:int = a1 / value;
			return new DivAbstraction(depth, a1, a2);
		}
		
	}

}