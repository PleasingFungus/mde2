package Testing.Goals {
	import Values.NumericValue;
	import Values.Value;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireTutorialGoal extends LevelGoal {
		
		public function WireTutorialGoal(TimeLimit:int =2, Description:String = "Set memory line 1 to 2!") {
			super(Description);
			dynamicallyTested = true;
			timeLimit = timeLimit = TimeLimit;
			
			expectedMemory = generateBlankMemory();
			expectedMemory[1] = new NumericValue(2);
		}
		
	}

}