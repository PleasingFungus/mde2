package Testing {
	import Testing.Goals.LevelGoal;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class TestState {
		
		public var goal:LevelGoal;
		public var running:Boolean;
		public var succeeded:Boolean;
		public function TestState(Goal:LevelGoal) {
			goal = Goal;
		}
		
		public function startRun():void {
			goal.startRun();
			running = true;
			succeeded = false;
		}
		
		public function endRun():void {
			running = false;
			goal.endRun();
		}
		
		public function runTestStep(levelState:LevelState):void {
			goal.runTestStep(levelState);
			succeeded = levelState.time.moment < goal.timeLimit;
			if (!succeeded || goal.done())
				endRun();
		}
		
	}

}