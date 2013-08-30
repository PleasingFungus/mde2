package Testing.Goals {
	import Values.FixedValue;
	import Values.IntegerValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FibonacciGoal extends LevelGoal {
		
		public function FibonacciGoal() {
			super();
			expectedMemory = genMem();
			var len:int = 12;
			for (var i:int = 2; i < len; i++)
				expectedMemory[i] = new IntegerValue(expectedMemory[i - 1].toNumber() + expectedMemory[i - 2].toNumber());
			description = "Generate the first " + len + " digits of the Fibonacci sequence.";
			dynamicallyTested = true;
		}
		
		override public function genMem():Vector.<Value> {
			var mem:Vector.<Value> = generateBlankMemory();
			mem[0] = mem[1] = new IntegerValue(1);
			return mem;
		}
	}

}