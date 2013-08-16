package Testing.Tests {
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CollatzTest extends NumericTest {
		
		public function CollatzTest(_:Vector.<OpcodeValue>, Numbers:int = 5, Seed:Number = NaN) {
			super(Numbers, Seed);
		}
		
		private const ALLOWABLE_COLLATZ:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 32];
		override protected function randomNumber():int { return C.randomChoice(ALLOWABLE_COLLATZ) };
		override protected function executionsFor(num:int):int { return collatz(num); }
		override protected function transformedNumber(input:int):int { return collatz(input); }
		
		private function collatz(num:int):int {
			for (var i:int = 0; num != 1; i++)
				num = num % 2 ? num * 3 + 1 : num / 2;
			return i;
		}
	}

}