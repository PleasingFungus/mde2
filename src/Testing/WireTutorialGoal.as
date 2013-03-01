package Testing {
	import Values.Value;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireTutorialGoal extends LevelGoal {
		
		public function WireTutorialGoal() {
			super("Set memory line 1 to 2!");
			dynamicallyTested = true;
			timeLimit = 5;
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			return levelState.memory[1].toNumber() == 2;
		}
		
	}

}