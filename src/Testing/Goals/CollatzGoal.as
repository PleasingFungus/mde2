package Testing.Goals {
	import Testing.Tests.CollatzTest;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CollatzGoal extends GeneratedGoal {
		
		public function CollatzGoal() {
			super(CollatzTest, new Vector.<OpcodeValue>, 12, 2, 5);
			description = "For each value in memory lines 0-4, store the number of steps required for that number to reach 1 under the Collatz procedure!";
		}
	}

}