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
		
		override public function get symbol():String { return '-'; }
		
		
		override protected function produceValue(a:int, b:int):int {
			return a - b;
		}
		
		override protected function produceArgB(a:int, v:int):int {
			return v - a;
		}
		
		
		override protected function produce_unrestrained(valueAbstr:AbstractArg):InstructionAbstraction {
			var a1:int = C.randomRange(U.MIN_INT, U.MAX_INT);
            var a2:int = a1 - valueAbstr.value;
			return new SubAbstraction(a1, a2);
		}
		
		override public function produce(...args):InstructionAbstraction { return new SubAbstraction(C.INT_NULL, C.INT_NULL); }
		
	}

}