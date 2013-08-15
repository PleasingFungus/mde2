package Testing.Tests {
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SquareTest extends NumericTest {
		
		public function SquareTest(_:Vector.<OpcodeValue>, Numbers:int = 5, Seed:Number = NaN) {
			super(Numbers, Seed);
		}
		
		override protected function randomNumber():int { return C.randomRange(-16, 16) };
		override protected function executionsFor(num:int):int { return Math.abs(num); }
		override protected function transformedNumber(input:int):int { return input * input; }
	}

}