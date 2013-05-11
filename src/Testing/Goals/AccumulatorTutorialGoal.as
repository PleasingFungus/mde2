package Testing.Goals {
	import LevelStates.LevelState;
	import Values.Value;
	import Values.NumericValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AccumulatorTutorialGoal extends LevelGoal {
		
		public function AccumulatorTutorialGoal() {
			super();
			description = "Set memory lines 0-4 to 0-4!";
			dynamicallyTested = true;
			timeLimit = 10;
			
			expectedMemory = generateBlankMemory();
			for (var i:int = 0; i < 5; i++)
				expectedMemory[i] = new NumericValue(i);
		}
		
	}

}