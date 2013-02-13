package Testing {
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelGoal {
		
		public var description:String;
		public var dynamicallyTested:Boolean;
		public function LevelGoal(Description:String, DynamicallyTested:Boolean = true) {
			description = Description;
			dynamicallyTested = DynamicallyTested;
		}
		
		public function genMem(Seed:Number = NaN):Vector.<Value> {
			return null;
		}
		
		public function runTest(levelState:LevelState):void {
			
		}
	}

}