package Testing.Types {
	import Testing.Abstractions.SubAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SubType extends ArithmeticType {
		
		public function SubType() {
			super("Sub", SubAbstraction);
			symmetric = false;
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_SUB;
		}
		
		
		override protected function operate(a:int, b:int):int {
			return a - b;
		}
		
		override protected function reverseOp(v:int, b:int):int {
			return v + b;
		}
		
		
		override public function produce_unrestrained(value:int, depth:int):InstructionAbstraction {
            var a1:int = C.randomRange(U.MIN_INT, U.MAX_INT + 1);
            var a2:int = a1 - value;
			return new SubAbstraction(depth, a1, a2);
		}
		
	}

}