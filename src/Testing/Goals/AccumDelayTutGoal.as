package Testing.Goals {
	import Values.Value;
	import Values.IntegerValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AccumDelayTutGoal extends AccumulatorTutorialGoal {
		
		public function AccumDelayTutGoal() {
			super();
			timeLimit = 80;
			description = "Set memory lines 0-4 to 0-4!"
			description += "\n\nSame as the last one, but now you'll have to use a non-magical version of the Data Writer module, which has a delay."
			
			expectedMemory = generateBlankMemory();
			for (var i:int = 0; i < 4; i++)
				expectedMemory[i] = new IntegerValue(i);
		}
	}

}