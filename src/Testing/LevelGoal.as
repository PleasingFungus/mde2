package Testing {
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelGoal {
		
		public var description:String;
		public var dynamicallyTested:Boolean;
		public var timeLimit:int = int.MAX_VALUE;
		public function LevelGoal(Description:String, DynamicallyTested:Boolean = true) {
			description = Description;
			dynamicallyTested = DynamicallyTested;
		}
		
		public function genMem(Seed:Number = NaN):Vector.<Value> {
			return null;
		}
		
		public function runTest(levelState:LevelState):void {
			
		}
		
		public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			return false;
		}
	}

}