package Testing.Tests {
	import Values.OpcodeValue;
	import Values.Value;
	import Values.IntegerValue;
	import Testing.Instructions.Instruction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NumericTest extends Test {
		
		protected var numbers:Vector.<int>;
		public function NumericTest(NumsPerTest:int = 5, Seed:Number = NaN) {
			super(new Vector.<OpcodeValue>, NumsPerTest, Seed); 
		}
		
		override protected function generate():void {
			numbers = new Vector.<int>;
			expectedExecutions = 0;
			for (var i:int = 0; i < expectedInstructions; i++) {
				var num:int = randomNumber();
				numbers.push(num);
				expectedExecutions += executionsFor(num);
			}
			
			instructions = new Vector.<Instruction>;
		}
		
		override protected function genInitialMemory():Vector.<Value> {
			var memory:Vector.<Value> = generateBlankMemory();
			for (var i:int = 0; i < numbers.length; i++)
				memory[i] = new IntegerValue(numbers[i]);
			return memory;
		}
		
		override protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			for (var i:int = 0; i < numbers.length; i++)
				memory[i] = new IntegerValue(transformedNumber(numbers[i]));
			return memory;
		}
		
		protected function randomNumber():int { return C.randomRange(U.MIN_INT, U.MAX_INT) };
		protected function executionsFor(num:int):int { return 1; }
		protected function transformedNumber(input:int):int { return input; }
		
	}

}