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
			super("Set memory lines 1-5 to 1-5!");
			dynamicallyTested = true;
			timeLimit = 10;
			
			expectedMemory = generateBlankMemory();
			for (var i:int = 1; i <= 5; i++)
				expectedMemory[i] = new NumericValue(i);
		}
		
	}

}