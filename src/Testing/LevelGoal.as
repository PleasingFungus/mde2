package Testing {
	import Values.Value;
	import Values.FixedValue;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelGoal {
		
		public var description:String;
		public var dynamicallyTested:Boolean;
		public var randomizedMemory:Boolean;
		public var timeLimit:int = int.MAX_VALUE;
		
		public var running:Boolean;
		public function LevelGoal(Description:String) {
			description = Description;
		}
		
		public function genMem(Seed:Number = NaN):Vector.<Value> {
			return generateBlankMemory();
		}
		
		protected function generateBlankMemory():Vector.<Value> {
			var memory:Vector.<Value> = new Vector.<Value>;
			for (var i:int = memory.length; i < U.MAX_INT - U.MIN_INT; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		public function startRun():void {
			running = true;
		}
		
		public function endRun():void {
			running = false;
		}
		
		public function runTestStep(levelState:LevelState):Boolean {
			levelState.time.reset();
			while (levelState.time.moment < timeLimit && !stateValid(levelState))
				levelState.time.step();
			
			var success:Boolean = stateValid(levelState, true);
			if (!success || done())
				endRun();
			return success;
		}
		
		public function getProgress():String {
			return "";
		}
		
		protected function done():Boolean {
			return true;
		}
		
		public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			return false;
		}
	}

}