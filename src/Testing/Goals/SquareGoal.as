package Testing.Goals {
	import Testing.Tests.SquareTest;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SquareGoal extends GeneratedGoal {
		
		public function SquareGoal() {
			super(SquareTest, new Vector.<OpcodeValue>, 12, 2, 5);
			description = "Square each value in memory lines 0-4!";
		}
		
	}

}