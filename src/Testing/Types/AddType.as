package Testing.Types {
	import Testing.Abstractions.AddAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddType extends ArithmeticType {
		
		public function AddType() {
			super("Add", AddAbstraction);
		}
		
		
		override protected function operate(a:int, b:int):int {
			return a + b;
		}
		
		override protected function reverseOp(v:int, b:int):int {
			return v - b;
		}
		
		
		override public function produce_unrestrained(value:int, depth:int):InstructionAbstraction {
			var minAddend:int = Math.max(U.MIN_INT, value - U.MAX_INT);
			var maxAddend:int = Math.max(U.MAX_INT, value - U.MIN_INT);
        
            var a1:int = C.randomRange(minAddend, maxAddend+1);
            var a2:int = value - a1;
			return new AddAbstraction(depth, a1, a2);
		}
		
	}

}