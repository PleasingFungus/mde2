package Testing {
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AccumulatorTutorialGoal extends LevelGoal {
		
		public function AccumulatorTutorialGoal() {
			super("Set memory lines 1-5 to 1-5!");
			dynamicallyTested = true;
			timeLimit = 10;
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean = false):Boolean {
			for (var i:int = 1; i <= 5; i++)
				if (levelState.memory[i].toNumber() != i)
					return false;
			return true;
		}
		
	}

}