package Testing.Types {
	import Testing.Abstractions.AddAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import org.flixel.FlxG;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddType extends ArithmeticType {
		
		public function AddType() {
			super("Add", AddAbstraction);
		}
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_ADD;
		}
		
		
		override protected function produceValue(a:int, b:int):int {
			return a + b;
		}
		
		override protected function produceArgB(a:int, v:int):int {
			return v - a;
		}
		
		
		override protected function produce_unrestrained(valueAbstr:AbstractArg):InstructionAbstraction {
			var value:int = valueAbstr.value;
			
			var minAddend:int = Math.max(U.MIN_INT, value - U.MAX_INT);
			var maxAddend:int = Math.min(U.MAX_INT, value - U.MIN_INT);
        
            var a1:int = C.randomRange(minAddend, maxAddend+1);
            var a2:int = value - a1;
			return new AddAbstraction(a1, a2);
		}
		
		override public function produce(...args):InstructionAbstraction { return new AddAbstraction(C.INT_NULL, C.INT_NULL); }
	}

}