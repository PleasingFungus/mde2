package Testing {
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireTutorialGoal extends LevelGoal {
		
		public function WireTutorialGoal() {
			super("Set memory line 1 to 2!", true);
			timeLimit = 5;
		}
		
		override public function genMem(Seed:Number = NaN):Vector.<Value> {
			return generateBlankMemory();
		}
		
		override public function runTest(levelState:LevelState):void {
			levelState.time.reset();
			while (levelState.time.moment < timeLimit && !stateValid(levelState))
				levelState.time.step();
			
			if (stateValid(levelState, true))
				C.log("Success!");
			else
				C.log("Failure!");
			
			levelState.time.reset();
			levelState.runTest();
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			return levelState.memory[1].toNumber() == 2;
		}
		
	}

}