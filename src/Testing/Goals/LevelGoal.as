package Testing.Goals {
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
		public var succeeded:Boolean;
		public var timeLimit:int = int.MAX_VALUE;
		
		protected var expectedMemory:Vector.<Value>;
		
		public var running:Boolean;
		public function LevelGoal(Description:String) {
			description = Description;
		}
		
		public function genMem():Vector.<Value> {
			return generateBlankMemory();
		}
		
		protected function generateBlankMemory():Vector.<Value> {
			var memory:Vector.<Value> = new Vector.<Value>;
			for (var i:int = memory.length; i < U.MAX_MEM; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		public function genExpectedMem():Vector.<Value> {
			return expectedMemory;
		}
		
		public function startRun():void {
			running = true;
			succeeded = false;
		}
		
		public function endRun():void {
			running = false;
		}
		
		public function runTestStep(levelState:LevelState):void {
			levelState.time.reset();
			while (levelState.time.moment < timeLimit && !stateValid(levelState))
				levelState.time.step();
			
			succeeded = stateValid(levelState, true);
			if (!succeeded || done())
				endRun();
		}
		
		public function getProgress():String { return ""; }
		public function getTime():String { return ""; }
		
		protected function done():Boolean {
			return true;
		}
		
		
		public function stateValid(levelState:LevelState, print:Boolean = false):Boolean {
			var expectedMemory:Vector.<Value> = genExpectedMem();
			if (!expectedMemory)
				return false;
			
			return memoryMatches(levelState.memory, expectedMemory);
		}
		
		protected function memoryMatches(memory:Vector.<Value>, expectedMemory:Vector.<Value>):Boolean {
			for (var line:int = 0; line < memory.length; line++)
				if (!memory[line].eq(expectedMemory[line]))
					return false;
			return true;
		}
	}

}